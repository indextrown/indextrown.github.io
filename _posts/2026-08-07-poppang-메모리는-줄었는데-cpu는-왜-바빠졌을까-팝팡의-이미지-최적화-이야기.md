---
title: "[작성중 PopPang] 메모리는 줄었는데 CPU는 왜 바빠졌을까? 팝팡의 이미지 최적화 이야기"
date: 2026-08-07
tags: []
---

#### Pixel

- 디지털 이미지는 작은 점인 **Pixel(Picture Element)**의 집합으로 표현됩니다.
- pixel의 색상은 보통 RGBA(Red, Green, Blue, Alpha)라는 채널로 표현합니다. 
- 각 채널을 8bit로 표현하는 일반적인 RGBA 이미지에서는 각 채널이 0\~255 사이의 숫자로 표현됩니다.
- 즉 8bit RGBA 기준 하나의 픽셀은 1byte(=8bit) x 4 = 4byte 크기의 메모리를 사용합니다.
- 참고: 모든 이미지의 픽셀이 항상 4byte는 아닙니다. RGB, grayscale, 16bit 채널 등 픽셀 포맷에 따라 달라질 수 있습니다.

#### JPG

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

&nbsp;

이미지를 렌더링 하기 위해서는 압축된 JPEG/PNG 형식을 디코딩하여 pixel 데이터로 준비해야 합니다.   
팝팡은 서버에서 2250 × 2812(6,327,000 pixels) 해상도의 이미지를 받아왔습니다. 그런데 CollectionView에서 실제 표시 크기는 150 \* 150만 필요했습니다.

기존에는 원본 해상도를 그대로 디코딩하려고 했기 때문에 2250 × 2812 x 4byte = 25,308,000byte, 즉 이미지 하나가 약 **25.3MB**, MiB 기준으로는 약 **24.1MiB**의 메모리가 요구되었습니다.

&nbsp;

```bash
원본
2250 × 2812 JPEG
(압축 데이터)

        ↓ ImageIO

작은 크기의 CGImage
(Thumbnail)

        ↓ Decode / backing store 준비

작은 Pixel Buffer

        ↓

UIImage
```

이를 해결하기 위해 WWDC를 참고해서 팝팡에서는 아래 두 가지 전략을 활용했습니다.

- Prefetching으로 셀이 등장하기 전에 앞으로 필요한 이미지의 준비 작업을 미리 시작하여, 스크롤 시점에 CPU 작업이 집중되는 것을 줄입니다.
- 백그라운드에서 원본 이미지를(JPEG) 필요한 크기로 **Downsampling**하고(CGImage확장자), 축소된 이미지를 **Decode**하여(Pixel확장자) 화면에 바로 표시할 수 있는 상태로 준비합니다.

&nbsp;

#### Prefetching: 무거운 작업을 셀이 등장하기 전에 미리 시작

```bash
현재 화면

[1]
[2]
[3]
[4]  ← 현재

[5]  ← 미리 준비 시작
[6]  ← 미리 준비 시작
[7]  ← 미리 준비 시작
[8]  ← 미리 준비 시작
```

앞으로 필요할 데이터를 미리 준비하는 방식입니다.

&nbsp;

```swift
UICollectionViewDataSourcePrefetching

func collectionView(
    _ collectionView: UICollectionView,
    prefetchItemsAt indexPaths: [IndexPath]
)
```

 `prefetchItemsAt`은 앞으로 필요할 가능성이 있는 index path의 데이터를 미리 준비하도록 알려주고, 필요 없어진 작업은 `cancelPrefetchingForItemsAt`에서 취소할 수 있습니다.

중요한 점은 Prefetching 자체가 이미지를 디코딩 해주는 것은 아니고 **곧 필요할 것 같으니까 지금부터 작업 시작해라는 delegate 이벤트만 전달해주는 메서드**입니다.

&nbsp;

#### Background Downsample / Decode: 이미지 준비 작업을 메인 스레드에서 피하자

```bash
Main Thread
───────────────────────────────
Cell 생성               UIImage 설정
   │                         ▲
   │                         │
   └──── Background ─────────┘
          Decode
        Downsample
```

그림처럼 디코딩과 다운샘플링을 백그라운드에서 처리할 수 있습니다.

&nbsp;

```bash
// gcd ver
image.prepareThumbnail(of: size) { thumbnail in
    ...
}

// swift concurrency ver
let thumbnail = await image.byPreparingThumbnail(ofSize: size)

// 참고: 동기 API 버전
let thumbnail = image.preparingThumbnail(of: CGSize(width: 300, height: 300))
```

