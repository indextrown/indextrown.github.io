---
title: "[SwiftUI] Diffing, 끝까지 파고들었습니다."
tags:
  - Swift
header:
  teaser:
typora-root-url: ../
---

<!-- `Text("Hello World")`, `Text(isOn ? "On" : "Off")`, `Button` -->

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%" align="left"> -->

SwiftUI 성능 문제를 살펴볼 때 body 호출 횟수만 세면 원인을 놓치기 쉽습니다. body가 다시 호출되는 것과 실제 화면이 갱신되는 것은 서로 다른 단계이기 때문입니다.

이 글에서는 @State, @Binding, @ObservedObject, @Observable, ForEach, .equatable() 예제를 차례로 실행하며 다음 세 가지를 확인합니다.

- 어떤 상태 변화가 어떤 View의 body를 다시 호출하는가
- identity가 State 유지와 View 재사용에 어떤 영향을 주는가
- 팝팡 리스트에서 여러 Cell의 body가 다시 호출되던 범위를 어떻게 좁혔는가

본문에서는 body 재계산, diffing/reconciliation, 실제 화면 반영을 구분해서 설명하겠습니다.

## Diffing을 이해하려면 Identity부터 봐야 합니다

[WWDC21 - Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/)에서는 Identity를 두 가지로 나누어 설명합니다.

- Explicit Identity(명시적 identity): 사용자 정의 값이나 데이터의 식별자를 사용합니다.
- Structural Identity(구조적 identity): View 계층의 타입과 위치로 View를 구분합니다.

Apple은 View의 프로퍼티를 종속성(dependencies)이라고 부릅니다.

<details class="notion-toggle-list" markdown="1">
<summary>body 재호출 디버깅을 위한 랜덤 배경색 부여 헬퍼 메서드</summary>

```swift
public extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension View {
    func randomColorStyle(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 12
    ) -> some View {
        self
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.random.opacity(0.35))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}
```

</details>

## 1. @State가 바뀌면 소유 View의 body를 다시 계산합니다
<div class="code-media-row" markdown="1">
```swift
struct SampleDiffView: View {
    @State private var isOn = true
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello World")
                .frame(maxWidth: .infinity)
                .randomColorStyle()

            Text(isOn ? "On" : "Off")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
            
            Button {
                isOn.toggle()
            } label: {
                Text("버튼")
                    .frame(maxWidth: .infinity)
            }
            .randomColorStyle()
        }
        .padding(24)
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-01 at 17.26.13](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-01 at 17.26.13.gif)

</div>
이 예제는 body가 다시 호출될 때마다 랜덤 색상을 입혀 호출 범위를 눈으로 확인합니다. 이 배경색 변화는 diffing 결과가 아니라 body를 다시 계산하는 시점에 발생한다는 점을 먼저 구분해야 합니다.

SampleDiffView.body는 isOn을 읽습니다. 버튼을 눌러 isOn이 바뀌면 SampleDiffView의 body를 다시 계산합니다. 이때 VStack 내부의 하위 View가 모두 같은 identity를 갖는 것은 아닙니다.

#### 하위 View는 위치에 따라 다른 Structural Identity를 가집니다
```swift
VStack(spacing: 20) {
    Text("Hello World")        // child 0
    Text(isOn ? "On" : "Off")  // child 1
    Button { ... }             // child 2
}
```
`Text("Hello World")`, `Text(isOn ? "On" : "Off")`, Button은 VStack 안에서 위치가 다르므로 각각 다른 Structural Identity를 가집니다. 두 번째 Text는 isOn 값에 따라 on/off를 보여주지만 View의 위치와 타입은 그대로 유지됩니다. 즉, "On" 상태의 두 번째 Text와 "Off" 상태의 두 번째 Text는 같은 Structural Identity를 유지하고, Text의 입력값만 바뀝니다.

<!-- 그런데 화면에서는 isOn과 직접 관련 없어 보이는 Text("Hello World")의 배경색도 함께 바뀐다. 이는 Text("Hello World")가 같은 identity를 가져서가 아니라, SampleDiffView.body가 다시 평가되면서 .randomColorStyle() 내부의 Color.random도 다시 실행되기 때문이다.

정리하면 다음과 같다.
- isOn 변경으로 SampleDiffView.body가 다시 평가된다.
- VStack 내부의 각 subview는 서로 다른 structural identity를 가진다.
- 두 번째 Text는 "On"과 "Off" 사이에서 같은 structural identity를 유지한다.
- Text("Hello World")의 배경색이 바뀌는 이유는 identity 때문이 아니라, body 재평가 과정에서 랜덤 색상이 다시 생성되기 때문이다. -->

## 2. View를 분리하면 무관한 자식 body 호출을 줄일 수 있습니다
<div class="code-media-row" markdown="1">

```swift
struct SampleDiffView: View {
    @State private var isOn = true
    var body: some View {
        VStack(spacing: 20) {
            ExtractSubView()
            
            Text(isOn ? "On" : "Off")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
            
            Button {
                isOn.toggle()
            } label: {
                Text("버튼")
                    .frame(maxWidth: .infinity)
            }
            .randomColorStyle()
        }
        .padding(24)
    }
}

struct ExtractSubView: View {
    // no dependency
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-02 at 13.41.22](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-02 at 13.41.22.gif)

</div>

ExtractSubView는 isOn을 직접 읽지 않는 독립적인 View입니다. 버튼을 누르면 SampleDiffView의 @State인 isOn이 바뀌므로 SampleDiffView.body를 다시 계산합니다. 하지만 ExtractSubView는 VStack 안에서 같은 위치와 타입을 유지하고, 내부에서 바뀐 종속성을 읽지 않습니다.

#### ExtractSubView.body를 다시 계산하지 않는 이유

이 예제에서 ExtractSubView에는 바뀌는 종속성이 없습니다. SwiftUI는 같은 위치에 같은 타입으로 남아 있는 이 View를 이전 View와 연결할 수 있으므로 ExtractSubView.body를 다시 계산할 필요가 없습니다.

