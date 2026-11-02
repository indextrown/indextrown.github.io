---
title: "[Mapbox] Custom Layer 딥다이브 - 셰이더 처음부터 지도 위 삼각형까지"
date: 2026-11-02
tags:
  - Mapbox
---

[이전 글]({% post_url 2026-11-02-mapbox-basic-concepts %})에서 Mapbox로 지도에 무언가를 그리는 5가지 방법을 소개했습니다. 이번 글은 그중 가장 저수준인 **Custom Layer**를 처음부터 끝까지 파고들어 보겠습니다.

Custom Layer 공식 예제를 열어보면 `MTLDevice`, `shader`, `pipeline`, `projectionMatrix`, `clip space` 같은 단어가 쏟아집니다. 지도 SDK 글인데 갑자기 3D 그래픽스 용어가 나오는 이유는, Custom Layer가 **Mapbox가 지도를 그리는 GPU 작업 한가운데에 내 그래픽 코드를 끼워 넣는 기능**이기 때문입니다.

그래서 이 글은 Mapbox 이야기를 하기 전에 그래픽스 기초부터 순서대로 쌓아 올립니다.

**Part 1. 그래픽스 기초**

1. CPU와 GPU - 왜 GPU에게 그림을 맡길까
2. 모든 것은 삼각형이다
3. 렌더링 파이프라인
4. 셰이더란 무엇인가
5. 좌표의 여정과 행렬
6. Metal의 핵심 객체들

**Part 2. Mapbox Custom Layer 해부**

7. CustomLayer와 CustomLayerHost
8. 생명주기 - renderingWillStart, render, renderingWillEnd
9. CustomLayerRenderParameters - 매 프레임 받는 카메라 정보
{: start="7"}

**Part 3. 예제**

10. 예제 1 - 서울, 부산, 광주를 잇는 삼각형
11. 예제 2 - 시간에 따라 깜빡이는 삼각형 (uniform, triggerRepaint)
12. 예제 3 - 공식 예제 읽기 (미터 단위 3D 큐브, Globe)
13. 아무것도 안 보일 때 체크리스트
{: start="10"}

> 이 글은 **Mapbox Maps SDK for iOS v11** 기준입니다. (소스 기준 11.34 ~ 11.35) `CustomLayer`는 `@_spi(Experimental)`로 표시된 실험적 API라 이후 버전에서 바뀔 수 있습니다.

&nbsp;

---

&nbsp;

# Part 1. 그래픽스 기초

## 1. CPU와 GPU - 왜 GPU에게 그림을 맡길까

아이폰 화면은 수백만 개의 픽셀로 이루어져 있고, 120Hz 화면이라면 1초에 120번 이 픽셀 전부의 색을 다시 정해야 합니다. 1초에 수억 번의 "이 픽셀은 무슨 색?" 계산이 필요한 셈입니다.

| | CPU | GPU |
| --- | --- | --- |
| 코어 | 소수의 똑똑한 코어 | 수천 개의 단순한 코어 |
| 잘하는 일 | 복잡한 분기, 순서가 중요한 로직 | 똑같은 계산을 엄청나게 많이, 동시에 |
| 비유 | 박사 몇 명 | 계산만 하는 초등학생 수천 명 |

픽셀 색 계산은 "같은 공식을 픽셀마다 반복"하는 일이라 GPU에 딱 맞습니다. 그래서 그림 그리기는 GPU에게 맡기고, CPU는 **GPU에게 일을 시키는 명령서**를 작성하는 역할을 합니다.

GPU에게 명령을 내리는 방법을 표준화한 것이 **그래픽스 API**입니다. OpenGL, Vulkan, DirectX 등이 있고, Apple 플랫폼에서는 **Metal**을 사용합니다. Mapbox iOS SDK도 내부적으로 Metal로 지도를 그리고, Custom Layer 역시 Metal 코드를 직접 작성하는 방식입니다.

&nbsp;

## 2. 모든 것은 삼각형이다

GPU가 직접 그릴 수 있는 도형(primitive)은 딱 세 가지입니다.

<img src="/assets/img/2026-11-02-mapbox-custom-layer-deep-dive/primitives.svg" alt="GPU primitive" style="width: 100%;">

- **점(point)**, **선(line)**, **삼각형(triangle)**
- 사각형은 삼각형 2개, 원은 삼각형 여러 개를 이어 붙여서 만듭니다.
- 3D 큐브는 면 6개 × 삼각형 2개 = **삼각형 12개**, 꼭짓점으로 세면 12 × 3 = **36개**입니다.

이때 각 꼭짓점을 **정점(vertex)** 이라고 부릅니다. 정점은 위치뿐 아니라 색, 텍스처 좌표 같은 정보를 함께 가질 수 있습니다.

> 이전 글의 GeoJSON Geometry(Point, LineString, Polygon)와 비슷하다고 느꼈다면 정확합니다. Mapbox의 fill Layer도 내부적으로 Polygon을 삼각형으로 쪼개서(triangulation) GPU에 넘깁니다.

&nbsp;

## 3. 렌더링 파이프라인

정점 데이터가 화면의 픽셀이 되기까지 GPU는 정해진 단계를 차례로 거칩니다. 이 흐름을 **렌더링 파이프라인**이라고 합니다.

<img src="/assets/img/2026-11-02-mapbox-custom-layer-deep-dive/render-pipeline.svg" alt="렌더링 파이프라인" style="width: 100%;">

| 단계 | 하는 일 | 누가 |
| --- | --- | --- |
| ① Vertex 데이터 | 정점 좌표와 색을 GPU 메모리(`MTLBuffer`)에 올림 | 내가 (Swift) |
| ② Vertex Shader | 정점마다 실행되어 **화면 어디에 놓일지** 계산 | 내가 (셰이더) |
| ③ Rasterizer | 삼각형이 덮는 픽셀들을 찾고, 정점 사이 값을 보간 | GPU 자동 |
| ④ Fragment Shader | 픽셀마다 실행되어 **무슨 색일지** 계산 | 내가 (셰이더) |
| ⑤ 출력 병합 | 깊이 테스트, 블렌딩 후 최종 픽셀에 기록 | GPU (설정으로 제어) |

