import Foundation
import UIKit

struct ImageResizeResult {
    let screenScale: CGFloat
    let targetPixelWidth: Int
    let original: BitmapMemoryMeasurement
    let resized: BitmapMemoryMeasurement
}

struct ImageDownsampleResult {
    let screenScale: CGFloat
    let targetSize: CGSize
    let maxPixelSize: Int
    let original: BitmapMemoryMeasurement
    let downsampled: BitmapMemoryMeasurement
}

@MainActor
final class PopupImageLoader: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    static let expectedPixelWidth = 2250
    static let expectedPixelHeight = 2812
    static let expectedDecodedBytes = expectedPixelWidth * expectedPixelHeight * 4
    static let expectedDecodedMemoryText = String(
        format: "%.2f MiB",
        Double(expectedDecodedBytes) / 1_048_576
    )

    static let sourceURL = URL(string: "https://poppang.co.kr/images/20260805-110013_18076623047343482/%EB%A7%88%EB%8B%88_%ED%99%88%EC%9B%A8%EC%96%B4_%ED%8C%9D%EC%97%85%EC%8A%A4%ED%86%A0%EC%96%B4_1.jpg")!

    @Published private(set) var image: UIImage?
    @Published private(set) var decodedImageInfo: BitmapMemoryMeasurement?
    @Published private(set) var state: LoadState = .idle

    func load() async {
        guard state != .loading, image == nil else { return }

        state = .loading

        do {
            let (data, response) = try await URLSession.shared.data(from: Self.sourceURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            guard let originalImage = UIImage(data: data) else {
                throw CocoaError(.fileReadCorruptFile)
            }

            // 원본 해상도를 유지한 채 화면 표시용으로 디코딩합니다.
            // scaledToFit()은 UI 크기만 바꿀 뿐, 이 원본 픽셀 버퍼를 줄이지 않습니다.
            let displayImage = originalImage.preparingForDisplay() ?? originalImage
            image = displayImage
            decodedImageInfo = displayImage.bitmapMemoryMeasurement()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func reload() async {
        unload()
        URLCache.shared.removeCachedResponse(for: URLRequest(url: Self.sourceURL))
        await load()
    }

    /// 다음 화면으로 이동하기 전에 원본 비트맵의 강한 참조를 끊습니다.
    func unload() {
        image = nil
        decodedImageInfo = nil
        state = .idle
    }
}

/// 원본을 먼저 표시하고, 버튼을 누르면 축소본으로 교체하는 화면용 로더입니다.
@MainActor
final class ResizedPopupImageLoader: ObservableObject {
    @Published private(set) var originalImage: UIImage?
    @Published private(set) var resizedImage: UIImage?
    @Published private(set) var resizeResult: ImageResizeResult?
    @Published private(set) var state: PopupImageLoader.LoadState = .idle
    @Published private(set) var isResizing = false

    func loadOriginal() async {
        guard state != .loading, originalImage == nil else { return }

        state = .loading

        do {
            let (data, response) = try await URLSession.shared.data(from: PopupImageLoader.sourceURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            guard let originalImage = UIImage(data: data) else {
                throw CocoaError(.fileReadCorruptFile)
            }

            let displayImage = originalImage.preparingForDisplay() ?? originalImage
            self.originalImage = displayImage
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func resize(toPixelWidth targetPixelWidth: Int = 350, screenScale: CGFloat) {
        guard
            let originalImage,
            resizedImage == nil,
            !isResizing
        else { return }

        isResizing = true
        state = .loading

        defer {
            isResizing = false
        }

        guard
            let original = originalImage.bitmapMemoryMeasurement(),
            let resizedImage = originalImage.resized(toPixelWidth: targetPixelWidth),
            let resized = resizedImage.bitmapMemoryMeasurement()
        else {
            state = .failed("이미지를 리사이징하지 못했습니다.")
            return
        }

        // 화면에서 원본을 제거한 뒤 축소본만 강하게 보관합니다.
        self.originalImage = nil
        self.resizedImage = resizedImage
        resizeResult = ImageResizeResult(
            screenScale: screenScale,
            targetPixelWidth: targetPixelWidth,
            original: original,
            resized: resized
        )
        state = .loaded

        print(
            """
            화면 배율: \(String(format: "%.1f", screenScale))
            오리지널 - 사이즈: \(String(format: "%.1f", Double(original.pixelWidth))) x \(String(format: "%.1f", Double(original.pixelHeight))), 용량: \(original.memoryText)
            ✅ 리사이징 - 사이즈: \(String(format: "%.1f", Double(resized.pixelWidth))) x \(String(format: "%.1f", Double(resized.pixelHeight))), 용량: \(resized.memoryText)
            """
        )
    }
}

/// 원본을 먼저 표시한 뒤, 원본 Data에서 ImageIO 다운샘플링 결과를 만드는 화면용 로더입니다.
@MainActor
final class DownsampledPopupImageLoader: ObservableObject {
    @Published private(set) var originalImage: UIImage?
    @Published private(set) var downsampledImage: UIImage?
    @Published private(set) var downsampleResult: ImageDownsampleResult?
    @Published private(set) var state: PopupImageLoader.LoadState = .idle
    @Published private(set) var isDownsampling = false

    private var sourceData: Data?

    func loadOriginal() async {
        guard state != .loading, originalImage == nil else { return }

        state = .loading

        do {
            let (data, response) = try await URLSession.shared.data(from: PopupImageLoader.sourceURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            guard let originalImage = UIImage(data: data) else {
                throw CocoaError(.fileReadCorruptFile)
            }

            sourceData = data
            self.originalImage = originalImage.preparingForDisplay() ?? originalImage
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func downsample(
        to targetSize: CGSize,
        scale: CGFloat
    ) {
        guard
            let originalImage,
            let sourceData,
            downsampledImage == nil,
            !isDownsampling
        else { return }

        isDownsampling = true
        state = .loading

        defer {
            isDownsampling = false
        }

        guard
            let original = originalImage.bitmapMemoryMeasurement(),
            let downsampledImage = UIImage.downsampled(
                data: sourceData,
                to: targetSize,
                scale: scale
            ),
            let downsampled = downsampledImage.bitmapMemoryMeasurement()
        else {
            state = .failed("이미지를 다운샘플링하지 못했습니다.")
            return
        }

        let maxPixelSize = Int(
            (max(targetSize.width, targetSize.height) * scale).rounded()
        )

        // 데모에서는 전후 비교를 위해 원본을 먼저 보여줍니다.
        // 실제 앱에서는 원본 UIImage를 만들지 않고 이 메서드를 바로 호출합니다.
        self.originalImage = nil
        self.sourceData = nil
        self.downsampledImage = downsampledImage
        downsampleResult = ImageDownsampleResult(
            screenScale: scale,
            targetSize: targetSize,
            maxPixelSize: maxPixelSize,
            original: original,
            downsampled: downsampled
        )
        state = .loaded

        print(
            """
            화면 배율: \(String(format: "%.1f", scale))
            오리지널 - 사이즈: \(String(format: "%.1f", Double(original.pixelWidth))) x \(String(format: "%.1f", Double(original.pixelHeight))), 용량: \(original.memoryText)
            ✅ 다운샘플링 - 사이즈: \(String(format: "%.1f", Double(downsampled.pixelWidth))) x \(String(format: "%.1f", Double(downsampled.pixelHeight))), 용량: \(downsampled.memoryText)
            """
        )
    }
}
