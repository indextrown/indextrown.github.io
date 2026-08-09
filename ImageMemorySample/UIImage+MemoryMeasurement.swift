import Foundation
import ImageIO
import UIKit

/// `CGImage`가 설명하는 비트맵 레이아웃으로 계산한 이미지 1장의 크기입니다.
/// 앱 프로세스 전체 메모리나 GPU/캐시 사용량을 측정하는 값은 아닙니다.
struct BitmapMemoryMeasurement {
    let pixelWidth: Int
    let pixelHeight: Int
    let bytesPerRow: Int

    /// 행당 바이트 수와 높이로 계산한 비트맵 픽셀 버퍼 크기입니다.
    var bitmapByteCount: Int {
        bytesPerRow * pixelHeight
    }

    var memoryText: String {
        String(format: "%.2f MiB", Double(bitmapByteCount) / 1_048_576)
    }
}

extension UIImage {
    /// 압축된 원본 데이터를 목표 표시 크기에 맞는 작은 이미지로 바로 다운샘플링합니다.
    static func downsampled(
        data: Data,
        to targetSize: CGSize,
        scale: CGFloat
    ) -> UIImage? {
        let maxPixelSize = max(targetSize.width, targetSize.height) * scale

        guard
            maxPixelSize > 0,
            let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxPixelSize.rounded())
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            options as CFDictionary
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    /// 이미지가 가진 `CGImage`의 비트맵 레이아웃을 이용해 픽셀 버퍼 크기를 계산합니다.
    ///
    /// 예: 2250 × 2812 이미지에서 `bytesPerRow`가 9000이면
    /// `9000 × 2812 = 25,308,000 byte`, 약 24.14 MiB입니다.
    ///
    /// - Important: 이 값은 이미지 한 장의 비트맵 버퍼 크기입니다. JPEG 압축 파일 크기,
    ///   `UIImage` 객체 오버헤드, 이미지 캐시, Core Animation 렌더링 표면, 앱 전체 메모리는 포함하지 않습니다.
    func bitmapMemoryMeasurement() -> BitmapMemoryMeasurement? {
        guard let cgImage else { return nil }

        return BitmapMemoryMeasurement(
            pixelWidth: cgImage.width,
            pixelHeight: cgImage.height,
            bytesPerRow: cgImage.bytesPerRow
        )
    }

    /// `UIGraphicsImageRenderer`로 이미 디코드된 이미지를 목표 픽셀 너비에 맞춰 다시 그립니다.
    ///
    /// 이 방식은 최종 출력 이미지의 픽셀 수를 줄이지만, `draw(in:)` 중에는 원본 전체가
    /// 디코드될 수 있습니다. 원본 디코드 자체를 줄이는 용도라면 ImageIO 다운샘플링이 적합합니다.
    func resized(toPixelWidth targetPixelWidth: Int) -> UIImage? {
        guard targetPixelWidth > 0, let cgImage, cgImage.width > 0 else { return nil }

        let targetPixelHeight = Int(
            (CGFloat(cgImage.height) / CGFloat(cgImage.width) * CGFloat(targetPixelWidth)).rounded()
        )
        let targetSize = CGSize(width: targetPixelWidth, height: targetPixelHeight)
        let format = UIGraphicsImageRendererFormat()

        // `targetSize`를 실제 출력 픽셀 크기로 사용합니다.
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