핵심은 **②와 ④만 내가 프로그래밍하고, 나머지는 GPU가 알아서** 한다는 점입니다.

③ Rasterizer의 **보간(interpolation)** 도 기억해 두면 좋습니다. 정점 3개에 빨강, 파랑, 초록을 주면 삼각형 내부 픽셀은 거리에 따라 색이 섞인 그라데이션이 됩니다. 정점 3개에만 값을 줬는데 수천 개 픽셀의 값이 자동으로 채워지는 것입니다.

&nbsp;

## 4. 셰이더란 무엇인가

**셰이더(Shader)** 는 GPU에서 실행되는 작은 함수입니다. 이름은 "음영(shade)을 계산한다"에서 왔지만, 지금은 GPU에서 돌아가는 프로그램 전반을 부르는 말입니다.

Metal에서는 **MSL(Metal Shading Language)** 이라는 C++ 기반 언어로 작성하고, `.metal` 파일에 넣으면 Xcode가 빌드할 때 함께 컴파일해줍니다.

```cpp
#include <metal_stdlib>
using namespace metal;

// Vertex Shader와 Fragment Shader 사이에서 전달되는 데이터
struct RasterizerData {
    float4 position [[position]]; // 이 정점의 clip space 위치 (필수)
    float4 color;                 // Rasterizer가 픽셀마다 보간해서 넘겨줌
};

// ② 정점마다 1번 실행
vertex RasterizerData myVertex(uint vertexID [[vertex_id]],
                               constant float2 *positions [[buffer(0)]]) {
    RasterizerData out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.color = float4(1.0, 0.5, 0.0, 1.0);
    return out;
}

// ④ 픽셀마다 1번 실행
fragment float4 myFragment(RasterizerData in [[stage_in]]) {
    return in.color; // 이 픽셀의 색 (r, g, b, a)
}
```

처음 보면 낯선 문법이 몇 가지 있습니다.

| 문법 | 의미 |
| --- | --- |
| `vertex`, `fragment` | 이 함수가 어떤 셰이더인지 표시 |
| `float2`, `float4`, `float4x4` | 벡터, 행렬 타입. Swift의 `SIMD2<Float>`, `SIMD4<Float>`, `simd_float4x4`에 대응 |
| `[[vertex_id]]` | 지금 처리 중인 정점의 번호 (0, 1, 2, ...) |
| `[[buffer(0)]]` | Swift에서 `setVertexBuffer(_, index: 0)`으로 넘긴 데이터 |
| `[[position]]` | 이 값이 정점의 최종 위치라고 GPU에게 알려줌 |
| `[[stage_in]]` | Rasterizer가 보간해서 넘겨준 데이터 |
| `constant` | 읽기 전용 GPU 메모리 공간 |

Swift 코드와 셰이더는 **`[[buffer(n)]]`의 번호로 연결**된다는 점이 가장 중요합니다. Swift에서 `index: 1`로 넘긴 데이터는 셰이더의 `[[buffer(1)]]` 파라미터로 들어옵니다.

### uniform - 모든 정점이 공유하는 값

정점마다 다른 값(위치, 색)과 달리 **모든 정점과 픽셀이 똑같이 사용하는 값**도 있습니다. 카메라 행렬, 현재 시간 같은 것들입니다. 그래픽스에서는 이런 값을 **uniform**이라고 부릅니다. Metal에서는 별도 문법 없이 버퍼로 넘기지만, 개념상 구분해 두면 공식 예제의 `GlobeUniforms`, `u_matrix` 같은 이름을 읽을 때 도움이 됩니다.

&nbsp;

## 5. 좌표의 여정과 행렬

Vertex Shader가 해야 할 일은 결국 "이 정점이 화면 어디에 있는가"를 계산하는 것입니다. 지도에서는 이 계산이 꽤 긴 여정을 거칩니다.

<img src="/assets/img/2026-11-02-mapbox-custom-layer-deep-dive/coordinates.svg" alt="좌표의 여정" style="width: 100%;">

### ① 위경도 → Mercator (0 ~ 1)

지구는 둥글지만 화면은 평평합니다. 둥근 지구를 평면에 펼치는 방법을 **투영(projection)** 이라고 하고, 웹 지도는 대부분 **Web Mercator** 투영을 사용합니다.

Mapbox는 전 세계를 가로, 세로 0 ~ 1인 정사각형으로 펼친 Mercator 좌표를 사용합니다. 왼쪽 위가 (0, 0), 오른쪽 아래가 (1, 1)입니다.

```swift
let mercator = Projection.latLngToMercatorXY(coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780))
// mercator.x ≈ 0.8527, mercator.y ≈ 0.3873
```

이 값은 카메라와 상관없이 고정이므로 **한 번만 계산**해두면 됩니다.

### ② Mercator → World 좌표 (픽셀)

줌 레벨에 따라 전 세계 지도의 크기가 달라집니다. 줌 0에서 전 세계는 512 × 512 크기이고, 줌이 1 올라갈 때마다 2배씩 커집니다.

```swift
let worldSize = Projection.worldSize(scale: pow(2, zoom)) // 512 × 2^zoom
let worldX = mercator.x * worldSize
```

이 "World 좌표"가 Mapbox가 넘겨주는 `projectionMatrix`가 기대하는 입력입니다.

### ③ World → Clip space (-1 ~ 1)

GPU는 화면 크기를 모릅니다. 대신 **Clip space**라는 표준 공간을 사용합니다. x, y가 -1 ~ 1 범위 안에 들어온 점만 화면에 보이고, 밖으로 벗어난 점은 잘려나갑니다(clip). Vertex Shader의 출력인 `[[position]]`이 바로 이 Clip space 좌표입니다.

World 좌표를 Clip space로 바꾸려면 카메라 위치, 회전(bearing), 기울기(pitch), 시야각(field of view)을 모두 반영해야 합니다. 이 복잡한 계산은 **Mapbox가 매 프레임 `projectionMatrix`로 만들어서 넘겨줍니다.** 우리는 곱하기만 하면 됩니다.

