# ImageMemorySample

팝팡 팝업 원본 이미지를 전체 해상도로 표시하며, JPEG 파일 크기와 화면 표시용 픽셀 버퍼의 메모리 차이를 확인하는 SwiftUI 샘플입니다.

## 실행

1. Xcode에서 `ImageMemorySample.xcodeproj`를 엽니다.
2. iOS 17 이상 시뮬레이터 또는 기기에서 실행합니다.
3. 이미지가 나타난 뒤 Xcode의 Debug navigator 메모리 게이지 또는 Instruments > Allocations를 확인합니다.

## 계산 기준

- JPEG 파일 크기: 약 1.2 MB
- 원본 이미지: 2250 × 2812 pixel
- 디코딩 가정: 8-bit RGBA, pixel당 4 byte
- 예상 픽셀 버퍼: `2250 × 2812 × 4 = 25,308,000 byte` ≈ `24.14 MiB`

파일 용량은 압축된 네트워크 전송량이고, 화면 표시 시에는 압축을 푼 픽셀 데이터가 필요합니다. 이 샘플은 `UIImage.preparingForDisplay()`를 사용해 원본을 화면 표시용으로 준비한 뒤 `Image(uiImage:)`에 전달합니다. `scaledToFit()`은 화면의 표시 크기만 줄이며 원본 픽셀 버퍼 자체를 다운샘플링하지 않습니다.

실제 앱의 총 메모리 사용량은 이 계산값보다 커질 수 있습니다. `bytesPerRow`의 정렬, 이미지 캐시, Core Animation의 렌더링 표면 등이 추가되기 때문입니다.
