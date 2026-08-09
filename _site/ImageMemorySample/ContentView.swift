import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("측정 화면") {
                    NavigationLink(value: ImageDemoRoute.original) {
                        Label("원본 이미지", systemImage: "photo")
                    }

                    NavigationLink(value: ImageDemoRoute.resized) {
                        Label("리사이징", systemImage: "arrow.down.right.and.arrow.up.left")
                    }

                    NavigationLink(value: ImageDemoRoute.downsampled) {
                        Label("다운샘플링", systemImage: "arrow.down.right.and.arrow.up.left.circle")
                    }
                }
            }
            .navigationTitle("이미지 메모리")
            .navigationDestination(for: ImageDemoRoute.self) { route in
                switch route {
                case .original:
                    OriginalImageScreen()
                case .resized:
                    ResizedImageScreen()
                case .downsampled:
                    DownsampledImageScreen()
                }
            }
        }
    }
}

private enum ImageDemoRoute: Hashable {
    case original
    case resized
    case downsampled
}

private struct OriginalImageScreen: View {
    @StateObject private var loader = PopupImageLoader()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                imageSection
                expectedMemorySection
                loadedImageSection
                noteSection
            }
            .padding()
            .padding(.bottom, 20)
        }
        .navigationTitle("원본 이미지")
        .onAppear {
            guard loader.image == nil, loader.state == .idle else { return }
            Task {
                await loader.load()
            }
        }
    }

    @ViewBuilder
    private var imageSection: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .accessibilityLabel("팝팡 홈웨어 팝업 이미지")
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.quaternary)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(2250.0 / 2812.0, contentMode: .fit)
                    .overlay {
                        if loader.state == .loading {
                            ProgressView("원본 이미지 준비 중")
                        } else if case let .failed(message) = loader.state {
                            ContentUnavailableView(
                                "이미지를 불러오지 못했습니다",
                                systemImage: "exclamationmark.triangle",
                                description: Text(message)
                            )
                        } else {
                            ContentUnavailableView(
                                "이미지를 준비합니다",
                                systemImage: "photo"
                            )
                        }
                    }
            }
        }
    }

    private var expectedMemorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("예상 디코딩 메모리")
                .font(.title3.bold())

            metricRow(
                title: "계산",
                value: "2250 × 2812 × 4 byte",
                detail: "RGBA 8-bit 기준, 픽셀당 4 byte"
            )
            metricRow(
                title: "결과",
                value: PopupImageLoader.expectedDecodedMemoryText,
                detail: "25,308,000 byte ≈ 24.14 MiB"
            )
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var loadedImageSection: some View {
        if let info = loader.decodedImageInfo {
            VStack(alignment: .leading, spacing: 12) {
                Text("불러온 이미지")
                    .font(.title3.bold())

                metricRow(
                    title: "실제 크기",
                    value: "\(info.pixelWidth) × \(info.pixelHeight)",
                    detail: "CGImage 픽셀 기준"
                )
                metricRow(
                    title: "픽셀 버퍼",
                    value: info.memoryText,
                    detail: "bytesPerRow \(info.bytesPerRow.formatted()) × 높이 \(info.pixelHeight.formatted())"
                )
            }
            .padding()
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("확인 포인트")
                .font(.title3.bold())
            Text("화면에서 작게 보이도록 scaledToFit()을 적용해도, 이 예제는 원본 전체를 디코딩합니다. 이 화면을 나가면 원본 이미지 참조도 함께 해제됩니다.")
            Text("실제 사용량에는 이미지 캐시, Core Animation 표면, 행 정렬 등이 더해질 수 있어 계산값보다 커질 수 있습니다.")
                .foregroundStyle(.secondary)
        }
        .font(.footnote)
    }

    private func metricRow(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.monospacedDigit().weight(.semibold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ResizedImageScreen: View {
    @StateObject private var loader = ResizedPopupImageLoader()
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                imageSection
                resizeButton
                resizeOutputSection
                noteSection
            }
            .padding()
            .padding(.bottom, 20)
        }
        .navigationTitle("리사이징")
        .task {
            await loader.loadOriginal()
        }
    }

    @ViewBuilder
    private var imageSection: some View {
        if let image = loader.resizedImage ?? loader.originalImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityLabel(
                    loader.resizedImage == nil
                        ? "리사이징 전 원본 팝팡 홈웨어 팝업 이미지"
                        : "가로 350픽셀로 리사이징한 팝팡 홈웨어 팝업 이미지"
                )
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .frame(maxWidth: .infinity)
                .aspectRatio(2250.0 / 2812.0, contentMode: .fit)
                .overlay {
                    if loader.state == .loading {
                        ProgressView("원본 이미지 준비 중")
                    } else if case let .failed(message) = loader.state {
                        ContentUnavailableView(
                            "이미지를 불러오지 못했습니다",
                            systemImage: "exclamationmark.triangle",
                            description: Text(message)
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private var resizeButton: some View {
        if loader.resizedImage == nil {
            Button {
                loader.resize(screenScale: displayScale)
            } label: {
                if loader.isResizing {
                    ProgressView("리사이징 중")
                        .frame(maxWidth: .infinity)
                } else {
                    Label("리사이징", systemImage: "arrow.down.right.and.arrow.up.left")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(loader.originalImage == nil || loader.isResizing)
        }
    }

    @ViewBuilder
    private var resizeOutputSection: some View {
        if let result = loader.resizeResult {
            VStack(alignment: .leading, spacing: 10) {
                Text("리사이징 출력")
                    .font(.headline)

                Text("화면 배율: \(result.screenScale, specifier: "%.1f")")
                Text(
                    "원본 — 크기: \(result.original.pixelWidth) × \(result.original.pixelHeight), 픽셀 버퍼: \(result.original.memoryText)"
                )
                Text(
                    "✅ 리사이징 — 크기: \(result.resized.pixelWidth) × \(result.resized.pixelHeight), 픽셀 버퍼: \(result.resized.memoryText)"
                )
                .foregroundStyle(.green)

                Text("출력 크기: 가로 \(result.targetPixelWidth) px · 렌더러 배율: 1.0")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.monospacedDigit())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundStyle(.white)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var noteSection: some View {
        Text("버튼을 누르면 원본을 축소본으로 교체하고 원본 참조를 해제합니다. 다만 이 방식도 결과를 만들 때는 원본 전체를 디코드하므로, 작업 순간의 CPU와 메모리 피크는 남습니다.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

private struct DownsampledImageScreen: View {
    @StateObject private var loader = DownsampledPopupImageLoader()
    @Environment(\.displayScale) private var displayScale

    /// 2번 리사이징 예제와 같은 350 × 437px 결과를 만들기 위한 논리 크기입니다.
    private var comparisonTargetSize: CGSize {
        let targetPixelWidth: CGFloat = 350
        let targetPixelHeight = (
            CGFloat(PopupImageLoader.expectedPixelHeight) /
            CGFloat(PopupImageLoader.expectedPixelWidth) *
            targetPixelWidth
        ).rounded()

        return CGSize(
            width: targetPixelWidth / displayScale,
            height: targetPixelHeight / displayScale
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                imageSection
                downsampleButton
                downsampleOutputSection
                noteSection
            }
            .padding()
            .padding(.bottom, 20)
        }
        .navigationTitle("다운샘플링")
        .task {
            await loader.loadOriginal()
        }
    }

    @ViewBuilder
    private var imageSection: some View {
        if let image = loader.downsampledImage ?? loader.originalImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityLabel(
                    loader.downsampledImage == nil
                        ? "다운샘플링 전 원본 팝팡 홈웨어 팝업 이미지"
                        : "ImageIO로 다운샘플링한 팝팡 홈웨어 팝업 이미지"
                )
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .frame(maxWidth: .infinity)
                .aspectRatio(2250.0 / 2812.0, contentMode: .fit)
                .overlay {
                    if loader.state == .loading {
                        ProgressView("원본 이미지 준비 중")
                    } else if case let .failed(message) = loader.state {
                        ContentUnavailableView(
                            "이미지를 불러오지 못했습니다",
                            systemImage: "exclamationmark.triangle",
                            description: Text(message)
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private var downsampleButton: some View {
        if loader.downsampledImage == nil {
            Button {
                loader.downsample(to: comparisonTargetSize, scale: displayScale)
            } label: {
                if loader.isDownsampling {
                    ProgressView("다운샘플링 중")
                        .frame(maxWidth: .infinity)
                } else {
                    Label("다운샘플링", systemImage: "arrow.down.right.and.arrow.up.left.circle")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(loader.originalImage == nil || loader.isDownsampling)
        }
    }

    @ViewBuilder
    private var downsampleOutputSection: some View {
        if let result = loader.downsampleResult {
            VStack(alignment: .leading, spacing: 10) {
                Text("다운샘플링 출력")
                    .font(.headline)

                Text("화면 배율: \(result.screenScale, specifier: "%.1f")")
                Text(
                    "원본 — 크기: \(result.original.pixelWidth) × \(result.original.pixelHeight), 픽셀 버퍼: \(result.original.memoryText)"
                )
                Text(
                    "✅ 다운샘플링 — 크기: \(result.downsampled.pixelWidth) × \(result.downsampled.pixelHeight), 픽셀 버퍼: \(result.downsampled.memoryText)"
                )
                .foregroundStyle(.green)

                Text(
                    "비교 기준: 리사이징 예제와 같은 \(result.downsampled.pixelWidth) × \(result.downsampled.pixelHeight) px"
                )
                .foregroundStyle(.secondary)
            }
            .font(.subheadline.monospacedDigit())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundStyle(.white)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var noteSection: some View {
        Text("리사이징 예제와 같은 350 × 437px 결과를 ImageIO로 만듭니다. 이 화면은 전후 비교를 위해 원본을 먼저 보여주며, 실제 팝팡 카드에서는 네트워크 Data를 바로 다운샘플링합니다.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    ContentView()
}