### ④ Clip space → 화면 픽셀

마지막 변환은 GPU가 Viewport 설정을 보고 자동으로 처리합니다.

### 왜 행렬일까 - MVP

위 변환들을 매번 따로 계산하는 대신, 그래픽스에서는 각 변환을 **4×4 행렬**로 표현하고 곱해서 하나로 합칩니다.

| 행렬 | 역할 | 이 글에서 |
| --- | --- | --- |
| **M**odel | 물체 자신의 좌표 → World 좌표 (이동, 회전, 크기) | `× worldSize` 스케일 행렬 |
| **V**iew | World → 카메라 기준 좌표 | Mapbox `projectionMatrix`에 포함 |
| **P**rojection | 카메라 기준 → Clip space (원근감) | Mapbox `projectionMatrix`에 포함 |

```text
clipPosition = Projection × View × Model × vertexPosition
             = projectionMatrix × modelMatrix × vertexPosition
```

여기서 두 가지를 짚고 넘어가겠습니다.

- **왜 4×4일까?** 3D 좌표 (x, y, z)에 1을 붙여 (x, y, z, 1)로 만들면 이동(translation)까지 행렬 곱 하나로 표현할 수 있습니다. 이 네 번째 값을 `w`라고 하며, 이런 좌표를 **동차 좌표(homogeneous coordinates)** 라고 합니다. 셰이더에서 `float4(position, 0.0, 1.0)`처럼 마지막에 1을 붙이는 이유입니다.
- **곱하는 순서가 중요합니다.** 행렬 곱은 교환법칙이 성립하지 않습니다. 오른쪽부터 적용된다고 읽으면 됩니다. Model을 먼저 적용하고, 그다음 projectionMatrix를 적용합니다.

&nbsp;

## 6. Metal의 핵심 객체들

Metal 코드를 처음 보면 `MTL`로 시작하는 타입이 너무 많아서 길을 잃기 쉽습니다. 역할별로 정리하면 다음과 같습니다.

| 객체 | 역할 | 언제 만드나 |
| --- | --- | --- |
| `MTLDevice` | GPU 그 자체. 다른 모든 객체를 만드는 공장 | Mapbox가 넘겨줌 |
| `MTLLibrary` / `MTLFunction` | 컴파일된 `.metal` 파일 / 그 안의 셰이더 함수 하나 | 시작할 때 1번 |
| `MTLRenderPipelineState` | "어떤 셰이더로, 어떤 픽셀 포맷에, 어떻게 블렌딩할지"를 묶은 설정. 만들기 비쌈 | 시작할 때 1번 |
| `MTLDepthStencilState` | 깊이 테스트 규칙 | 시작할 때 1번 |
| `MTLBuffer` | GPU가 읽을 수 있는 메모리 (정점 데이터 등) | 시작할 때 또는 데이터 바뀔 때 |
| `MTLCommandBuffer` | 이번 프레임에 GPU가 할 일 목록 | Mapbox가 매 프레임 넘겨줌 |
| `MTLRenderPassDescriptor` | 어디에 그릴지 (그릴 대상 텍스처) | Mapbox가 매 프레임 넘겨줌 |
| `MTLRenderCommandEncoder` | Command Buffer에 그리기 명령을 기록하는 펜 | 매 프레임 내가 생성 |

음식점에 비유하면 다음과 같습니다.

- `MTLDevice`는 **주방**, `MTLRenderPipelineState`는 미리 정해둔 **레시피**, `MTLBuffer`는 손질해 둔 **재료**입니다.
- `MTLCommandBuffer`는 이번 타임의 **주문서**이고, `MTLRenderCommandEncoder`로 주문서에 "이 레시피로, 이 재료를 써서, 삼각형 3개 그려주세요"라고 적습니다.
- 주문서를 주방에 넘기는 일(`commit`)은 Mapbox가 다른 Layer 주문까지 모두 적은 뒤에 합니다.

> 비싼 객체(Pipeline, Buffer)는 **한 번만 만들고**, 매 프레임에는 **기록(encode)만** 하는 것이 Metal 성능의 기본 원칙입니다. 이 원칙이 그대로 Custom Layer의 생명주기 구조가 됩니다.

### 깊이 테스트와 블렌딩

파이프라인 마지막 단계에서 쓰이는 두 가지 개념도 알아두겠습니다.

- **깊이 테스트(Depth test)**: 3D에서 가까운 물체가 먼 물체를 가리도록, 픽셀마다 깊이 값을 비교해서 더 가까운 것만 남깁니다. 큐브 같은 3D 물체에서는 필수이고, 평평한 2D 도형은 끄는 경우가 많습니다.
- **블렌딩(Blending)**: 반투명한 색을 그 아래에 이미 그려진 색과 섞는 규칙입니다. 지도 위에 반투명 도형을 올리려면 켜야 합니다.

&nbsp;

---

&nbsp;

# Part 2. Mapbox Custom Layer 해부

## 7. CustomLayer와 CustomLayerHost

Custom Layer는 두 부분으로 나뉩니다.

- **`CustomLayer`**: Style의 Layer 배열에 들어가는 Layer 정의 (구조체)
- **`CustomLayerHost`**: 실제로 Metal 코드를 실행하는 렌더러 (내가 구현하는 프로토콜)

SDK 소스에서 `CustomLayer`의 정의를 보면 다음과 같습니다.

```swift
@_spi(Experimental)
public struct CustomLayer: Layer, Equatable {
    public var id: String
    public let type: LayerType = .custom
    public var slot: Slot?
    public var minZoom: Double?
    public var maxZoom: Double?
    public var visibility: Value<Visibility> = .constant(.visible)
    public var renderer: CustomLayerHost
}
```

이전 글에서 배운 `CircleLayer`, `FillLayer`와 비교해 보면 차이가 분명합니다.

