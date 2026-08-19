---
title: "[작성중] 팝팡의 이미지 최적화: 다운샘플링으로 메모리와 CPU 피크 줄이기"
date: 2026-08-07
tags: []
---

<details class="notion-toggle-list" markdown="1">
<summary>사전 지식</summary>

#### Pixel

- 디지털 이미지는 작은 점인 **Pixel(Picture Element)**의 집합으로 표현됩니다.
- pixel의 색상은 보통 RGBA(Red, Green, Blue, Alpha)라는 채널로 표현합니다. 
- 각 채널을 8bit로 표현하는 일반적인 RGBA 이미지에서는 각 채널이 0\~255 사이의 숫자로 표현됩니다.
- 즉 8bit RGBA 기준 하나의 픽셀은 1byte(=8bit) x 4 = 4byte 크기의 메모리를 사용합니다.
- 참고: 모든 이미지의 픽셀이 항상 4byte는 아닙니다. RGB, grayscale, 16bit 채널 등 픽셀 포맷에 따라 달라질 수 있습니다.JPG
- JPEG는 **픽셀로 표현되는 래스터(Raster) 이미지 포맷**입니다.
- 압축 방식: 손실 압축 방식(Lossy Compression)을 사용해 사람 눈에 덜 보이는 정보를 버리고 용량을 줄입니다. 
- 장점: 색상 변화가 많은 이미지에서 높은 압축 효율로 파일 크기가 상대적으로 작아집니다.
- 단점: 투명도(알파 채널)를 지원하지 않고 압축 과정에서 일부 이미지 정보가 손실되어 반복 저장 시 화질이 저하될 수 있습니다.

#### PNG

- jpg와 동일하게 **픽셀로 표현되는 래스터(Raster) 이미지 포맷**입니다.
- 압축 방식: 무손실 압축 방식(Lossless Compression)을 사용해 원본 데이터를 보존하면서 압축합니다.
- 장점: 압축과 복원을 반복해도 원본 데이터 유지, 투명도 지원, 아이콘처럼 경계가 뚜렷한 이미지에 적합합니다.
- 단점: 파일 크기가 JPEG보가 큽니다.

#### Vector Image

- 이미지를 픽셀의 집합으로 저장하는 대신 **점, 선, 곡선, 도형 등의 수학적 정보**로 표현합니다.
- 이미지를 확대하거나 축소해도 픽셀이 깨지는 현상이 발생하지 않습니다.
- 대표적인 포맷으로는 SVG, PDF, iOS 개발에서는 주로 아이콘이나 일러스트 같은 다양한 크기 표현 이미지에 사용됩니다.

#### HEIF / HEIC (High Efficiency Image Format)

- 고효율 이미지 저장을 위한 파일 포맷입니다.
- Apple은 iOS 11부터 사진 저장 포맷으로 HEIF를 지원하며, Apple 기기에서 생성되는 HEIF 이미지에는  
일반적으로 `.heic` 확장자가 사용됩니다.
- 압축 방식: HEVC(H.265) 기반 압축을 하여 JPG보다 50% 이상 용량 절감이 가능합니다.  
동일하거나 비슷한 화질을 기준으로 JPEG보다 더 작은 파일 크기를 만들 수 있어 높은 압축 효율을 제공합니다.
- 장점: 
  - JPEG보다 높은 압축 효율
  - 작은 파일 크기로 높은 화질 유지 가능
  - Alpha Channel 지원 가능
  - 여러 이미지 및 이미지 시퀀스 저장 가능
  - HDR 등의 다양한 이미지 정보 저장 가능
- 단점: 
  - JPEG나 PNG에 비해 플랫폼 및 프로그램 호환성이 떨어질 수 있음
  - 호환성이 필요한 환경에서는 JPEG나 PNG 등으로 변환해야 할 수 있음
</details>





&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/pasted-image-20260809T081939-2.png)

팝팡의 화면은 많은 팝업 이미지를 보여줍니다. 처음에는 이미지가 많으니 메모리 사용량도 늘겠거니 생각했습니다. 하지만 화면을 넘길수록 이미지가 누적되고, 프로세스 메모리가 GB 단위까지 커지는 상황을 확인하면서 이미지 메모리 최적화가 필요하다는 것을 알게 되었습니다.

디코드된 이미지 한 장이 25MB라면 화면에 여러 장이 보이는 것만으로도 메모리는 빠르게 늘어납니다. 스크롤하면서 새로운 이미지를 계속 준비하면 메모리 부족으로 앱이 종료될 수도 있습니다. 따라서 단순히 이미지 파일을 내려받는 것에 그치지 않고, 화면에 필요한 크기로 이미지를 다뤄야 합니다.