View를 이렇게 나누면 상태와 무관한 하위 body를 건너뛸 여지가 생깁니다. body 재계산 범위를 좁히면 이후 diffing과 화면 반영 후보도 함께 줄일 수 있습니다.

렌더링 단계의 비용이 가장 크지만, 이 구조처럼 body 재계산 범위를 줄이면 불필요한 렌더링으로 이어지는 일을 막을 수 있습니다.

## 3. `.id()` 값이 바뀌면 View의 Identity도 바뀝니다
<div class="code-media-row" markdown="1">
```swift
struct SampleDiffView: View {
    @State private var isOn = true
    var body: some View {
        VStack(spacing: 20) {
            ExtractSubView().id(UUID()) // id

            Text(isOn ? "On" : "Off")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
            
            Button {
                isOn.toggle()
            } label: {
                Text("버튼")
                    .frame(maxWidth: .infinity)
            }
            .randomColorStyle()
        }
        .padding(24)
    }
}

struct ExtractSubView: View {
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-01 at 17.26.13](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-01 at 17.26.13.gif)
</div>
[`id(_:)` 공식 문서](https://developer.apple.com/documentation/swiftui/view/id(_:)/)는 id 값이 바뀌면 View의 identity도 바뀐다고 설명합니다. 버튼을 누르면 SampleDiffView의 @State인 isOn이 바뀌므로 SampleDiffView.body를 다시 계산합니다. 이때 `ExtractSubView().id(UUID())`도 다시 만들어집니다. `UUID()`는 매번 새로운 값을 만들기 때문에 ExtractSubView의 Explicit Identity도 매번 달라집니다.

2번 예시에서는 ExtractSubView가 같은 위치에 같은 타입으로 유지되어 이전 View와 연결될 수 있었습니다. 3번 예시에서는 `.id(UUID())` 때문에 이전 ExtractSubView와 현재 ExtractSubView를 같은 View로 볼 수 없습니다. SwiftUI는 이를 새로운 대상으로 취급하고 ExtractSubView.body를 다시 계산합니다.

Self._printChanges()를 출력하면 다음과 같은 결과가 나올 수 있습니다.

```swift
SampleDiffView: @self, @identity, _isOn changed. // 뷰 초기화
SampleDiffView: _isOn changed.                   // 버튼 클릭
SampleDiffView: _isOn changed.                   // 버튼 클릭
```

여기서 `_isOn changed`는 @State 값인 isOn이 바뀌어 SampleDiffView.body를 다시 계산했다는 뜻입니다. `@self`는 SampleDiffView라는 View 값 자체가 바뀌었다는 뜻이고, `@identity`는 SwiftUI가 identity 변화를 감지했음을 나타냅니다. 첫 출력은 SampleDiffView를 처음 구성하면서 identity 변화가 함께 감지된 상황입니다. 이후 출력은 identity를 유지한 채 `_isOn` 변경만으로 SampleDiffView.body를 다시 계산한 상황입니다.


## 4. @Binding을 전달해도 body에서 읽지 않으면 다시 계산되지 않을 수 있습니다
```bash
// 버튼 1번 클릭
ExtractLightView: _isOn changed.

// 버튼 1번 클릭
ExtractLightView: _isOn changed.
```
<div class="code-media-row" markdown="1">
```swift
struct SampleDiffView5: View {
    @State private var isOn = true
    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            ExtractTitleView()

            ExtractLightView(isOn: $isOn)
            
            ExtractSubButton(isOn: $isOn)
        }
        .padding(24)
    }
}