| | 일반 Layer (Circle, Fill 등) | CustomLayer |
| --- | --- | --- |
| Source | 필요함 | **없음** |
| 그리는 방법 | paint, layout 속성 (Expression) | **renderer가 Metal로 직접** |
| Layer 순서, slot, minZoom, maxZoom, visibility | 있음 | 있음 |

즉 Custom Layer는 **Layer 배열에서 한 자리를 차지한다는 점은 같지만, 그 자리에서 무엇을 그릴지는 전부 내가 정하는** Layer입니다. Layer 순서가 있기 때문에 도로 위, 라벨 아래처럼 지도 요소 사이에 내 그래픽을 끼워 넣을 수 있습니다. 이것이 지도 위에 `UIView`나 별도의 `MTKView`를 겹쳐 올리는 방식과 가장 큰 차이입니다.

&nbsp;

## 8. 생명주기 - renderingWillStart, render, renderingWillEnd

<img src="/assets/img/2026-11-02-mapbox-custom-layer-deep-dive/lifecycle.svg" alt="CustomLayer 생명주기" style="width: 100%;">

`CustomLayerHost` 프로토콜의 필수 메서드는 3개입니다.

```swift
protocol CustomLayerHost: NSObjectProtocol {
    func renderingWillStart(_ metalDevice: MTLDevice,
                            colorPixelFormat: UInt,
                            depthStencilPixelFormat: UInt)

    func render(_ parameters: CustomLayerRenderParameters,
                mtlCommandBuffer: MTLCommandBuffer,
                mtlRenderPassDescriptor: MTLRenderPassDescriptor)

    func renderingWillEnd()
}
```

### renderingWillStart - 한 번, 무거운 준비

렌더링을 처음 시작하기 전(또는 앱이 백그라운드에서 돌아왔을 때) 호출됩니다. Mapbox가 사용하는 `MTLDevice`와 픽셀 포맷을 넘겨주므로, 여기서 앞에서 말한 "비싼 객체"들을 만듭니다.

- `makeDefaultLibrary()`로 셰이더 함수 불러오기
- `MTLRenderPipelineState` 만들기
- 정점 데이터를 담은 `MTLBuffer` 만들기

`colorPixelFormat`, `depthStencilPixelFormat`이 `MTLPixelFormat`이 아니라 `UInt`인 이유는 헤더에서 Metal을 import하지 않기 위해서입니다. `MTLPixelFormat(rawValue:)`로 변환해서 씁니다. Pipeline의 픽셀 포맷은 **반드시 Mapbox가 넘겨준 값과 같아야** 합니다. Mapbox가 그리는 도화지에 함께 그리기 때문입니다.

### render - 매 프레임, 가볍게

지도가 다시 그려질 때마다 호출됩니다. 여기서 하는 일은 정해져 있습니다.

1. `mtlCommandBuffer.makeRenderCommandEncoder(descriptor: mtlRenderPassDescriptor)`로 Encoder 만들기
2. Pipeline, Buffer, 행렬 같은 상태 설정
3. `drawPrimitives` 호출
4. `endEncoding()`으로 기록 끝내기

여기서 주의할 점이 있습니다. SDK 헤더 주석에도 적혀 있는 내용입니다.

> Command Buffer는 **commit 하면 안 됩니다.** 내 Layer 뒤에 그려질 다른 Layer들의 명령이 아직 기록되지 않았기 때문입니다.

`render`는 매 프레임 호출되므로 여기서 Pipeline이나 Buffer를 새로 만들면 프레임이 떨어집니다.

### renderingWillEnd - 한 번, 정리

렌더링이 끝날 때 호출되며 만든 리소스를 정리합니다. 헤더 주석에 따르면 **`renderingWillStart`가 호출되지 않았는데도 호출될 수 있으므로**, 정리 코드는 리소스가 없는 상황도 안전하게 처리해야 합니다.

### 선택 메서드

이 외에 `prerender(_:mtlCommandBuffer:)`, `renderToTile(_:mtlRenderCommandEncoder:)` 같은 선택 메서드도 있습니다. 지형(terrain)이나 Globe 위에 텍스처처럼 덮어 그릴 때 쓰는 실험적 기능이라, 이 글에서는 다루지 않고 이후 딥다이브 주제로 남겨두겠습니다.

&nbsp;

## 9. CustomLayerRenderParameters - 매 프레임 받는 카메라 정보

`render`의 첫 번째 파라미터에는 지금 이 프레임의 카메라 정보가 담겨 있습니다.

| 프로퍼티 | 의미 |
| --- | --- |
| `width`, `height` | 지도 뷰 크기 (**point 단위**) |
| `latitude`, `longitude` | 카메라 중심 좌표 |
| `zoom` | 줌 레벨 |
| `bearing` | 회전 각도 (북쪽 기준 시계 방향) |
| `pitch` | 기울기 |
| `fieldOfView` | 시야각 (degree) |
| `projectionMatrix` | World 좌표 → Clip space 변환 행렬. `[NSNumber]` 16개 |
| `depthRange` | 3D 콘텐츠에 쓸 깊이 범위 |
| `elevationData` | 지형(terrain)이 켜져 있을 때 고도 정보 |
| `projection` | 현재 지도 투영(Mercator, Globe)에 맞는 변환 도우미 |

가장 많이 쓰는 것은 `projectionMatrix`와 `zoom`입니다. `projectionMatrix`는 `[NSNumber]` 16개로 오기 때문에 `simd_float4x4`로 바꿔서 사용합니다. 값은 **열 우선(column-major)** 순서로 들어 있어서 4개씩 끊어 열(column)로 만들면 됩니다.

```swift
extension Array where Element == NSNumber {
    var simdFloat4x4: simd_float4x4 {
        simd_float4x4([
            SIMD4(self[0].floatValue,  self[1].floatValue,  self[2].floatValue,  self[3].floatValue),
            SIMD4(self[4].floatValue,  self[5].floatValue,  self[6].floatValue,  self[7].floatValue),
            SIMD4(self[8].floatValue,  self[9].floatValue,  self[10].floatValue, self[11].floatValue),
            SIMD4(self[12].floatValue, self[13].floatValue, self[14].floatValue, self[15].floatValue)
        ])
    }
}
```