문제는 이미지 한 장이 실제로 얼마나 많은 메모리를 사용하는지, 어느 크기까지 줄여도 되는지 기준이 없었다는 점입니다. 이미지 처리 과정을 제대로 이해하기 위해 WWDC 내용을 공부했고, 팝팡에 적용한 방식과 함께 이 글에 정리했습니다.



&nbsp;

![exec-59137e69-509c-400d-9de4-12b5c6a9d706](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/exec-59137e69-509c-400d-9de4-12b5c6a9d706-2.png)

가로 2250, 세로 2812 픽셀의 이미지가 있고 이 이미지 파일의 용량은 1.2MB입니다. 하지만 이 이미지가 iOS 메모리에 올라갈 때는 얼마나 사용될까요? 무려 25MB를 사용하게 됩니다. 만약 이미지가 10개가 보인다면 250MB가 보이게 되는 것입니다.

&nbsp;

#### 이미지를 렌더링 하는 과정은 3단계로 동작합니다.

![팝업 이미지의 Load, Decode, Render 과정](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/poppang-image-rendering-flow.png)

1. Load: JPEG 이미지를 메모리에 불러옵니다.
2. Decode: 이미지 데이터를 픽셀당 정보로 변환하는 작업으로 CPU를 많이 사용하고 메모리 할당과 해제가   
지속적으로 발생할 수 있습니다.
3. Render: 디코딩된 이미지 데이터를 렌더링합니다.



&nbsp;

![SwiftUI 이미지 렌더링 파이프라인](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/swiftui-image-buffer-rendering-pipeline.png)

조금 더 깊게 들어가기위해 Data Buffer, Image Buffer, Frame Buffer를 이해하는게 좋습니다.

**Data Buffer**에는 JPEG, PNG처럼 인코딩된 이미지 바이트와 메타데이터가 들어 있습니다. 압축된 파일이므로 이 단계의 크기는 파일 용량과 가깝습니다. 다만 렌더러는 이 바이트를 그대로 픽셀로 그릴 수 없습니다. Decode는 인코딩된 바이트를 픽셀별 색상과 투명도 정보로 푸는 작업입니다.

**Image Buffer**에는 디코딩된 픽셀 정보가 들어 있습니다. 버퍼 크기는 이미지의 가로·세로 픽셀 수에 비례합니다. 일반적인 8비트 RGBA 또는 BGRA 포맷은 픽셀당 4바이트를 사용합니다. 렌더러는 이 버퍼를 샘플링해 화면의 일부에 이미지를 그립니다.

**Frame Buffer**에는 앱이 한 프레임 동안 화면에 실제로 렌더링한 최종 픽셀 결과가 들어 있습니다. Image Buffer가 원본 이미지의 디코딩된 픽셀을 담는다면, Frame Buffer는 이미지·텍스트·배경처럼 화면 전체를 합친 출력 표면입니다. 그림의 작은 색 영역은 Image Buffer의 픽셀이 최종 화면에서 차지하는 위치를 나타냅니다. 작은 색 영역만 Frame Buffer인 것이 아니라, 큰 사각형 전체가 Frame Buffer입니다.

SwiftUI의 상태가 바뀌면 View를 다시 계산하고, 시스템이 변경된 화면을 새 프레임으로 렌더링합니다. 시스템 컴포지터는 이 결과를 다른 화면 요소와 합성해 디스플레이에 전달합니다. 디스플레이는 기기 주사율에 맞춰 프레임을 표시합니다. 예를 들어 60Hz 기기는 약 16.67ms마다, 120Hz 기기는 약 8.33ms마다 새 프레임을 표시할 수 있습니다. 화면에 변경 사항이 없으면 같은 프레임을 계속 표시하므로, 매 표시 주기마다 앱이 화면 전체를 다시 그릴 필요는 없습니다.

블러, 마스크, 투명도 그룹처럼 한 번에 합성하기 어려운 효과는 GPU가 중간 결과를 담을 render target을 추가로 만들 수 있습니다. 이 표면은 화면 크기에 가까울 수 있어 메모리와 GPU 대역폭을 함께 사용합니다.

> 엄밀히 말하면 SwiftUI 앱이 물리 디스플레이의 프레임 버퍼를 직접 소유하지는 않습니다. Core Animation과 GPU가 시스템 관리 렌더링 표면을 통해 최종 화면을 합성합니다. 이 글에서는 WWDC의 설명 방식을 따라 이 최종 출력 표면을 Frame Buffer라고 부릅니다.



&nbsp;

## 기존 팝팡 문제점

```swift
extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let newSize = CGSize(width: newWidth, height: newHeight)
        let resized = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = resized.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }

        printData(resizedImage)
        return resizedImage
    }

}
```