struct ExtractTitleView: View {
    // no dependency
    var body: some View {
        let _ = Self._printChanges()
        Text("Hello World")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct ExtractLightView: View {
    @Binding var isOn: Bool
    var body: some View {
        let _ = Self._printChanges()
        Text(isOn ? "On" : "Off")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct ExtractSubButton: View {
    @Binding var isOn: Bool
    var body: some View {
        let _ = Self._printChanges()
        Button {
            isOn.toggle()
        } label: {
            Text("버튼")
                .frame(maxWidth: .infinity)
        }
        .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 14.32.04](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 14.32.04.gif)
</div>

- ExtractTitleView는 바뀌는 종속성을 읽지 않으므로 body를 다시 계산하지 않습니다.
- ExtractLightView는 `@Binding var isOn: Bool`을 가지고 있고, `Text(isOn ? "On" : "Off")`에서 isOn을 읽습니다. isOn이 바뀔 때마다 body를 다시 계산합니다.
- ExtractSubButton도 `@Binding var isOn: Bool`을 가지고 있지만, `isOn.toggle()`은 버튼을 누를 때 실행되는 action 클로저 안에서만 호출합니다. body가 화면을 구성할 때는 이 값을 읽지 않으므로, 이 예제에서는 isOn이 바뀌어도 ExtractSubButton.body를 다시 계산하지 않습니다.

@Binding을 전달했다는 이유만으로 body를 다시 계산하지는 않습니다. 이 예제에서는 body가 상태를 읽어 화면 결과에 반영하는지에 따라 호출 범위가 달라집니다.

ExtractLightView는 `Text(isOn ? "On" : "Off")`에서 isOn을 읽으므로 값이 바뀌면 화면 결과도 달라질 수 있습니다. 반면 ExtractSubButton은 이벤트가 발생할 때 action 클로저 안에서만 isOn을 사용합니다. 현재 화면 결과는 isOn에 직접 의존하지 않습니다.

이 차이는 상태를 “전달받는 것”과 “렌더링에 사용하는 것”의 차이입니다.


## 5. @ObservedObject는 객체 단위 변경 알림을 구독합니다

```bash
// 버튼 1번 클릭
SampleObservedObjectDiffView: _viewModel changed.
ObservedLightView: _viewModel changed.
ObservedSubButton: _viewModel changed.

// 버튼 1번 클릭
SampleObservedObjectDiffView: _viewModel changed.
ObservedLightView: _viewModel changed.
ObservedSubButton: _viewModel changed.
```

<div class="code-media-row" markdown="1">
```swift
final class LightViewModel: ObservableObject {
    @Published var isOn = true

    func toggle() {
        isOn.toggle()
    }
}

struct SampleObservedObjectDiffView: View {
    @StateObject private var viewModel = LightViewModel()

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            ObservedTitleView()
    
            ObservedLightView(viewModel: viewModel)
    
            ObservedSubButton(viewModel: viewModel)
        }
        .padding(24)
    }
}

struct ObservedTitleView: View {
    // no dependency
    var body: some View {
        let _ = Self._printChanges()
        Text("Hello World")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct ObservedLightView: View {
    @ObservedObject var viewModel: LightViewModel

    var body: some View {
        let _ = Self._printChanges()
        Text(viewModel.isOn ? "On" : "Off")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct ObservedSubButton: View {
    @ObservedObject var viewModel: LightViewModel

    var body: some View {
        let _ = Self._printChanges()
        Button {
            viewModel.toggle()
        } label: {
            Text("버튼")
                .frame(maxWidth: .infinity)
        }
        .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 14.47.48](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 14.47.48.gif)
</div>

4번 예시에서는 `@Binding var isOn: Bool`을 가지고 있더라도 body에서 isOn을 읽지 않는 ExtractSubButton.body는 다시 호출되지 않았습니다.

@ObservedObject는 다르게 동작합니다. ObservedLightView와 ObservedSubButton은 같은 LightViewModel을 @ObservedObject로 관찰합니다. viewModel.isOn이 바뀌면 LightViewModel.objectWillChange가 발생하고, 이 객체를 관찰하는 View가 변경 알림을 받습니다.

ObservedLightView는 body에서 viewModel.isOn을 읽으므로 body를 다시 계산합니다. ObservedSubButton은 viewModel을 버튼 action 클로저에서만 사용하지만, @ObservedObject로 객체 자체를 관찰하기 때문에 같은 변경 알림을 받아 body를 다시 계산할 수 있습니다.

ObservedTitleView는 LightViewModel을 전달받지 않고 바뀌는 종속성도 읽지 않습니다. 버튼을 눌러 isOn이 바뀌어도 ObservedTitleView.body는 다시 호출되지 않습니다.

@Binding 예제에서는 body가 값을 읽는지에 따라 호출 범위가 달라졌습니다. @ObservedObject는 객체의 objectWillChange를 구독하므로, 특정 프로퍼티를 body에서 읽지 않아도 같은 객체의 변경 알림으로 body가 다시 호출될 수 있습니다.


## 6. 여러 @Published를 묶으면 업데이트 범위가 넓어질 수 있습니다

```bash
// count 버튼 1번 클릭
SampleMultiPublishedDiffView: _viewModel changed.
PublishedCountView: _viewModel changed.
PublishedTitleView: _viewModel changed.
PublishedSubButton: _viewModel changed.
```

<div class="code-media-row" markdown="1">
```swift
final class MultiPublishedViewModel: ObservableObject {
    @Published var count = 0
    @Published var title = "Hello World"

    func increaseCount() {
        count += 1
    }
    
    func changeTitle() {
        title = ["SwiftUI", "Diffing", "Identity"].randomElement() ?? "SwiftUI"
    }
}

struct SampleMultiPublishedDiffView: View {
    @StateObject private var viewModel = MultiPublishedViewModel()

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            PublishedCountView(viewModel: viewModel)
    
            PublishedTitleView(viewModel: viewModel)
    
            PublishedSubButton(viewModel: viewModel)
        }
        .padding(24)
    }
}

struct PublishedCountView: View {
    @ObservedObject var viewModel: MultiPublishedViewModel

    var body: some View {
        let _ = Self._printChanges()
        Text("count: \(viewModel.count)")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct PublishedTitleView: View {
    @ObservedObject var viewModel: MultiPublishedViewModel

    var body: some View {
        let _ = Self._printChanges()
        Text(viewModel.title)
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct PublishedSubButton: View {
    @ObservedObject var viewModel: MultiPublishedViewModel

    var body: some View {
        let _ = Self._printChanges()
        Button {
            viewModel.increaseCount()
        } label: {
            Text("count 증가")
                .frame(maxWidth: .infinity)
        }
        .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 14.55.42](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 14.55.42.gif)
</div>

이 예제에서 count 버튼을 누르면 count만 바뀝니다. PublishedTitleView가 읽는 title은 그대로입니다.

하지만 count와 title은 같은 ObservableObject에 들어 있습니다. `@Published var count`가 바뀌면 MultiPublishedViewModel.objectWillChange가 발생하고, 이 객체를 관찰하는 View가 변경 알림을 받습니다.

PublishedTitleView가 title만 읽더라도 같은 viewModel을 @ObservedObject로 관찰하고 있다면, count가 바뀔 때 body를 다시 계산할 수 있습니다.

ObservableObject는 기본적으로 프로퍼티가 아니라 객체 단위로 변경 알림을 보냅니다. 여러 @Published 값을 하나의 ObservableObject에 모으면 관리하기는 편하지만 업데이트 범위가 넓어질 수 있습니다.


## 7. ForEach의 Identity가 흔들리면 하위 View의 State도 초기화될 수 있습니다

```bash
// 부모 업데이트 버튼 1번 클릭
ForEachIdentitySampleView: _tick changed.
UnstableIdentityRow: @self, @identity, _color changed.
UnstableIdentityRow: @self, @identity, _color changed.
UnstableIdentityRow: @self, @identity, _color changed.
```

<div class="code-media-row" markdown="1">
```swift
struct DiffItem: Identifiable {
    let id = UUID()
    let title: String
}

struct ForEachIdentitySampleView: View {
    @State private var tick = 0
    private let items = [
        DiffItem(title: "First"),
        DiffItem(title: "Second"),
        DiffItem(title: "Third")
    ]

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            Text("tick: \(tick)")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
    
            Button("부모 업데이트") {
                tick += 1
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    
            ForEach(items) { item in
                StableIdentityRow(title: item.title)
            }
    
            ForEach(items) { item in
                UnstableIdentityRow(title: item.title)
                    .id("\(item.id)-\(tick)")
            }
        }
        .padding(24)
    }
}

struct StableIdentityRow: View {
    let title: String
    @State private var color = Color.random

    var body: some View {
        let _ = Self._printChanges()
        Text("stable: \(title)")
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(color.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct UnstableIdentityRow: View {
    let title: String
    @State private var color = Color.random

    var body: some View {
        let _ = Self._printChanges()
        Text("unstable: \(title)")
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(color.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.05.06](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.05.06.gif)
</div>

ForEach는 identity로 각 row를 구분합니다. items가 안정적인 id를 가지고 있으면 SwiftUI는 이전 row와 현재 row를 같은 View로 연결할 수 있습니다.

이 예제에서는 row 내부에 `@State private var color = Color.random`을 두었습니다. row의 identity가 유지되면 @State 값도 유지되므로 부모 View의 tick이 바뀌어도 stable row의 배경색은 그대로입니다.

UnstableIdentityRow에는 `.id("\(item.id)-\(tick)")`를 붙였습니다. tick이 바뀔 때마다 row의 identity도 바뀌므로 SwiftUI는 이전 row와 현재 row를 같은 View로 연결하지 못합니다. 이때 row의 로컬 @State를 새로 만들 수 있고, color가 초기화되면서 배경색도 바뀝니다.

ForEach에서는 body 호출 횟수만 보기보다 identity가 로컬 State를 유지하는지 함께 봐야 합니다. identity가 안정적이면 row의 State를 이어받을 수 있습니다. 반대로 identity가 흔들리면 이전 row와 연결되지 않아 State가 초기화될 수 있습니다.


## 8. Equatable이 없어도 입력값이 같으면 하위 body 호출을 줄일 수 있습니다

```bash
// unrelated 버튼 1번 클릭
NonEquatableSampleView: _unrelated changed.

// count 버튼 1번 클릭
NonEquatableSampleView: _count changed.
PlainCounterView: _count changed.
```

<div class="code-media-row" markdown="1">
```swift
struct NonEquatableSampleView: View {
    @State private var count = 0
    @State private var unrelated = false

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            Text("unrelated: \(unrelated.description)")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
    
            PlainCounterView(count: count)
    
            Button("unrelated 변경") {
                unrelated.toggle()
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    
            Button("count 증가") {
                count += 1
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
        }
        .padding(24)
    }
}

struct PlainCounterView: View {
    let count: Int
    
    var body: some View {
        let _ = Self._printChanges()
        Text("count: \(count)")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.16.21](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.16.21.gif)
</div>

먼저 .equatable()을 사용하지 않은 경우를 살펴보겠습니다. unrelated가 바뀌면 NonEquatableSampleView.body를 다시 계산합니다. 이 과정에서 body 안의 `PlainCounterView(count: count)` 코드도 다시 실행되어 새로운 View 값을 만듭니다.

count 값이 그대로라면 PlainCounterView의 화면 결과도 달라지지 않습니다. SwiftUI는 이전 View와 현재 View의 입력값을 비교해 같다고 판단하면 하위 View의 body 호출이나 갱신을 줄일 수 있습니다.

그래서 이 예제에서는 .equatable()을 붙이지 않아도 PlainCounterView.body가 다시 호출되지 않는 것처럼 보입니다. 이 지점 때문에 .equatable()을 "body 호출을 막는 마법"처럼 설명하면 오히려 헷갈립니다.

Equatable을 직접 사용하지 않아도 SwiftUI가 입력값이 바뀌지 않은 하위 View를 다시 계산하지 않는 경우가 있습니다. 단순한 count 전달 예제만으로는 .equatable()의 차이가 선명하게 드러나지 않습니다.


## 8-1. .equatable()은 하위 View의 비교 기준을 명시합니다

```bash
// unrelated 버튼 1번 클릭
EquatableValueSampleView: _unrelated changed.

// count 버튼 1번 클릭
EquatableValueSampleView: _count changed.
EquatableValueCounterView: @self changed.
```

<div class="code-media-row" markdown="1">
```swift
struct EquatableValueSampleView: View {
    @State private var count = 0
    @State private var unrelated = false

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            Text("unrelated: \(unrelated.description)")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
    
            EquatableValueCounterView(count: count)
                .equatable()
    
            Button("unrelated 변경") {
                unrelated.toggle()
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    
            Button("count 증가") {
                count += 1
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
        }
        .padding(24)
    }
}

struct EquatableValueCounterView: View, Equatable {
    let count: Int

    var body: some View {
        let _ = Self._printChanges()
        Text("count: \(count)")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.21.04](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.21.04.gif)
</div>

.equatable()을 붙이면 SwiftUI는 EquatableValueCounterView를 비교할 때 View가 정의한 Equatable 기준을 사용합니다. 이 예제에서 EquatableValueCounterView는 count만 가지고 있으므로 Swift가 합성한 비교도 결국 count를 비교합니다.

unrelated만 바뀌면 부모인 EquatableValueSampleView.body를 다시 계산합니다. 하지만 EquatableValueCounterView에 전달하는 count는 그대로입니다. SwiftUI는 이전 EquatableValueCounterView와 현재 View가 같다고 판단하고, 하위 View의 body 호출이나 갱신을 줄일 수 있습니다.

반대로 count가 바뀌면 EquatableValueCounterView의 입력값도 달라집니다. 비교 결과가 다르므로 EquatableValueCounterView.body를 다시 계산합니다.

이 예제도 8번과 결과가 비슷해 보일 수 있습니다. count처럼 단순한 값 하나만 넘기면 SwiftUI가 .equatable() 없이도 비슷하게 최적화할 수 있기 때문입니다. .equatable()은 "항상 새로운 최적화를 켠다"기보다 하위 View 비교에 Equatable 기준을 사용하겠다고 명시하는 방법에 가깝습니다.


## 8-2. 클로저는 `==`을 직접 구현해 비교에서 제외합니다

```bash
// unrelated 버튼 1번 클릭
EquatableClosureSampleView: _unrelated changed.

// EquatableClosureCounterView 버튼 1번 클릭
EquatableClosureSampleView: _unrelated changed.

// count 버튼 1번 클릭
EquatableClosureSampleView: _count changed.
EquatableClosureCounterView: @self changed.
```

<div class="code-media-row" markdown="1">
```swift
struct EquatableClosureSampleView: View {
    @State private var count = 0
    @State private var unrelated = false

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            Text("unrelated: \(unrelated.description)")
                .frame(maxWidth: .infinity)
                .randomColorStyle()
    
            EquatableClosureCounterView(
                count: count,
                action: {
                    unrelated.toggle()
                }
            )
                .equatable()
    
            Button("unrelated 변경") {
                unrelated.toggle()
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    
            Button("count 증가") {
                count += 1
            }
            .frame(maxWidth: .infinity)
            .randomColorStyle()
        }
        .padding(24)
    }
}

struct EquatableClosureCounterView: View, Equatable {
    let count: Int
    let action: () -> Void

    static func == (lhs: EquatableClosureCounterView, rhs: EquatableClosureCounterView) -> Bool {
        lhs.count == rhs.count
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Button {
            action()
        } label: {
            Text("count: \(count)")
                .frame(maxWidth: .infinity)
        }
        .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.27.05](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.27.05.gif)
</div>

이번에는 EquatableClosureCounterView가 count와 action 클로저를 함께 받습니다. 클로저는 일반적인 값처럼 Equatable로 비교할 수 없으므로 Swift가 Equatable 구현을 자동으로 합성할 수 없습니다. 개발자가 `==`을 직접 구현해야 합니다.

action 클로저는 버튼을 눌렀을 때 실행할 동작입니다. 화면에는 `Text("count: \(count)")`가 표시되고, 이 예제에서 View의 시각적 결과를 결정하는 입력값은 count입니다.

따라서 `==` 구현에서는 action을 제외하고 count만 비교합니다. unrelated가 바뀌면 부모 body를 다시 계산하고 action 클로저도 새로 만들 수 있지만, count가 같다면 EquatableClosureCounterView의 화면 결과는 같습니다.

반대로 count가 바뀌면 `==`의 비교 결과도 달라집니다. 이때는 EquatableClosureCounterView.body를 다시 계산합니다.

.equatable()은 부모 body 호출을 막지 않습니다. 하위 View를 비교할 때 어떤 값을 기준으로 같은 결과라고 볼지 알려줍니다. 클로저처럼 비교할 수 없거나 화면 결과에 직접 영향을 주지 않는 값이 있다면 `==`을 직접 구현해 비교 대상에서 제외할 수 있습니다.


## 9. @Observable은 body에서 읽은 프로퍼티를 추적합니다

```bash
// 버튼 1번 클릭
ObservableMacroLightView: _model changed.

// 버튼 1번 클릭
ObservableMacroLightView: _model changed.
```

<div class="code-media-row" markdown="1">
```swift
import Observation
import SwiftUI

@Observable
final class ObservableLightModel {
    var isOn = true
    var title = "Hello World"

    func toggle() {
        isOn.toggle()
    }
}

struct SampleObservableMacroDiffView: View {
    @State private var model = ObservableLightModel()

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 20) {
            ObservableMacroTitleView(model: model)
    
            ObservableMacroLightView(model: model)
    
            ObservableMacroSubButton(model: model)
        }
        .padding(24)
    }
}

struct ObservableMacroTitleView: View {
    let model: ObservableLightModel

    var body: some View {
        let _ = Self._printChanges()
        Text(model.title)
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct ObservableMacroLightView: View {
    let model: ObservableLightModel

    var body: some View {
        let _ = Self._printChanges()
        Text(model.isOn ? "On" : "Off")
            .frame(maxWidth: .infinity)
            .randomColorStyle()
    }
}

struct ObservableMacroSubButton: View {
    let model: ObservableLightModel

    var body: some View {
        let _ = Self._printChanges()
        Button {
            model.toggle()
        } label: {
            Text("버튼")
                .frame(maxWidth: .infinity)
        }
        .randomColorStyle()
    }
}
```

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.29.58](/assets/img/2026-06-01-[SwiftUI] diff2/Simulator Screen Recording - iPhone 17 Pro Max - 2026-06-12 at 15.29.58.gif)
</div>

@Observable은 @ObservedObject처럼 객체 전체의 변경 알림만 구독하지 않습니다. SwiftUI는 body를 실행하는 동안 어떤 프로퍼티를 읽었는지 추적할 수 있습니다.

ObservableMacroTitleView는 model.title을 읽습니다. 버튼을 눌러 바뀌는 값은 model.isOn이므로 title을 읽는 View의 body는 다시 호출되지 않습니다.

ObservableMacroLightView는 model.isOn을 읽으므로 값이 바뀌면 ObservableMacroLightView.body를 다시 계산합니다.

ObservableMacroSubButton은 model을 가지고 있지만 body에서 model.isOn을 읽지 않습니다. 버튼 action 클로저에서 `model.toggle()`을 호출할 뿐입니다. action은 화면을 구성할 때가 아니라 이벤트가 발생할 때 실행되므로 body는 model.isOn에 직접 의존하지 않습니다.

@ObservedObject는 objectWillChange를 통해 객체 단위로 변경을 알립니다. @Observable은 body에서 읽은 프로퍼티를 기준으로 더 세밀하게 호출 범위를 좁힐 수 있습니다.


## 10. 실험으로 정리한 SwiftUI 업데이트 흐름

지금까지의 예제를 바탕으로 SwiftUI의 업데이트 흐름을 정리해 보겠습니다.

SwiftUI의 내부 구현은 모두 공개되어 있지 않습니다. 따라서 아래 흐름이 "항상 정확히 이 순서로만 동작한다"고 단정하기보다, 예제에서 관찰한 현상을 설명하는 개념 모델로 보는 편이 정확합니다.

상태 관리 방식에 따라 "어떤 View가 다시 계산 대상으로 잡히는가"가 다릅니다. @State, @ObservedObject, @Observable을 나눠서 살펴보겠습니다.

```text
// @State 값 변경
@State 변경
-> @State를 소유한 View의 body가 다시 호출될 수 있음
-> 그 body 안에서 자식 View 값들이 다시 만들어짐
-> 자식 View가 변경된 값을 body에서 읽거나, 입력값/identity가 달라졌다면 해당 자식 body가 다시 호출될 수 있음
-> 새로 계산된 View 값들을 기존 View Graph의 identity/dependency 정보와 맞춰 보며 업데이트 필요 여부를 판단
-> 필요한 부분만 실제 화면에 반영

// @ObservedObject / @StateObject의 @Published 값 변경
@Published 변경
-> objectWillChange 발생
-> 해당 객체를 관찰하는 View들이 업데이트 대상으로 잡힘
-> 해당 View들의 body가 다시 호출될 수 있음
-> 새로 계산된 View 값들을 기존 View Graph의 identity/dependency 정보와 맞춰 보며 업데이트 필요 여부를 판단
-> 필요한 부분만 실제 화면에 반영

// @Observable 프로퍼티 변경
@Observable 프로퍼티 변경
-> body에서 해당 프로퍼티를 실제로 읽은 View를 중심으로 업데이트 대상이 잡힘
-> 해당 View들의 body가 다시 호출될 수 있음
-> 새로 계산된 View 값들을 기존 View Graph의 identity/dependency 정보와 맞춰 보며 업데이트 필요 여부를 판단
-> 필요한 부분만 실제 화면에 반영
```

가장 중요한 구분은 body 호출과 실제 화면 반영이 같지 않다는 점입니다.

body가 다시 호출된다고 해서 곧바로 성능 문제가 생기지는 않습니다. SwiftUI는 body를 계산해 새로운 View 값을 만든 뒤, 이를 기존 View Graph의 identity, dependency, 저장 프로퍼티 정보와 맞춰 실제 업데이트가 필요한지 판단합니다. 이 diffing/reconciliation의 세부 구현은 개발자가 직접 제어할 수 없는 영역입니다.

개발자는 View와 dependency를 나누고 identity를 안정적으로 유지해 이 범위를 간접적으로 줄일 수 있습니다. 자식 body 호출이 줄어들면 하위 View Tree를 다시 계산하는 범위와 이후 diffing 후보도 함께 줄어들 수 있습니다.

목표는 "body 호출을 무조건 없애는 것"이 아닙니다. 바뀐 상태와 무관한 자식 View의 body 호출을 줄여 불필요한 View Tree 계산과 diffing 후보를 좁히는 것입니다.

부모 body가 다시 호출되어도 모든 자식 body를 반드시 다시 계산하지는 않습니다. 부모 body 안에서 자식 View 값을 다시 만들 수는 있지만, SwiftUI는 dependency와 identity, 비교 결과를 바탕으로 어떤 자식 body를 다시 계산할지 결정합니다.

@State가 바뀐 뒤 자식 View의 body를 다시 계산하는 대표적인 경우는 다음과 같습니다.

1. 자식 View가 바뀐 값을 body에서 직접 읽는 경우
2. 자식 View에 전달되는 입력값이 바뀌고, 그 값이 화면 결과에 영향을 주는 경우
3. `.id(...)`나 ForEach의 id가 바뀌어 자식 View의 identity가 달라지는 경우
4. if/switch 분기나 View 계층 변화로 자식 View의 Structural Identity가 달라지는 경우
5. 자식 View가 @State, @ObservedObject, @Environment 같은 dependency 변경을 감지한 경우

반대로 자식 View가 바뀐 값을 body에서 읽지 않고 identity와 비교 기준도 그대로라면, 부모 body가 다시 호출되어도 자식 body는 다시 호출되지 않을 수 있습니다. 4번 예제에서 ExtractSubButton이 @Binding을 가지고 있어도 body가 다시 호출되지 않은 이유입니다.

### View Tree, Render Tree, View Graph

SwiftUI의 업데이트 흐름을 이해하려면 세 구조를 나눠서 봐야 합니다.

View Tree는 body 호출 결과로 만드는 선언적 View 값입니다. Text, VStack, Button 같은 값이 모여 "화면이 이렇게 생겼으면 좋겠다"는 구조를 설명합니다. SwiftUI의 View는 대부분 값 타입이므로 body를 호출할 때마다 새로운 View 값을 만들 수 있습니다.

View Graph는 SwiftUI가 identity, state, dependency, layout을 연결하고 갱신하는 내부 관리 구조에 가깝습니다. @State가 어떤 View identity에 붙어 있는지, 어떤 body가 어떤 상태를 읽었는지 같은 정보는 선언적 View 값만으로 설명하기 어렵습니다.

Render Tree는 실제 화면에 가까운 구조입니다. UIKit/AppKit View, Layer처럼 렌더링할 수 있는 객체가 여기에 해당합니다. body를 호출할 때마다 전체를 새로 만들지 않고, diffing/reconciliation 결과에 따라 필요한 부분만 만들거나 갱신합니다.

상태 변경 이후 업데이트 흐름에서 각 구조가 어느 시점에 관여하는지 정리하면 다음과 같습니다.

1. 업데이트 트리거: @State 변경, objectWillChange, @Observable 접근 추적 등을 바탕으로 어떤 View의 body를 다시 계산할지 후보를 잡습니다.
2. body 호출: View Tree에 해당하는 선언적 View 값을 새로 만들 수 있습니다.
3. diffing/reconciliation: 새 View 값을 기존 View Graph의 identity/state/dependency 정보와 맞춰 실제 화면에 반영할지 판단합니다.
4. 화면 반영: 실제 변화가 필요하다고 판단한 부분만 Render Tree에 반영합니다.

invalidation은 문맥에 따라 뜻이 달라질 수 있습니다. objectWillChange처럼 body 재계산을 유발하는 변경 알림을 가리키기도 하고, diffing 이후 실제 화면 갱신 대상으로 판정하는 과정을 뜻하기도 합니다. 이 글에서는 혼동을 줄이려고 이를 "업데이트 트리거", "body 재계산", "화면 반영 대상 결정"으로 나누었습니다.

이를 초기 표시와 상태 변경 이후 업데이트 흐름에 대입하면 다음과 같습니다.

```text
초기 표시 단계
1. View 인스턴스 초기화
2. body 호출
3. body 결과로 선언적 View 값들이 만들어짐
4. SwiftUI가 이 View 값들을 기존/새 View Graph에 연결
5. layout, drawing, platform view/layer 반영을 거쳐 Render Tree가 생성 또는 갱신

상태 변경 이후 업데이트 단계
1. @State, objectWillChange, @Observable 접근 추적 등에 의해 body 재계산 후보가 잡힘
2. 대상 View의 body가 다시 호출됨
3. 새로운 선언적 View 값들이 만들어짐
4. SwiftUI가 새 View 값들을 기존 View Graph의 identity/state/dependency 정보와 맞춰 보며 화면 반영 여부를 판단함
5. 실제 변화가 필요한 부분만 Render Tree에 반영
```

View Tree에 해당하는 선언적 View 값은 자주 다시 만들 수 있지만, Render Tree 전체를 매번 새로 만들지는 않습니다. SwiftUI는 새 View 값을 기존 View Graph와 연결하고 identity와 입력값 변화를 확인한 뒤, 실제 화면에 필요한 변경만 반영합니다.

### 업데이트 대상으로 잡히는 기준

body는 View가 의존하는 값이 바뀌었을 때 다시 호출될 수 있습니다. 의존한다는 말은 단순히 프로퍼티를 가지고 있다는 뜻이 아닙니다. body를 계산할 때 그 값을 읽어 화면 결과에 반영한다는 뜻에 가깝습니다.

@State 예제에서는 @State를 소유한 View의 body가 다시 호출됐습니다. @Binding 예제에서는 Binding을 전달받았더라도 body에서 값을 읽지 않는 버튼 View를 다시 계산하지 않았습니다.

```swift
Text(isOn ? "On" : "Off") // body가 isOn을 읽는다.

Button {
    isOn.toggle()          // action 시점에만 isOn을 사용한다.
} label: {
    Text("버튼")
}
```

첫 번째 코드는 body가 isOn을 읽어 화면 결과를 만듭니다. isOn이 바뀌면 body 결과도 달라질 수 있습니다.

두 번째 코드는 isOn을 버튼 action 안에서만 사용합니다. action은 body가 화면을 구성할 때가 아니라 사용자가 버튼을 누를 때 실행됩니다. 따라서 버튼의 화면 결과는 현재 isOn 값에 직접 의존하지 않습니다.

### @ObservedObject와 @Observable의 차이

@ObservedObject는 프로퍼티가 아니라 객체 단위 변경 알림에 가깝습니다. ObservableObject 안의 @Published 값이 바뀌면 objectWillChange가 발생하고, 그 객체를 관찰하는 View가 변경 알림을 받습니다.

어떤 View가 viewModel.isOn을 화면에 직접 표시하지 않더라도 같은 viewModel을 @ObservedObject로 관찰하고 있다면 body를 다시 계산할 수 있습니다.

@Observable은 body를 실행하는 동안 실제로 읽은 프로퍼티를 추적할 수 있습니다. title만 읽는 View는 isOn 변경에 반응하지 않고, isOn을 읽는 View를 다시 계산합니다.

이 차이는 5번과 9번 예제를 비교하면 선명해집니다.

- @ObservedObject: 객체 변경 알림을 구독하는 View 단위로 body 호출 범위가 넓어질 수 있습니다.
- @Observable: body에서 읽은 프로퍼티를 기준으로 호출 범위를 더 좁힐 수 있습니다.

### Identity는 State를 어디에 붙여둘지 결정합니다

SwiftUI에서 identity는 "이전 View와 현재 View를 같은 대상으로 볼 수 있는가"를 판단하는 기준입니다.

identity에는 크게 두 가지 관점이 있습니다.

- Structural Identity: View 계층의 타입과 위치로 생기는 identity
- Explicit Identity: `.id(...)`나 ForEach의 id처럼 개발자가 명시하는 identity

ForEach 예제에서 row의 identity가 안정적이면 SwiftUI는 이전 row와 현재 row를 같은 대상으로 연결할 수 있습니다. 이때 row 내부의 @State도 유지됩니다.

반대로 `.id("\(item.id)-\(tick)")`처럼 tick이 바뀔 때마다 identity가 흔들리면 SwiftUI는 이전 row와 현재 row를 연결할 수 없습니다. 그러면 row에 붙어 있던 로컬 @State도 새로 만들 수 있습니다.

identity는 diffing 성능에만 영향을 주지 않습니다. @State를 유지하는 위치, View를 재사용하는 범위, 애니메이션을 연결하는 방식도 identity에 따라 달라집니다.

### Diffing과 Equatable

body를 다시 계산하면 SwiftUI는 새 View 값을 기존 View Graph의 정보와 맞춰 실제 업데이트가 필요한지 판단합니다. 이 과정을 흔히 diffing 또는 reconciliation이라고 부릅니다.

개념적으로는 다음과 같이 이해할 수 있습니다.

```swift
// 실제 SwiftUI 구현이 아니라 이해를 위한 의사코드
func shouldUpdate(oldView: ViewValue, newView: ViewValue) -> Bool {
    if viewUsesEquatableComparison {
        return oldView != newView
    }

    return compareStoredProperties(oldView, newView)
}
```

Equatable을 사용하지 않아도 SwiftUI는 단순한 값 변화를 내부에서 비교할 수 있습니다. count 같은 값 하나만 넘기는 예제에서는 .equatable()을 붙이지 않아도 하위 View의 body 호출이 줄어들 수 있습니다.

.equatable()의 의미는 "부모 body 호출을 막는다"가 아닙니다. "이 하위 View를 비교할 때 Equatable 기준을 사용하라"고 명시하는 방법입니다.

특히 클로저가 섞이면 비교 기준이 중요해집니다.

```swift
struct CellView: View, Equatable {
    let item: Item
    let action: () -> Void

    static func == (lhs: CellView, rhs: CellView) -> Bool {
        lhs.item == rhs.item
    }
}
```

클로저는 일반적인 값처럼 Equatable로 비교할 수 없습니다. action 클로저가 화면 결과를 결정하지 않고 item만 화면을 결정한다면 `==`에서 item만 비교하도록 기준을 정할 수 있습니다.

부모 body를 다시 계산하면서 action 클로저를 새로 만들더라도 item이 같다면 CellView의 화면 결과는 같다고 판단할 수 있습니다.

### 실전에서 가져갈 기준

이번 예제에서 확인한 기준은 다음과 같습니다.

1. body 호출과 실제 화면 반영은 서로 다른 단계입니다.
2. 상태를 가지고 있다는 사실보다 body에서 실제로 읽는지가 중요합니다.
3. @ObservedObject는 객체 단위로 변경을 알려 body 호출 범위가 넓어질 수 있습니다.
4. @Observable은 읽은 프로퍼티를 기준으로 더 세밀하게 반응할 수 있습니다.
5. ForEach에서는 안정적인 identity가 로컬 State 유지에 중요합니다.
6. .equatable()은 부모 body 호출을 막는 기능이 아니라 하위 View의 비교 기준을 명시하는 도구입니다.
7. 클로저를 하위 View에 넘길 때는 화면 결과를 결정하는 값과 이벤트 처리를 위한 값을 분리해서 생각해야 합니다.

결국 SwiftUI 성능을 볼 때 핵심은 "무엇이 바뀌었는가"보다 "어떤 View가 그 값을 읽고 있는가", "그 View의 identity는 유지되는가", "이전 View와 현재 View를 같은 결과로 볼 수 있는가"에 가깝습니다.


## 11. 팝팡에서는 Cell의 ViewModel 구독을 제거했습니다

<img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="80%">

팝팡에서는 리스트의 특정 Cell 하나만 바꿔도 여러 Cell의 body가 다시 호출되는 문제가 있었습니다.

기존에는 Cell이 ViewModel을 직접 관찰했습니다.

```swift
// MARK: - Cell (ViewModel 참조)
struct CellView: View {
    let item: Item
    @ObservedObject var vm: ListViewModel

    var body: some View {
        print("body 호출: \(item.id)")

        return HStack {
            Text(item.name)

            Spacer()

            Button {
                vm.toggleLike(id: item.id)
            } label: {
                Image(systemName: item.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(item.isLiked ? .red : .gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
```

이 구조에서는 여러 Cell이 같은 ListViewModel을 @ObservedObject로 관찰합니다. 특정 Cell의 좋아요 상태만 바뀌어도 ListViewModel.objectWillChange가 발생하고, 같은 객체를 관찰하는 Cell이 업데이트 대상에 포함될 수 있습니다.

Cell은 화면에 필요한 item뿐 아니라 변경 알림을 보내는 ViewModel 자체를 구독하고 있었습니다. 이 구조에서는 특정 item 하나만 바뀌어도 여러 Cell의 body를 다시 계산할 수 있고, 이후 diffing/reconciliation 후보도 넓어집니다.

Cell에서 @ObservedObject를 제거하고 화면 결과를 결정하는 값과 사용자 이벤트를 분리했습니다.

```swift
// MARK: - Cell (값 타입 데이터 + 액션)
struct CellView: View, Equatable {
    let item: Item
    let action: () -> Void

    static func == (lhs: CellView, rhs: CellView) -> Bool {
        lhs.item == rhs.item
    }

    var body: some View {
        print("body 호출: \(item.id)")

        return HStack {
            Text(item.name)

            Spacer()

            Button {
                action()
            } label: {
                Image(systemName: item.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(item.isLiked ? .red : .gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
```

변경 후 Cell은 ViewModel을 직접 관찰하지 않습니다. 화면을 그리는 데 필요한 item만 받고, 좋아요 버튼을 눌렀을 때 실행할 동작은 action 클로저로 상위 View에 위임합니다.

item은 화면 결과를 결정하고 action은 이벤트를 처리합니다. action 클로저는 Equatable로 비교할 수 없고, 부모 body를 다시 계산할 때마다 새로 만들 수 있습니다. 하지만 action 자체는 Cell의 현재 화면 결과를 결정하지 않습니다.

따라서 Equatable 구현에서는 item만 비교합니다.

```swift
static func == (lhs: CellView, rhs: CellView) -> Bool {
    lhs.item == rhs.item
}
```

부모 View의 body를 다시 계산해 CellView 값을 새로 만들더라도 item이 같다면 화면 결과가 같은 Cell로 판단할 수 있습니다. 좋아요 상태처럼 item의 화면 결과를 바꾸는 값이 달라지면 비교 결과도 달라지고, 해당 Cell을 다시 계산할 수 있습니다.

팝팡에는 다음과 같이 적용했습니다.

1. Cell에서 @ObservedObject를 제거했습니다.
2. Cell에는 화면 결과를 결정하는 값 타입 데이터만 전달했습니다.
3. 사용자 액션은 클로저로 상위 View에 위임했습니다.
4. Cell에 Equatable을 적용하고 클로저는 비교 기준에서 제외했습니다.
5. 변경과 무관한 Cell의 body 호출과 이후 diffing/reconciliation 후보 범위를 줄였습니다.

핵심은 Equatable 하나를 추가한 데 있지 않습니다. Cell이 구독하는 상태의 범위를 줄이고, 화면을 결정하는 값과 이벤트 처리를 분리한 것이 더 중요합니다.