`width`, `height`가 point 단위라는 점도 기억해야 합니다. Metal의 Viewport는 실제 픽셀 단위이므로 화면 배율(scale)을 곱해야 합니다. 이걸 빠뜨리면 그림이 화면의 1/3 크기로 구석에 그려집니다.

&nbsp;

---

&nbsp;

# Part 3. 예제

## 10. 예제 1 - 서울, 부산, 광주를 잇는 삼각형

지금까지 배운 내용을 모두 모아서, 서울, 부산, 광주를 꼭짓점으로 하는 반투명 삼각형을 지도에 그려보겠습니다. 지도를 움직이고 확대하면 삼각형도 지도에 붙어서 함께 움직여야 합니다.

파일은 3개입니다.

```text
TriangleShaders.metal        ← 셰이더 (GPU)
TriangleLayerHost.swift      ← CustomLayerHost 구현 (CPU)
CustomLayerViewController.swift
```

### Step 1. 정점 데이터 구조 정하기

Swift와 셰이더가 **같은 메모리 구조**를 사용해야 합니다. 정점 하나는 Mercator 위치(x, y)와 색(r, g, b, a)을 가집니다.

```swift
// Swift
struct TriangleVertex {
    var position: SIMD2<Float> // Mercator x, y (0 ~ 1)
    var color: SIMD4<Float>    // r, g, b, a (0 ~ 1)
}
```

```cpp
// MSL
struct TriangleVertex {
    float2 position;
    float4 color;
};
```

`float4`는 16바이트 정렬이 필요해서, 두 언어 모두 `position`(8바이트) 뒤에 8바이트 패딩을 넣고 `color`를 16바이트 위치에 둡니다. 그래서 `MemoryLayout<TriangleVertex>.stride`는 32입니다. 구조가 어긋나면 GPU가 엉뚱한 바이트를 읽어 삼각형이 깨지므로, 타입을 바꿀 때는 양쪽을 함께 바꿔야 합니다.

> 공식 예제처럼 C 헤더(`.h`) 하나에 구조체를 정의하고 Swift(Bridging Header)와 셰이더 양쪽에서 include하면 이 불일치를 원천적으로 막을 수 있습니다.

### Step 2. 셰이더 작성 (TriangleShaders.metal)

```cpp
#include <metal_stdlib>
using namespace metal;

struct TriangleVertex {
    float2 position; // Mercator (0 ~ 1)
    float4 color;
};

struct RasterizerData {
    float4 position [[position]];
    float4 color;
};

vertex RasterizerData triangleVertex(uint vertexID [[vertex_id]],
                                     constant TriangleVertex *vertices [[buffer(0)]],
                                     constant float4x4 &mvp [[buffer(1)]]) {
    TriangleVertex v = vertices[vertexID];

    RasterizerData out;
    // Mercator(x, y, 0, 1) → MVP 행렬 → Clip space
    out.position = mvp * float4(v.position, 0.0, 1.0);
    out.color = v.color;
    return out;
}

fragment float4 triangleFragment(RasterizerData in [[stage_in]]) {
    // premultiplied alpha: rgb에 미리 alpha를 곱해서 반환
    return float4(in.color.rgb * in.color.a, in.color.a);
}
```

Vertex Shader는 앞에서 본 좌표의 여정을 코드 한 줄로 끝냅니다. `mvp`는 Swift에서 `projectionMatrix × modelMatrix`를 미리 곱해서 넘겨줄 것입니다.

Fragment Shader에서 rgb에 alpha를 곱하는 것을 **premultiplied alpha**라고 합니다. 아래 Pipeline의 블렌딩 설정(`source = one`, `destination = oneMinusSourceAlpha`)과 짝을 이루는 방식으로, 공식 예제도 같은 블렌딩 설정을 사용합니다.

### Step 3. CustomLayerHost 구현 (TriangleLayerHost.swift)

