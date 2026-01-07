---
title: "[SwiftUI] View" 
tags:
- SwiftUI
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

## View
```swift
@MainActor @preconcurrency
protocol View
```
> SwiftUI의 View는 화면 그 자체가 아니라 이 상태라면 이런 화면이어야 한다는 설계도(설명값)이다.  

SwiftUI는 state-driven(언제 UI가 바뀌는가), data-driven(UI를 무엇으로 표현하는가)   
UI 프레임워크로 state가 변경되면 View의 body가 다시 평가되며 이전 View 트리와 새로운 View 트리를 diff한 결과에 따라 필요한 UI만 업데이트한다.



1. View 값 생성
  ```swift
  var body: some View {
        VStack {
            Text("Hello")
            Button("Tap") {}
        }
  }
  ```
  - body 실행
  - View Struct 값 생성
  - 아직 화면에는 아무것도 안그려짐
2. View 트리 구성
  ```bash
  // SwiftUI는 body 결과를 모아서 이런 구조를 만든다
  VStack
 ├─ Text("Hello")
 └─ Button("Tap")
  ```
  
3. 이전 트리와 diff
  ```swift
  // Text는 같고 내용만 바뀜(전체 다시그리지 않고 부분 업데이트)
  Text("Hello") → Text("World")
  ```
  - 이전 View Tree vs 새 View Tree
  - SwiftUI는 View 타입, 위치, identity(id), View 입력값을 비교한다
4. 내부 Render Tree 갱신
  - SwiftUI는 View Tree를 Render Tree로 그린다
  - 레이아웃 계산
  - 애니메이션
  - 트랜지션
  - 접근성
  - hit testing
5. UIKit / AppKit View 업데이트
  - 여기서 실제 화면 객체가 등장한다
  - iOS → UIKit (UIView)
  - macOS → AppKit (NSView)

## SwiftUI는 뷰를 어떻게 구분하고 업데이트 하는가?
사전 지식으로 동등성(equality)와 동일성(Identity)가 필요하다.

### 사전지식이 필요한 이유
> UIKit은 클래스 타입이기 때문에 뷰를 할당하므로 얻는 포인터가 그 뷰의 명시적 ID가 될 수 있다.  
SwiftUI는 값 타입이기 때문에 이런 값을 지속적으로 사용할 수 없다.
그래서 Identity가 등장하게 되었고 데이터 및 업데이트 주기에 영향을 미친다.
  
SwiftUI는 값타입이다. 값타입은 복사에 의해 값이 전달되므로 원본을 변경하지 않고 각각의 복사본이 독립적으로 존재하게 된다. 변수에 값을 할당하거나 함수에 인자로 전달할 때 원본이 아닌 독립된 복사본이 생성된다. 각 복사본이 메모리 상의 다른 위치에 존재한다는 뜻이며 이러한 특성으로 해당 뷰를 지속적으로 추적하기 힘들다.
  
만약 SwiftUI가 내부적으로 뷰의 메모리 주소를 ID를 사용한다면 뷰가 재생성 될 때마다 새로운 id가 할당된다. SwiftUI는 뷰의 상태와 속성의 변화를 감지하고 변화된 부분만 효율적으로 업데이트한다.
뷰의 새로운 상태외 이 전상태를 비교하게 되는데 이때 id가 다르다면 상태 비교가 불가능하게 된다.

### View Identity
- 명시적(Explicit) Identity
- 구조적(Structural) Identity

### 명시적(Explicit) Identity
```swift
List {
    ForEach(viewModel.searchResults, id: \.resultId) { result in
        // 
    }
}
```
- 직접 id를 설정해준다
- 하지만 사소한 뷰 하나하나 id를 설정하는건 비효율적이다

### 구조적(Structural)Identity
```swift
struct MainView: View {
    var body: some View {
        if users.isEmpty {
            EmptyView()
        } else {
            UserListView()
        }
    }
}
```
- SwiftUI는 뷰 계층구조를 사용해 함시적 Identity를 생성한다
- 전반에 걸쳐 구조적 Id를 생성하므로 모든 뷰의 id를 생성할 필요가 없다.

## Reference
- [https://green1229.tistory.com/589](https://green1229.tistory.com/589)
- [https://hasensprung.tistory.com/133](https://hasensprung.tistory.com/133)
- [https://eunjin3786.tistory.com/m/559](https://eunjin3786.tistory.com/m/559)
- [https://developer.apple.com/documentation/swiftui/view](https://developer.apple.com/documentation/swiftui/view)
- [https://eunjin3786.tistory.com/560](https://eunjin3786.tistory.com/560)
- [https://terry-some.tistory.com/133](https://terry-some.tistory.com/133)
- [https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [https://developer.apple.com/documentation/swiftui/view](https://developer.apple.com/documentation/swiftui/view)
- [https://developer.apple.com/swiftui/](https://developer.apple.com/swiftui/)
- [https://clamp-coding.tistory.com/519](https://clamp-coding.tistory.com/519)
- [https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
- [https://eunjin3786.tistory.com/560](https://eunjin3786.tistory.com/560)
- [https://lzufs.tistory.com/2](https://lzufs.tistory.com/2)