애플은 iOS 15부터 위 API를 제공합니다. 비동기 prepareThumbnail은 thumbnail 생성을 백그라운드에서 수행합니다. Apple은 비동기 Image preparation API가 내부 UIKit Queue에서 처리한다고 설명합니다. [공식문서](https://developer.apple.com/documentation/uikit/uiimage/preparethumbnail(of:completionhandler:)?changes=__3)

&nbsp;

#### 방법 1 + 2 같이 사용하면

```bash
                    화면 밖
                      │
                Prefetch 발생
                      │
                      ▼
                 Download
                      │
                      ▼
         Background Decode
              + Downsample
                      │
                      ▼
                    Cache
                      │
──────────────────────┼────────────
                      │
                  Cell 등장
                      │
                      ▼
                  Cache Hit
                      │
                      ▼
                   Display
```

Apple도 WWDC21에서 **prefetching이 다운로드와 image preparation에 더 많은 시간을 제공한다**고 설명하고, 최종적으로 prefetching + image preparation(비동기 다운샘플링 + 비동기 디코딩 작업)을 함께 사용하는 구조를 보여줍니다. [WWDC](https://developer.apple.com/videos/play/wwdc2021/10252/?time=915)

&nbsp;

#### iOS 17

SwiftUI iOS 17에서는 `onScrollTargetVisibilityChange` 를 사용할 수 없어 최선의 방식은 현재 index를 확인하고 index + 1... index + N 데이터를 Prefetch하는 휴리스틱 방안이 있습니다.

#### iOS 18+

SwiftUI iOS 18+에서는 `onScrollTargetVisibilityChange` 를 사용가능해 `scrollTargetLayout()`과 함께 현재 visible target ID들을 관찰할 수 있습니다. [공식문서](https://developer.apple.com/documentation/swiftui/view/onscrolltargetvisibilitychange%28idtype%3Athreshold%3A_%3A%29?changes=_1__6&language=objc&utm_source=chatgpt.com) 따라서 화면에 보이는 마지막 셀의 index를 알고 그다음 인덱스들을 prefetch할 수 있습니다. 실제 이미지 로드는 `.task(id: photo.id)` 를 이용할 수 있습니다. SwiftUI는 View가 사라지거나 바뀌면 `.task(id:)` 작업을 취소/재시작할 수 있습니다.

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

---

&nbsp;

&nbsp;

Apple WWDC21에서 아래 두가지 방법을 함께 사용하는 것을 권장합니다.

- Data Source Prefetching으로 필요한 이미지를 미리 디코딩하여 CPU 사용량을 분산
- 백그라운드에서 디코딩/다운샘플링을 시도할 수 있습니다.

&nbsp;

JPEG/PNG/HEIC 같은 이미지는 압축된 상태입니다. 실제 호면에 표시하려면 raw pixel 데이터가 필요합니다. Apple은 이미지가 `UIImageView`에 표시되는 시점까지 준비되지 않았다면 display commit 과정에서 이미지 준비가 메인 스레드 작업을 길게 만들 수 있다고 설명합니다.

&nbsp;

## 문제 예시

```bash
원본 이미지
4000 × 3000

↓ CollectionView

셀
150 × 150
```

예를 들어 위처럼 원본 전체를 디코딩 하는것은 낭비입니다.

&nbsp;

```bash
4000 × 3000 JPEG
        ↓
   Downsample
        ↓
   150 × 150 Bitmap
```

그래서 다운샘플링을 하는 것이 좋습니다. UIImage의 thumbnail API는 원본 크기 전체를 디코딩하는 메모리 오버헤드를 피하도록 제공합니다.

&nbsp;

```bash
스크롤
 ↓
새 셀 1 등장 → Decode
새 셀 2 등장 → Decode
새 셀 3 등장 → Decode
새 셀 4 등장 → Decode
                ↑
           CPU 작업 집중
```

하지만 여전히 문제가 있습니다. 매번 셀이 보일때마다 무거운 디코딩 과정을 해야하기 때문에 무겁습니다.

&nbsp;

## 두가지 해결 전략

#### 뱡법1: Prefetching

```swift
UICollectionViewDataSourcePrefetching
```

앞으로 필요할 데이터를 미리 준비하는 방식입니다. UIKit에서는 `UICollectionViewDataSourcePrefetching`으로 이를 적용할 수 있습니다. `prefetchItemsAt`은 앞으로 필요할 가능성이 있는 index path의 데이터를 미리 준비하도록 알려주고, 필요 없어진 작업은 `cancelPrefetchingForItemsAt`에서 취소할 수 있습니다.

&nbsp;

```bash
현재 화면

[1]
[2]
[3]
[4]  ← 현재

[5]  ← 미리 준비
[6]  ← 미리 준비
[7]  ← 미리 준비
[8]  ← 미리 준비
```

중요한 점은 Prefetching 자체가 이미지를 디코딩 해주는 것은 아니고 **곧 필요할 것 같으니까 지금부터 준비 시작을 위한 delegate 이벤트만 전달해주는 메서드**입니다.

&nbsp;

#### 방법2: Background Decode / Downsample

```bash
// gcd ver
image.prepareThumbnail(of: size) { thumbnail in
    ...
}

// swift concurrency ver
let thumbnail = await image.byPreparingThumbnail(ofSize: size)
```

애플은 iOS 15부터 위 API를 제공합니다. 비동기 prepareThumbnail은 thumbnail 생성을 백그라운드에서 수행합니다. Apple은 비동기 Image preparation API가 내부 UIKit Queue에서 처리한다고 설명합니다. [공식문서](https://developer.apple.com/documentation/uikit/uiimage/preparethumbnail(of:completionhandler:)?changes=__3)

&nbsp;

```bash
Main Thread
───────────────────────────────
Cell 생성               UIImage 설정
   │                         ▲
   │                         │
   └──── Background ─────────┘
          Decode
        Downsample
```

2번 방식은 이런 그림처럼 디코딩과 다운샘플링을 백그라운드에서 처리할 수 있습니다.

&nbsp;

#### 방법 1 + 2 같이 사용하면

```bash
                    화면 밖
                      │
                Prefetch 발생
                      │
                      ▼
                 Download
                      │
                      ▼
         Background Decode
              + Downsample
                      │
                      ▼
                    Cache
                      │
──────────────────────┼────────────
                      │
                  Cell 등장
                      │
                      ▼
                  Cache Hit
                      │
                      ▼
                   Display
```

Apple도 WWDC21에서 **prefetching이 다운로드와 image preparation에 더 많은 시간을 제공한다**고 설명하고, 최종적으로 prefetching + image preparation을 함께 사용하는 구조를 보여줍니다. [WWDC](https://developer.apple.com/videos/play/wwdc2021/10252/?time=915)

&nbsp;

&nbsp;