```swift
import UIKit
import Metal
import simd
@_spi(Experimental) import MapboxMaps

final class TriangleLayerHost: NSObject, CustomLayerHost {

    private var pipelineState: MTLRenderPipelineState?
    private var depthStencilState: MTLDepthStencilState?
    private var vertexBuffer: MTLBuffer?

    private let corners: [(coordinate: CLLocationCoordinate2D, color: SIMD4<Float>)] = [
        (CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), [1.0, 0.35, 0.2, 0.7]), // 서울
        (CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756), [0.2, 0.5, 1.0, 0.7]),  // 부산
        (CLLocationCoordinate2D(latitude: 35.1595, longitude: 126.8526), [0.2, 0.8, 0.4, 0.7])   // 광주
    ]

    // MARK: - 1번: 무거운 준비

    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        // 1. 셰이더 함수 불러오기
        guard let library = metalDevice.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "triangleVertex"),
              let fragmentFunction = library.makeFunction(name: "triangleFragment") else {
            assertionFailure("셰이더 함수를 찾을 수 없습니다.")
            return
        }

        // 2. Render Pipeline: 어떤 셰이더로, 어떤 포맷에, 어떻게 섞을지
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Triangle Pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        let colorAttachment = pipelineDescriptor.colorAttachments[0]!
        colorAttachment.pixelFormat = MTLPixelFormat(rawValue: colorPixelFormat)!   // Mapbox와 같은 포맷
        colorAttachment.isBlendingEnabled = true
        colorAttachment.sourceRGBBlendFactor = .one                     // premultiplied alpha
        colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachment.sourceAlphaBlendFactor = .one
        colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: depthStencilPixelFormat)!
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat(rawValue: depthStencilPixelFormat)!

        do {
            pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            assertionFailure("Pipeline 생성 실패: \(error)")
        }

        // 3. 깊이 테스트: 평평한 2D 도형이므로 비교 없이 항상 그림
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .always
        depthDescriptor.isDepthWriteEnabled = false
        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthDescriptor)

        // 4. 정점 버퍼: Mercator 좌표는 카메라와 무관하므로 1번만 계산
        let vertices = corners.map { corner -> TriangleVertex in
            let mercator = Projection.latLngToMercatorXY(coordinate: corner.coordinate)
            return TriangleVertex(position: SIMD2(Float(mercator.x), Float(mercator.y)), color: corner.color)
        }
        vertexBuffer = metalDevice.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<TriangleVertex>.stride * vertices.count,
            options: []
        )
    }

    // MARK: - 매 프레임: 가볍게 기록만

    func render(_ parameters: CustomLayerRenderParameters,
                mtlCommandBuffer: MTLCommandBuffer,
                mtlRenderPassDescriptor: MTLRenderPassDescriptor) {
        guard let pipelineState,
              let depthStencilState,
              let vertexBuffer,
              let encoder = mtlCommandBuffer.makeRenderCommandEncoder(descriptor: mtlRenderPassDescriptor) else {
            return
        }

        // 1. MVP 행렬 만들기
        let projectionMatrix = parameters.projectionMatrix.simdFloat4x4
        let worldSize = Float(Projection.worldSize(scale: pow(2, parameters.zoom)))
        let modelMatrix = simd_float4x4(diagonal: SIMD4<Float>(worldSize, worldSize, 1, 1)) // Mercator → World
        var mvp = projectionMatrix * modelMatrix

        // 2. Viewport: point → pixel
        let scale = UIScreen.main.scale
        encoder.setViewport(MTLViewport(
            originX: 0, originY: 0,
            width: parameters.width * scale,
            height: parameters.height * scale,
            znear: 0, zfar: 1
        ))

        // 3. 상태와 데이터 설정
        encoder.label = "Triangle Custom Layer"
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthStencilState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)                         // → [[buffer(0)]]
        encoder.setVertexBytes(&mvp, length: MemoryLayout<simd_float4x4>.stride, index: 1)  // → [[buffer(1)]]

        // 4. 그리기: 정점 3개로 삼각형 1개
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        // 5. 기록 끝 (commit은 Mapbox가 함)
        encoder.endEncoding()
    }

    // MARK: - 1번: 정리

    func renderingWillEnd() {
        pipelineState = nil
        depthStencilState = nil
        vertexBuffer = nil
    }
}
```

코드를 파이프라인 관점에서 다시 읽어보면 다음과 같습니다.

| 코드 | 파이프라인 단계 |
| --- | --- |
| `vertexBuffer` 생성 | ① Vertex 데이터를 GPU 메모리에 올림 |
| `vertexFunction` + `mvp` | ② Vertex Shader가 Clip space 좌표 계산 |
| `drawPrimitives(type: .triangle)` | ③ Rasterizer가 삼각형으로 픽셀을 채움 |
| `fragmentFunction` | ④ Fragment Shader가 색 결정 (보간된 색 사용) |
| `isBlendingEnabled`, `depthStencilState` | ⑤ 블렌딩과 깊이 테스트 규칙 |

`setVertexBytes`는 작은 데이터(4KB 미만)를 버퍼 없이 바로 넘기는 API입니다. 행렬처럼 매 프레임 바뀌는 작은 uniform을 넘길 때 편리합니다.

### Step 4. 지도에 추가 (CustomLayerViewController.swift)

```swift
import UIKit
@_spi(Experimental) import MapboxMaps

final class CustomLayerViewController: UIViewController {

    private var mapView: MapView!
    // 렌더러는 Layer를 다시 만들 때마다 새로 생기지 않도록 프로퍼티로 보관
    private let renderer = TriangleLayerHost()
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = CameraOptions(center: CLLocationCoordinate2D(latitude: 36.3, longitude: 127.8), zoom: 6)
        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: camera, styleURI: .streets))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            guard let self else { return }

            // 이 예제의 MVP 계산은 평면 Mercator 기준이므로 투영을 고정
            try? self.mapView.mapboxMap.setProjection(StyleProjection(name: .mercator))

            let layer = CustomLayer(id: "triangle-layer", renderer: self.renderer)
            // 도로 라벨 아래에 끼워 넣기
            try? self.mapView.mapboxMap.addLayer(layer, layerPosition: .below("road-label"))
        }.store(in: &cancelables)
    }
}
```

`.below("road-label")` 덕분에 삼각형은 도로 위에, 도로 이름 라벨 아래에 그려집니다. 이전 글에서 배운 Layer 순서 개념이 Custom Layer에도 그대로 적용됩니다.

SwiftUI처럼 선언형 Style DSL을 쓴다면 공식 예제처럼 이렇게 추가할 수도 있습니다.

```swift
mapView.mapboxMap.setMapStyleContent {
    CustomLayer(id: "triangle-layer", renderer: renderer)
}
```

### 실행 결과 이해하기

실행하면 한반도 위에 서울, 부산, 광주를 잇는 삼각형이 보이고, 내부는 세 꼭짓점의 색(주황, 파랑, 초록)이 자연스럽게 섞인 그라데이션으로 채워집니다. 정점 3개에만 색을 줬는데 그라데이션이 생기는 것은 ③ Rasterizer의 보간 덕분입니다.

지도를 움직이거나 회전, 기울이면 삼각형도 함께 움직입니다. Mapbox가 매 프레임 새 `projectionMatrix`와 `zoom`을 넘겨주고, 우리는 그걸로 MVP를 다시 만들기 때문입니다.

### 왜 Globe에서는 다르게 해야 할까

v11의 기본 투영은 줌이 낮을 때 지구를 공 모양으로 보여주는 **Globe**입니다. 이 예제는 평면 Mercator를 가정하고 MVP를 만들었기 때문에, Globe 상태에서는 위치가 맞지 않습니다. 그래서 `setProjection(StyleProjection(name: .mercator))`로 투영을 고정했습니다.

Globe에 대응하려면 `parameters.projection`이 제공하는 도우미(`convertMercatorModelMatrix`, `getTransitionMatrix`, `getTransitionPhase` 등)를 써야 합니다. 예제 3에서 공식 코드로 살펴보겠습니다.

