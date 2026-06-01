---
title: "[SwiftUI] Diffing, 끝까지 파고들었습니다2."
tags:
  - Swift
header:
  teaser:
typora-root-url: ../
---

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

## 0. body 재호출 디버깅을 위한 랜덤 배경색 부여 헬퍼 메서드
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

## 1. View의 Dependency가 Bool타입일 때
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
이 예제에서는 SampleDiffView.body 안에서 isOn을 읽고 있다.
따라서 버튼을 눌러 isOn이 변경되면 SampleDiffView의 body가 다시 평가된다.
이때 VStack 내부의 subview들이 모두 같은 identity를 갖는 것은 아니다.
<br>

```swift
VStack(spacing: 20) {
    Text("Hello World")        // child 0
    Text(isOn ? "On" : "Off")  // child 1
    Button { ... }             // child 2
}
```
*Text("Hello World")*, Text(isOn ? "On" : "Off"), Button은 VStack 안에서 서로 다른 위치를 가지므로 각각 다른 structural identity를 가진다. 또한 두 번째 Text는 isOn 값에 따라 on/off를 보여주지만, 뷰의 위치와 타입은 그대로 유지된다. 즉, "On" 상태의 두 번째 Text와 "Off" 상태의 두 번째 Text는 같은 structural identity를 유지한다. 바뀌는 것은 identity가 아니라 Text의 입력 값이다.

그런데 화면에서는 isOn과 직접 관련 없어 보이는 Text("Hello World")의 배경색도 함께 바뀐다. 이는 Text("Hello World")가 같은 identity를 가져서가 아니라, SampleDiffView.body가 다시 평가되면서 .randomColorStyle() 내부의 Color.random도 다시 실행되기 때문이다.

정리하면 다음과 같다.
- isOn 변경으로 SampleDiffView.body가 다시 평가된다.
- VStack 내부의 각 subview는 서로 다른 structural identity를 가진다.
- 두 번째 Text는 "On"과 "Off" 사이에서 같은 structural identity를 유지한다.
- Text("Hello World")의 배경색이 바뀌는 이유는 identity 때문이 아니라, body 재평가 과정에서 랜덤 색상이 다시 생성되기 때문이다.

따라서 이 예제는 “state가 바뀌면 모든 subview가 같은 identity라서 다시 그려진다”를 보여주는 예제가 아니다.
오히려 “state 변경으로 body가 다시 평가되고, 그 과정에서 body 내부의 표현식도 다시 실행된다”는 것을 보여주는 예제에 가깝다.