![붙여넣은 이미지](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/pasted-image-20260809T095619.png)

처음에는 `UIGraphicsImageRenderer`로 이미지를 줄였습니다. 화면에 남는 이미지 버퍼는 작아졌지만, `draw(in:)`은 먼저 원본 JPEG 전체를 디코드합니다.

원본 버퍼를 만든 뒤 축소본을 다시 그리므로 CPU와 임시 메모리가 한 번에 올라갑니다. 최종 이미지가 작아져도 **디코딩 CPU 피크는 줄지 않았습니다.**



&nbsp;

## 해결 방법 1: ImageIO 다운샘플링으로 CPU 피크 줄이기

![붙여넣은 이미지](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/pasted-image-20260809T092949-2.png)

`PopupPaginationImageIOPipeline`은 서버에서 받은 `Data`로 `CGImageSource`를 만들고, 화면 크기에 맞는 썸네일을 요청합니다. 원본을 `UIImage`로 먼저 만들지 않고 필요한 크기만 디코드하는 방식입니다. [WWDC18 iOS Memory Deep Dive](https://developer.apple.com/videos/play/wwdc2018/416/)

```swift
import ImageIO
import UIKit

extension UIImage {
    /// 화면에 표시할 크기에 맞춰 ImageIO에서 바로 다운샘플링합니다.
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
}
```

![붙여넣은 이미지](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/pasted-image-20260809T095714-2.png)

원본이 `2250 × 2812px`라면 약 `24.14MiB`가 필요하지만, 화면 크기에 맞춘 결과는 훨씬 작습니다. 리사이징과 다운샘플링이 같은 크기의 결과를 만들면 최종 버퍼 크기는 같지만, 다운샘플링은 원본 전체 디코드를 피하므로 CPU 피크와 순간 메모리 사용량을 줄입니다.



&nbsp;

## 해결 방법 2: 프리패칭으로 이미지 작업(다운샘플링과 디코딩) 앞당기기

![스크롤 중 이미지 디코딩으로 발생하는 CPU 부하](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/poppang-scroll-decoding-problem.png)

스크롤 위치와 화면 높이로 다음에 보일 카드 URL을 계산합니다. 화면의 약 1.25배 앞까지 같은 이미지 파이프라인에 미리 요청해, 셀이 보이기 전에 다운로드와 이미지 준비를 시작합니다.

&nbsp;

## 해결 방법 3: 다운샘플링과 디코딩은 백그라운드에서 처리

![프리패칭과 백그라운드 디코딩 타임라인](/assets/img/2026-08-07-poppang-메모리는-줄었는데-cpu는-왜-바빠졌을까-팝팡의-이미지-최적화-이야기/poppang-background-decoding-timeline.png)

WWDC 예제는 디코딩을 직렬 큐에서 하나씩 처리합니다. 여러 작업이 동시에 독립적인 스레드를 만들며 시스템을 압박하는 상황을 피하기 위한 선택입니다.

팝팡은 Swift Concurrency로 구현했습니다. `Task`는 OS 스레드와 1:1로 대응하지 않고, Swift 런타임의 협력적 스레드 풀에서 실행됩니다. 그래서 직렬 큐로 모든 디코드를 한 줄로 세우는 대신, `TaskGroup`에서 이미지 준비 작업을 최대 10개까지만 실행해 동시 작업량을 제한했습니다.

`actor`는 대기열, 캐시, 중복 요청 같은 공유 상태만 보호합니다. 다운샘플링과 디코딩은 메인 액터 밖에서 실행하고, 준비된 이미지를 화면에 반영할 때만 `MainActor`로 돌아옵니다. 완성된 이미지는 URL별로 최대 36장까지 캐시합니다.

&nbsp;

## 마무리

이미지 최적화에서 먼저 봐야 할 값은 압축 파일 크기가 아니라 디코드된 픽셀 버퍼의 크기입니다. 화면에 작은 썸네일만 필요하다면 원본 크기 전체를 디코드할 이유가 없습니다.

팝팡은 세 단계로 이 비용을 줄였습니다.

1. ImageIO 다운샘플링으로 필요한 크기만 디코드합니다.
2. 프리패칭으로 이미지 준비 시점을 스크롤보다 앞당깁니다.
3. 제한된 수의 백그라운드 작업으로 준비하고, 메인 스레드는 화면 갱신에만 사용합니다.

이 방식이 이미지 메모리를 없애는 것은 아닙니다. 대신 필요한 크기의 이미지 버퍼만 유지하고, 스크롤 순간에 CPU 작업이 몰리지 않도록 제어합니다. 앞으로도 이미지 표시 크기, 캐시 개수, 동시 작업 수를 함께 관찰하면서 화면별 기준을 조정할 예정입니다.