### 정밀도 문제 - 줌을 많이 당기면 흔들린다

`Float`은 유효숫자가 약 7자리입니다. Mercator 좌표 `0.8527...`을 `Float`으로 저장하면 아주 작은 오차가 생기는데, 줌 18에서 `worldSize`는 512 × 2¹⁸ ≈ 1억 3천만이므로 이 작은 오차가 수 픽셀 단위로 커집니다. 그래서 줌을 아주 많이 당기면 도형이 미세하게 떨리거나 어긋날 수 있습니다.

이 문제는 보통 **기준점(origin)을 정하고, 정점을 기준점으로부터의 상대 좌표로 저장**하는 방식(Relative To Center)으로 해결합니다. 큰 수는 `Double`로 CPU에서 계산하고, GPU에는 작은 수만 넘기는 아이디어입니다. 도시 단위 시각화라면 크게 문제 되지 않지만, 건물 단위로 정밀하게 그려야 한다면 꼭 고려해야 합니다.

&nbsp;

## 11. 예제 2 - 시간에 따라 깜빡이는 삼각형

이번에는 시간을 uniform으로 넘겨서 삼각형이 숨 쉬듯 깜빡이게 만들어 보겠습니다. 이 예제에서 배울 것은 두 가지입니다.

- Fragment Shader에 uniform 넘기기
- 지도가 멈춰 있어도 계속 다시 그리게 만들기

### Fragment Shader에 시간 받기

```cpp
fragment float4 pulseFragment(RasterizerData in [[stage_in]],
                              constant float &time [[buffer(0)]]) {
    float pulse = 0.5 + 0.5 * sin(time * 3.0);     // 0 ~ 1 사이를 반복
    float alpha = in.color.a * (0.3 + 0.7 * pulse);
    return float4(in.color.rgb * alpha, alpha);    // premultiplied alpha
}
```

`renderingWillStart`에서 fragment 함수 이름을 `"pulseFragment"`로 바꾸고, `render`에서 시간을 넘겨줍니다.

```swift
private let startTime = CACurrentMediaTime()

// render(...) 안, drawPrimitives 전에
var time = Float(CACurrentMediaTime() - startTime)
encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.stride, index: 0) // → fragment의 [[buffer(0)]]
```

Vertex와 Fragment는 버퍼 번호 공간이 따로입니다. `setVertexBytes(index: 0)`과 `setFragmentBytes(index: 0)`은 서로 다른 슬롯입니다.

### 계속 다시 그리게 만들기 - triggerRepaint

여기까지만 하면 삼각형이 깜빡이지 않습니다. **Mapbox는 지도에 변화가 없으면 다시 그리지 않기** 때문입니다. 배터리를 아끼기 위한 당연한 동작이지만, 애니메이션을 하려면 매 프레임 "다시 그려줘"라고 요청해야 합니다.

```swift
private var displayLink: CADisplayLink?

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    displayLink = CADisplayLink(target: self, selector: #selector(repaint))
    displayLink?.add(to: .main, forMode: .common)
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    displayLink?.invalidate() // CADisplayLink는 target을 강하게 잡으므로 꼭 해제
    displayLink = nil
}

@objc private func repaint() {
    mapView.mapboxMap.triggerRepaint()
}
```

`CADisplayLink`는 화면 주사율에 맞춰 호출되는 타이머이고, `triggerRepaint()`는 Mapbox에게 다음 프레임을 그리라고 요청합니다. 그러면 `render`가 매 프레임 호출되면서 새 시간 값이 셰이더로 전달됩니다.

> 애니메이션이 필요 없을 때는 DisplayLink를 멈추는 것이 좋습니다. 매 프레임 지도 전체를 다시 그리는 것은 공짜가 아닙니다.

&nbsp;

## 12. 예제 3 - 공식 예제 읽기 (미터 단위 3D 큐브, Globe)

Mapbox 공식 저장소의 `CustomLayerExample.swift`는 두 가지를 그립니다. 지금까지 배운 개념으로 핵심만 읽어보겠습니다.

### 헬싱키 위의 1km 큐브

```swift
private func renderCubesInMeters(parameters: CustomLayerRenderParameters,
                                 renderCommandEncoder: MTLRenderCommandEncoder) {
    // 1. Mapbox가 준 View + Projection
    let projectionMatrix = parameters.projectionMatrix.simdFloat4x4

    // 2. Model 행렬: 위치 이동 × 미터→픽셀 스케일
    let modelMatrix = parameters.createModelMatrixMeters(
        location: cubeConfiguration.location,
        altitude: cubeConfiguration.altitude,
        size: cubeConfiguration.cubeSize)

    // 3. 현재 투영(Mercator/Globe)에 맞게 Model 행렬 보정
    let transformedMatrix = parameters.projection.convertMercatorModelMatrix(
        forMatrix: modelMatrix.nsNumberArray,
        ignoreDistortion: false
    )!.simdFloat4x4

    // 4. MVP
    var finalMatrix = projectionMatrix * transformedMatrix

    // 5. 깊이 테스트를 켠 파이프라인으로 36개 정점 그리기
    renderCommandEncoder.setDepthStencilState(simpleShaderProgram.depthStencilState)
    ...
}
```

예제 1과 비교하면 차이가 보입니다.

- **Model 행렬이 더 복잡합니다.** 예제 1은 `× worldSize` 스케일 하나였지만, 여기서는 "헬싱키 위치로 이동(translation)"과 "1000미터를 픽셀로 변환하는 스케일"을 곱합니다. Mercator 투영에서는 위도에 따라 1미터가 차지하는 픽셀 수가 달라지기 때문에 `Projection.metersPerPoint(for:zoom:)`로 위도별 값을 계산합니다.
- **`convertMercatorModelMatrix`** 가 들어갑니다. Mercator 기준으로 만든 Model 행렬을 현재 투영(Globe 포함)에 맞게 바꿔주는 도우미입니다. 예제 1에서 Globe를 피하려고 투영을 고정했던 문제를 이렇게 해결합니다.
- **깊이 테스트를 켭니다.** 큐브는 3D라서 앞면이 뒷면을 가려야 하므로 `depthCompareFunction = .less`, `isDepthWriteEnabled = true`를 사용합니다.

