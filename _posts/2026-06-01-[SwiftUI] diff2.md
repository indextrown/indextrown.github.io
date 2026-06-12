---
title: "[SwiftUI] Diffing, 끝까지 파고들었습니다2."
tags:
  - Swift
header:
  teaser:
typora-root-url: ../
---

<!-- `Text("Hello World")`, `Text(isOn ? "On" : "Off")`, `Button` -->

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%" align="left"> -->

## Identity
[WWDC21 - Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/) 에서 Identity를 두 경우로 나누어서 설명한다.
- explicit identity (명시적 정체성)
- structual identity (구조적 정체성)

각각 간략히 말하자면 
- explicit identity는 사용자 정의 또는 데이터 기반 identity를 사용하는 것이고
- structual identity은 View hierachy에서 타입 및 위치에 따라 뷰를 구분하는 것이다.  

**참고**: 애플은 View의 프로퍼티를 뷰의 종속성(dependencies)이라고 지칭한다.

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

## 1. @State 프로퍼티가 변경되면 @State를 소유한 View의 body는 재호출된다.
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
`이 예제의 목적은 body가 재호출 될 때 랜덤 색상을 부여하는 것이다. diffing 이전의 단계임을 인지해야 한다.`
이 예제에서는 SampleDiffView.body 안에서 isOn을 읽고 있다.
따라서 버튼을 눌러 isOn이 변경되면 SampleDiffView의 body가 다시 평가된다.
이때 VStack 내부의 subview들이 모두 같은 identity를 갖는 것은 아니다.
<br>

#### SubView들은 Structural Identity를 가진다.
```swift
VStack(spacing: 20) {
    Text("Hello World")        // child 0
    Text(isOn ? "On" : "Off")  // child 1
    Button { ... }             // child 2
}
```
`Text("Hello World")`, `Text(isOn ? "On" : "Off")`, `Button`은 VStack 안에서 서로 다른 위치를 가지므로 각각 다른 Structural Identity를 가진다. 또한 두 번째 Text는 isOn 값에 따라 on/off를 보여주지만, 뷰의 위치와 타입은 그대로 유지된다. 즉, "On" 상태의 두 번째 Text와 "Off" 상태의 두 번째 Text는 같은 Structural Identity를 유지한다. 바뀌는 것은 identity가 아니라 Text의 입력 값이다.

<!-- 그런데 화면에서는 isOn과 직접 관련 없어 보이는 Text("Hello World")의 배경색도 함께 바뀐다. 이는 Text("Hello World")가 같은 identity를 가져서가 아니라, SampleDiffView.body가 다시 평가되면서 .randomColorStyle() 내부의 Color.random도 다시 실행되기 때문이다.

정리하면 다음과 같다.
- isOn 변경으로 SampleDiffView.body가 다시 평가된다.
- VStack 내부의 각 subview는 서로 다른 structural identity를 가진다.
- 두 번째 Text는 "On"과 "Off" 사이에서 같은 structural identity를 유지한다.
- Text("Hello World")의 배경색이 바뀌는 이유는 identity 때문이 아니라, body 재평가 과정에서 랜덤 색상이 다시 생성되기 때문이다. -->

## 2. Extract SubView: View의 일부 UI를 새로운 하위 View로 만들면 dependency을 읽지 않는 자식 body호출을 방지할 수 있다.
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

`ExtractSubView는 isOn을 직접 읽지 않는 독립적인 View이다.`
버튼을 누르면 SampleDiffView의 @State인 isOn이 변경되므로 SampleDiffView.body는 다시 평가된다.
하지만 ExtractSubView는 VStack 안에서 같은 위치에 같은 타입으로 유지되고, 내부에서 변경된 dependency(@State)를 읽지 않는다.  

#### 부연 설명
SwiftUI 입장에서는 ExtractSubView 안에서 @State 같은 dependency 값이 변하지 않았고, 이 예시에서는 애초에 그런 dependency를 가지고 있지도 않기 때문에 ExtractSubView.body를 다시 평가할 필요가 없다.
참고로 어떤 View의 body가 다시 평가되면, 그 이후 diffing 단계에서 SwiftUI는 identity 변화를 확인해 이전 View를 재사용할지 새 View로 취급할지 판단하고, 실제 화면 업데이트가 필요한 범위를 결정한다.
`핵심은 렌더링 단계가 가장 무겁지만, 위와 같은 구조에서는 개발자가 body 재평가 범위를 직접 줄여 불필요한 렌더링으로 이어지는 일을 막을 수 있다는 것이다.`