### 베를린에서 도쿄까지 움직이는 점들

두 번째는 점 128개가 파도치듯 움직이는 애니메이션입니다. 여기서는 정점마다 위치를 **두 벌** 준비합니다.

- `pos_merc`: 평면 Mercator 기준 위치
- `pos_ecef`: 지구 중심 기준 3D 위치 (ECEF, Globe용)

```cpp
float4 pos_merc = uniforms.u_matrix_merc * float4(vertices[vertexID].pos_merc, 1.0);
float4 pos_ecef = uniforms.u_matrix_ecef * float4(vertices[vertexID].pos_ecef, 1.0);

float t = clamp(uniforms.u_transition, 0.0, 1.0);
out.position = mix(pos_merc, pos_ecef, t);
```

줌을 바꾸면 지도가 Globe와 평면 사이를 부드럽게 오가는데, 그 진행도를 `parameters.projection.getTransitionPhase()`로 받아 셰이더에서 `mix`로 두 위치를 섞습니다. 셰이더가 "정점 위치를 계산하는 프로그램"이라는 것을 잘 보여주는 예입니다.

또 `type: .point`로 그리면서 Vertex Shader 출력에 `[[point_size]]`를 지정해 점 크기를 정하는 것도 볼 수 있습니다.

&nbsp;

## 13. 아무것도 안 보일 때 체크리스트

Custom Layer는 실수해도 에러 없이 **그냥 아무것도 안 보이는** 경우가 많습니다. 아래를 순서대로 확인해 보세요.

| 증상 | 의심할 부분 |
| --- | --- |
| 아예 안 보임 | 셰이더 함수 이름 오타, `.metal` 파일이 앱 타겟에 포함되지 않음 (`makeFunction`이 nil) |
| 아예 안 보임 | Pipeline 픽셀 포맷이 Mapbox가 준 값과 다름 (생성 실패) |
| 아예 안 보임 | `endEncoding()` 누락 또는 Command Buffer를 직접 `commit` |
| 화면 구석에 작게 그려짐 | Viewport에 화면 배율(scale)을 곱하지 않음 |
| 엉뚱한 위치 | 행렬 곱 순서가 반대 (`model * projection`), 열 우선 순서 착각 |
| 엉뚱한 위치 | Globe 투영 상태인데 Mercator 기준으로 계산 |
| 모양이 깨짐 | Swift 구조체와 MSL 구조체의 메모리 레이아웃 불일치 |
| 애니메이션이 멈춤 | `triggerRepaint()`를 호출하지 않음 |
| 줌을 당기면 떨림 | `Float` 정밀도 문제 (Relative To Center 고려) |

**Xcode GPU Frame Capture**도 꼭 써보세요. 디버그 바의 카메라 모양 버튼으로 한 프레임을 캡처하면 Mapbox의 Layer별 draw call 목록 사이에서 `"Triangle Custom Layer"`라는 label로 내 Encoder를 찾을 수 있습니다. 정점 버퍼에 들어간 값, 행렬 값, 셰이더 출력까지 직접 확인할 수 있어서 "왜 안 보이지?"를 추측이 아니라 눈으로 확인할 수 있습니다. 코드에서 `encoder.label`을 지정한 이유가 바로 이것입니다.

&nbsp;

---

&nbsp;

## 정리

| 개념 | 한 줄 정의 |
| --- | --- |
| GPU | 같은 계산을 대량으로 동시에 처리하는 그래픽 전용 프로세서 |
| Metal | Apple 플랫폼에서 GPU에게 명령을 내리는 그래픽스 API |
| Vertex (정점) | 삼각형의 꼭짓점. 위치, 색 등의 정보를 가짐 |
| 렌더링 파이프라인 | 정점 → Vertex Shader → Rasterizer → Fragment Shader → 픽셀 |
| Shader | GPU에서 실행되는 작은 프로그램 (MSL로 작성) |
| Vertex Shader | 정점마다 실행, 화면 위치(Clip space) 계산 |
| Fragment Shader | 픽셀마다 실행, 색 계산 |
| Uniform | 모든 정점, 픽셀이 공유하는 값 (행렬, 시간 등) |
| Clip space | GPU의 표준 좌표 공간, -1 ~ 1 |
| MVP 행렬 | Model × View × Projection, 좌표 변환을 합친 행렬 |
| CustomLayer | Source 없이 Layer 배열에 자리 잡는 Layer |
| CustomLayerHost | Metal로 직접 그리는 렌더러. Start(1번) → Render(매 프레임) → End(1번) |
| projectionMatrix | Mapbox가 매 프레임 주는 World → Clip space 행렬 |

Custom Layer는 결국 **"Mapbox가 계산해 준 카메라 행렬을 받아서, 내 정점을 Clip space로 옮기는 셰이더를 짜는 일"** 입니다. 처음에는 용어가 많아 보이지만, 렌더링 파이프라인과 좌표의 여정 두 그림만 머릿속에 있으면 나머지 코드는 그 과정을 Metal 문법으로 적은 것에 불과합니다.

다음 딥다이브에서는 이 글에서 미뤄둔 주제들을 하나씩 다뤄볼 예정입니다.

- 미터 단위 3D 모델 배치와 깊이 테스트
- Globe 투영 대응 (`convertMercatorModelMatrix`, transition)
- Relative To Center로 정밀도 문제 해결
- `renderToTile`로 지형 위에 그리기

&nbsp;

### 참고

- [mapbox-maps-ios - CustomLayerExample.swift](https://github.com/mapbox/mapbox-maps-ios/blob/main/Sources/Examples/All%20Examples/CustomLayerExample.swift)
- [Apple - Metal](https://developer.apple.com/documentation/metal)
- [Apple - Using a Render Pipeline to Render Primitives](https://developer.apple.com/documentation/metal/using-a-render-pipeline-to-render-primitives)
- [Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