## 3. .id()로 View의 identity가 바뀌면 SubView도 다시 평가된다.
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
[공식문서](https://developer.apple.com/documentation/swiftui/view/id(_:)/) 에서 id가 변경되면 View의 Identity 가 변경된다고 한다.
버튼을 누르면 SampleDiffView의 @State인 isOn이 변경되므로 SampleDiffView.body가 다시 평가된다.
이때 ExtractSubView().id(UUID())도 다시 만들어지는데, UUID()는 매번 새로운 값을 만들기 때문에 ExtractSubView의 명시적 identity도 매번 달라진다.

즉 2번 예시에서는 ExtractSubView가 같은 위치에 같은 타입으로 유지되어 재사용될 수 있었지만, 3번 예시에서는 .id(UUID()) 때문에 SwiftUI가 이전 ExtractSubView와 현재 ExtractSubView를 같은 View로 보지 않는다. 그래서 ExtractSubView.body도 다시 평가되고, 실제 렌더링도 새로 일어나는 것처럼 보인다.

Self._printChanges()를 찍어보면 다음처럼 나올 수 있다.

```swift
SampleDiffView: @self, @identity, _isOn changed. // 뷰 초기화
SampleDiffView: _isOn changed.                   // 버튼 클릭
SampleDiffView: _isOn changed.                   // 버튼 클릭
```

여기서 _isOn changed는 @State 값인 isOn이 변경되어 SampleDiffView.body가 다시 평가됐다는 의미이다.
@self는 SampleDiffView라는 View 값 자체가 새로 만들어졌다는 의미이고, @identity는 SwiftUI가 SampleDiffView의 identity 변화를 감지했거나 identity 기준으로 View를 다시 연결했다는 의미로 볼 수 있다.
첫 출력은 SampleDiffView가 처음 구성되거나 identity 변화가 함께 감지된 상황이고, 이후 출력은 identity는 유지된 채 _isOn 변경만으로 SampleDiffView.body가 다시 평가된 상황이다.


## 4. Extract SubView: body에서 실제로 읽는 dependency가 바뀐 View만 body가 다시 호출된다.
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

- ExtractTitleView는 변경되는 dependency를 읽지 않기 때문에 body가 다시 호출되지 않는다.
- ExtractLightView는 @Binding var isOn: Bool을 가지고 있고, Text(isOn ? "On" : "Off")에서 isOn을 직접 읽는다. 따라서 isOn이 변경될 때마다 body가 다시 호출된다.
- ExtractSubButton도 @Binding var isOn: Bool을 가지고 있지만, 버튼을 누를 때 실행되는 action 클로저 안에서만 isOn.toggle()을 호출한다. 이 값은 화면을 그리는 body 안에서 직접 읽히는 값이 아니므로, isOn이 변경되어도 ExtractSubButton.body는 다시 호출되지 않는다.

여기서 중요한 점은 @Binding으로 값을 전달받았다는 사실만으로 body가 다시 호출되는 것은 아니라는 점이다.
SwiftUI에서 body가 다시 호출되는 기준은, body 안에서 해당 상태가 실제로 읽혔는지 여부에 가깝다.
ExtractLightView는 Text(isOn ? "On" : "Off")를 통해 isOn 값을 화면에 반영한다. 그래서 isOn이 바뀌면 화면 결과도 달라질 수 있고, SwiftUI는 ExtractLightView.body를 다시 호출한다.
반면 ExtractSubButton은 isOn을 버튼의 action 클로저 안에서만 사용한다. action 클로저는 body가 화면을 구성하는 시점이 아니라, 사용자가 버튼을 탭한 이벤트 시점에 실행된다. 따라서 ExtractSubButton의 화면 결과는 현재 isOn 값에 직접 의존하지 않는다.  

정리하면, @Binding 기반 예시에서는 상태를 “전달받는 것”과 상태를 “렌더링에 사용하는 것”이 다르다. SwiftUI에서 body 재호출의 기준은 단순한 상태 전달 여부가 아니라, body 안에서 해당 상태가 실제로 읽혀 화면 결과에 영향을 주는지에 가깝다.


## 5. @ObservedObject는 객체 변경 알림을 구독하기 때문에 body 호출 범위가 달라질 수 있다.

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

4번 예시에서는 @Binding var isOn: Bool을 가지고 있더라도, body 안에서 isOn을 직접 읽지 않는 ExtractSubButton.body는 다시 호출되지 않았다.

하지만 @ObservedObject는 동작 방식이 조금 다르다. ObservedLightView와 ObservedSubButton은 모두 같은 LightViewModel을 @ObservedObject로 관찰한다. viewModel.isOn이 변경되면 LightViewModel.objectWillChange가 발생하고, 이 객체를 관찰 중인 View들은 변경 알림을 받는다.

그래서 ObservedLightView처럼 body 안에서 viewModel.isOn을 직접 읽는 View는 당연히 body가 다시 호출된다. 그리고 ObservedSubButton처럼 viewModel을 버튼 action 클로저 안에서만 사용하더라도, @ObservedObject로 객체를 관찰하고 있기 때문에 viewModel의 변경 알림에 의해 body가 다시 호출될 수 있다.

반면 ObservedTitleView는 LightViewModel을 전달받지도 않고, 어떤 변경되는 dependency도 읽지 않는다. 그래서 버튼을 눌러 isOn이 변경되어도 ObservedTitleView.body는 다시 호출되지 않는다.

정리하면, @Binding은 값이 body 안에서 실제로 읽히는지에 따라 body 재호출 여부가 더 직접적으로 갈리는 반면, @ObservedObject는 객체의 objectWillChange를 구독한다. 따라서 같은 객체를 관찰하는 View라면, 특정 프로퍼티를 body 안에서 직접 읽지 않더라도 객체 변경 알림으로 인해 body가 다시 호출될 수 있다.


## 6. @Published 프로퍼티가 여러 개일 때 하나만 바뀌어도 같은 객체를 관찰하는 View의 body가 다시 호출될 수 있다.

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

이 예제에서 count 버튼을 누르면 실제로 변경되는 값은 count뿐이다. PublishedTitleView가 읽는 title은 바뀌지 않는다.

하지만 count와 title은 같은 ObservableObject 안에 들어 있다. @Published var count가 변경되면 MultiPublishedViewModel.objectWillChange가 발생하고, 이 객체를 관찰 중인 View들은 변경 알림을 받는다.

그래서 PublishedTitleView가 title만 읽고 있더라도, 같은 viewModel을 @ObservedObject로 관찰하고 있다면 count 변경 시 body가 다시 호출될 수 있다.

정리하면, ObservableObject는 기본적으로 프로퍼티 단위가 아니라 객체 단위로 변경 알림을 보낸다. 여러 @Published 값을 하나의 ObservableObject에 모아두면 편하지만, 변경 범위가 넓어질 수 있다.


## 7. ForEach에서 identity가 불안정하면 하위 View의 State가 유지되지 않을 수 있다.

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

ForEach는 각 row를 구분하기 위해 identity를 사용한다. items가 안정적인 id를 가지고 있으면 SwiftUI는 이전 row와 현재 row를 같은 View로 연결할 수 있다.

이 예제에서는 row 내부에 @State private var color = Color.random을 두었다. row의 identity가 유지되면 이 @State 값도 유지되기 때문에 부모 View의 tick이 바뀌어도 stable row의 배경색은 유지된다.

반면 UnstableIdentityRow에는 .id("\(item.id)-\(tick)")를 붙였다. tick이 바뀔 때마다 row의 identity도 바뀌므로 SwiftUI는 이전 row와 현재 row를 같은 View로 연결하지 못한다. 이때 row의 로컬 @State도 새로 만들어질 수 있고, color 값이 다시 초기화되면서 배경색이 바뀐다.

정리하면, ForEach에서는 body 호출 여부만 보는 것보다 identity가 로컬 State를 유지시키는지 확인하는 편이 더 명확하다. identity가 안정적이면 row의 State가 유지되고, identity가 흔들리면 SwiftUI가 이전 row를 이어받지 못해 State가 초기화될 수 있다.


## 8. Equatable을 사용하지 않아도 입력값이 그대로라면 하위 View의 body가 다시 호출되지 않을 수 있다.

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

먼저 .equatable()을 전혀 사용하지 않는 경우를 보자. unrelated가 바뀌면 NonEquatableSampleView.body는 다시 호출된다. 부모가 다시 호출되었기 때문에 body 안의 PlainCounterView(count: count) 코드도 다시 실행된다.

그런데 count 값이 그대로라면 PlainCounterView가 실제로 다시 계산되거나 갱신될 필요는 없다. SwiftUI는 이런 단순한 입력값에 대해 이미 이전 View와 현재 View를 비교하고, 결과가 같다고 판단하면 하위 View의 body 호출이나 갱신을 줄일 수 있다.

그래서 이 예제만 보면 .equatable()을 붙이지 않아도 PlainCounterView.body가 다시 호출되지 않는 것처럼 보일 수 있다. 이 지점 때문에 .equatable()을 "body 호출을 막는 마법"처럼 설명하면 오히려 헷갈린다.

정리하면, Equatable을 직접 사용하지 않아도 SwiftUI가 입력값이 변하지 않은 하위 View를 다시 계산하지 않는 경우가 있다. 따라서 단순한 count 전달 예제만으로는 .equatable()의 차이가 선명하게 드러나지 않을 수 있다.


## 8-1. .equatable()은 하위 View를 비교할 때 Equatable 기준을 사용하라고 명시하는 방법이다.

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

.equatable()을 붙이면 SwiftUI는 EquatableValueCounterView를 비교할 때 View가 가진 Equatable 기준을 사용할 수 있다. 이 예제에서는 EquatableValueCounterView가 count만 가지고 있으므로, Swift가 자동으로 만들어주는 Equatable 비교도 결국 count 비교가 된다.

unrelated만 바뀌면 부모인 EquatableValueSampleView.body는 다시 호출된다. 하지만 EquatableValueCounterView에 전달되는 count는 그대로다. 이 경우 SwiftUI는 이전 EquatableValueCounterView와 현재 EquatableValueCounterView가 같다고 판단할 수 있고, 하위 View의 body 호출이나 갱신을 줄일 수 있다.

반대로 count가 바뀌면 EquatableValueCounterView의 입력값 자체가 달라진다. 비교 결과가 달라졌기 때문에 EquatableValueCounterView.body는 다시 호출된다.

다만 이 예제도 8번과 결과가 비슷하게 보일 수 있다. count처럼 단순한 값 하나만 넘기는 경우에는 SwiftUI가 .equatable() 없이도 비슷하게 최적화할 수 있기 때문이다. 그래서 .equatable()의 의미는 "항상 새로운 최적화를 켠다"라기보다, 하위 View 비교에 Equatable 기준을 사용하겠다고 명시하는 쪽에 가깝다.


## 8-2. 클로저처럼 비교하기 어려운 값이 섞이면 ==을 직접 구현해 비교 기준에서 제외할 수 있다.

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

이번에는 EquatableClosureCounterView가 count뿐 아니라 action 클로저도 함께 받는다. 클로저는 일반적인 값처럼 Equatable로 비교할 수 없다. 그래서 이 상태에서는 Swift가 Equatable 구현을 자동으로 만들어줄 수 없고, 직접 ==을 구현해야 한다.

여기서 action 클로저는 버튼을 눌렀을 때 실행될 동작이다. 화면에 표시되는 값은 Text("count: \(count)")이고, 현재 예제에서 View의 시각적 결과를 결정하는 핵심 입력값은 count다.

그래서 == 구현에서 action은 비교하지 않고 count만 비교하도록 했다. unrelated가 바뀌면 부모 body가 다시 호출되고, action 클로저도 새로 만들어질 수 있다. 하지만 count가 같다면 EquatableClosureCounterView의 화면 결과는 같다고 볼 수 있다.

반대로 count가 바뀌면 ==의 비교 결과가 달라진다. 이때는 EquatableClosureCounterView가 다시 계산되어야 하므로 body가 다시 호출된다.

정리하면, .equatable()은 부모 body 호출을 막는 기능이 아니다. 더 정확히는 하위 View를 비교할 때 어떤 값을 기준으로 같다고 볼지 알려주는 장치에 가깝다. 특히 클로저처럼 비교하기 어렵거나, 화면 결과에 직접 영향을 주지 않는 값을 비교 대상에서 제외하고 싶을 때 직접 ==을 구현하는 방식이 의미가 있다.


## 9. @Observable은 body에서 실제로 접근한 프로퍼티를 기준으로 body 호출 범위를 좁힐 수 있다.

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

@Observable은 @ObservedObject와 달리 객체 전체의 변경 알림만 보는 방식이 아니다. SwiftUI가 body를 실행하는 동안 어떤 프로퍼티가 실제로 읽혔는지를 추적할 수 있다.

ObservableMacroTitleView는 model.title을 읽는다. 버튼을 눌러 바뀌는 값은 model.isOn이므로 title을 읽는 View의 body는 다시 호출되지 않을 수 있다.

ObservableMacroLightView는 model.isOn을 읽는다. 그래서 model.isOn이 바뀌면 ObservableMacroLightView.body는 다시 호출된다.

ObservableMacroSubButton은 model을 가지고 있지만, body 안에서 model.isOn을 읽지 않는다. 버튼 action 클로저에서 model.toggle()을 호출할 뿐이다. 이 경우 action은 렌더링 시점이 아니라 이벤트 시점에 실행되므로, body가 model.isOn에 직접 의존하지 않는다.

정리하면, @ObservedObject는 objectWillChange를 통해 객체 단위로 변경을 알리는 반면, @Observable은 body에서 실제로 접근한 프로퍼티를 기준으로 더 세밀하게 body 호출 범위를 줄일 수 있다.






