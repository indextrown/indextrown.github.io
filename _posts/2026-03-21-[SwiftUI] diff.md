---
title: "[SwiftUI] Diffing, 끝까지 파고들었습니다."
tags:
  - RxSwift
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->
  
<!-- <img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%" align="left"> -->


blue > "왜 특정 셀 하나만 바꿨을 뿐인데, 전체가 다시 그려질까?" <br/>
blue > PopPang 서비스를 개발하던 중, 특정 화면에서 메모리가 계속 증가하는 문제를 발견했습니다.  
blue > 처음에는 단순히 데이터 양이 많아서 생기는 현상이라고 생각했습니다.  
blue > 하지만 원인을 따라가다 보니, 문제는 전혀 다른 곳에 있었습니다.  
blue > 이 글에서는 그 문제를 어떻게 정의했고, 어떤 기준으로 해결했는지를 공유합니다.

## 문제: 셀 하나만 변경되도 모든 셀이 다시 그려진다
<img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="80%">
- 리스트의 특정 셀 좋아요룰 눌렀는데 전체 리스트의 Body가 다시 호출됨
- 스크롤 시 버벅임 + 메모리 증가 발생

---

## 의문
- SwiftUI는 왜 이렇게 많이 다시 그릴까?
- Diffing은 정확히 어떻게 동작할까?
- 내가 뭘 잘못 쓰고 있는 걸까?
👉 여기서부터 **Diffing을 끝까지 파보기 시작했습니다**

---

## SwiftUI 3가지 세계
1. View Tree: 선언적 트리
```swift
var body: some View {
      VStack {
          Text("Hello")
          Image(systemName: "star")
          Button("Tap") { … }
      }
}
```
- 개발자가 작성한 선언적 구조로 실제 UI가 아니라 값(value)일 뿐입니다.
- View는 struct 값 타입이며 매번 body가 호출될 때 새 View Tree가 만들어집니다.

2. Render Tree: 실제 화면에 표시되는 뷰 계층
- SwiftUI가 실제 화면에 그리기 위해 사용하는 내부 자료 구조입니다.
- UIKit의 UIView, Core Animation Layer, CoreGraphics 등을 포함하는 실제 렌더링 가능한 객체들의 구조입니다.
- SwiftUI는 **View Tree를 기반으로 RenderTree를 생성하고** **이전 Render Tree와 Diffing을 수행하여 필요한 부분만 업데이트**합니다.

3. View Graph: 상태/환경/레이아웃을 유지하는 내부 객체
- View Tree와 Render Tree 사이에서 상태(State), 환경(Environment), Layout 정보를 관리하는 구조체 집합입니다.  

이 중 성능 최적화에서 가장 중요한 것은 **SwiftUI에서 View Tree 전체를 재생성하지만 Render Tree는 Diffing을 통해 필요한 부분만 갱신합니다.**

---

## Body 재계산 규칙: 언제 invalidate 되는가?
**invalidate**: 이 View는 더이상 유효하지 않으니 다시 렌더링 하라고 표시하는 것입니다.
다음 중 하나라도 변경되면 body가 다시 계산됩니다.
```swift
1) @State 값 변경
2) @Binding 값 변경
3) @StateObject가 참조하는 ObservableObject에서 @Published 값 변경
4) Environment 값 변경
5) 부모 View의 body가 재계산되면서 이 View의 body도 재계산되는 경우
6) .id(), .animation(), .task(id:) 등 identity/behavior modifier가 변경 
```

<img src="{{ '/assets/img/2026-03-21-[SwiftUI] lifecycle/img.png' | relative_url }}" alt="이미지" width="100%">
blue >  중요한 점은 body 재계산 != 리렌더링 ❗ <br/>
blue > body 재계산 -> 새로운 View Tree 생성 -> Diffing -> Render Tree 업데이트  <br/>
blue > 만약 Diffing에서 **같다**로 판단되면 UI는 다시 그려지지 않습니다.

---

## Body Recompute와 Render Update의 차이
```swift
var body: some View {
    Text("Hello")
}
```
부모에서 State가 바뀌어 이 뷰의 body가 10번 재계산되더라도  
Text("Hello")는 항상 같은 값이므로 Render Tree는 변화 없음으로 판단됩니다.

## Invalidation 범위
Invalidation은 특정 View를 “무효화”하여, 다음 업데이트 사이클에서 body를 다시 계산하도록 표시하는 과정입니다. SwiftUI에서 Invalidation는 "상태가 바뀐 View와 그 하위"만 영향을 받습니다.
하지만
- 어떤 경우에는 부모 -> 자식 전체가 재계산되고
- 어떤 경우에는 자식 뷰만 재계산됩니다.

## 핵심 규칙
**@State는 해당 view struct에서만 invalidation을 일으킨다**
**@ObservedObject는 이 뷰뿐 뿐만 아니라 바인딩된 모든 자식에게도 invalidation 전파한다**
**@StateObjedt는 View 재생성에도 살아남지만 invalidation 전파는 ObservableObject 기반이다**
- 정리하자면 작은 뷰에 @ObservedObject를 넣는 것은 위험하다
- 큰 뷰는 상태를 최대한 분리해 invalidation을 최소화해야 한다

## 기존 팝팡 예시
```swift
// MARK: - Cell (ViewModel 참조)
struct CellView: View {
    
    let item: Item
    @ObservedObject var vm: ListViewModel   // ⭐️ 모든 셀이 같은 vm 구독
    
    var body: some View {
        print("🔥 body 호출: \(item.id)")
        
        return HStack {
            Text(item.name)
            
            Spacer()
            
            Button {
                vm.toggleLike(id: item.id)   // ⭐️ ViewModel 메서드 호출
            } label: {
                Image(systemName: item.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(item.isLiked ? .red : .gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - View
struct ContentView: View {
    
    @StateObject private var vm = ListViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.items) { item in
                    CellView(item: item, vm: vm)   // ⭐️ 동일 vm 전달
                }
            }
            .padding()
        }
    }
}
```
- 문제: 모든 셀이 동일한 @ObservableObject를 구독하면서 단일 상태 변경에도 objectWillChange가 전체 View invalidation을 유발하여 리스트 전체가 다시 렌더링되는 문제가 발생
- 원인: @ObservableObject는 상태 변경 시 diffing 결과와 관계없이 구독 중인 모든 View의 body를 재호출하며, 이로 인해 Identifiable / Equatable 기반의 렌더링 최적화가 무력화됨
- 즉 @ObservableObject를 Cell에서 직접 구독하면 diffing 최적화가 동작하지 않는다


## 요약
**@State**
- View struct 하나만 invalidation
- 가장 안전하고 가벼움

**@Binding**
- 부모 State 변경 시 자식도 invalidation
- 지나친 중첩은 body 경쟁을 유발

**@ObservedObject**
- @Published 변경 시 연결된 모든 View 트리가 invalidation
- 성능 문제의 주범이 되는 경우가 많음

**@StateObject**
- ObservableObject의 생명주기는 유지
- invalidation은 @ObservedObject와 동일
- “큰 변경”이 있는 객체는 자식뷰로 분리하는 것이 맞다

## Reference
- https://lzufs.tistory.com/2
- https://kka7.tistory.com/670
- https://green1229.tistory.com/563
- https://green1229.tistory.com/589
- https://eunjin3786.tistory.com/559
- https://medium.com/@mini-min/swiftui-ios-17-부터-새로워진-swiftui의-observation-상태-관리-이해하기-observable-bindable-cab86b79bad3








<!-- ## SwiftUI View 성능
View 생명주기를 살펴보면 **Updating Phase의 Diffing 단계**가 가장 중요합니다.
SwiftUI Diffing은 공식적으로 상세한 구현이 공개되어 있지 않지만 우리가 알 수 있는 것은 SwiftUI 모든 뷰를 매번 다시 렌더링 하지 않는다는 것입니다. 내부적으로 이전 View 트리와 새로운 View 트리를 비교하여 **변경된 부분만 다시 렌더링**하여 만약 새 값이 이전 값과 동일한 경우 **업데이트를 방지할 수 있습니다.**
변경된 값이 같으면 뷰가 제렌더링되지 않게 하기 위해 **View Equatable을 채택시키면 Diffing(비교) 과정을 개발자가 관리할 수 있습니다** -->

<!-- 
## ⚙️ SwiftUI Diffing의 핵심
SwiftUI는 상태가 바뀌면 이렇게 동작합니다.
```swift
// invalidation: 재계산 트리거
[1단계: 업데이트 트리거]
1. 상태 변경 감지 (@State, @ObservedObject 등)
2. 해당 View가 invalidation됨 (body 재계산 필요 표시)

[2단계: 렌더링 & Diffing]
3. 업데이트 사이클에서 body 실행 → 새로운 View 트리 생성
4. 이전 View 트리와 diffing 수행 (하위 View까지 재귀적으로 비교)
5. 변경된 부분만 실제 UI에 반영
``` -->



<!-- ## 고민했던 문제
SwiftUI를 사용하면서 이런 경험을 한번 쯤 하게 됩니다.  
1. List 스크롤 시 왜 버벅거리지?
2. 특정 셀의 상태만 변경되도 왜 전체 화면이 다시 그려지지?
3. ForEach에서 id: \.self를 쓰면 안된다는데 정확히 이유가 뭐지?
4. 에어비엔비는 15% 렌더링 성능 개선을 어떻개 했을까?

## SwiftUI가 화면을 그리는 기본 메커니즘
> SwiftUI는 선언형 UI 프레임워크로 상태가 변경될 때마다 새로운 뷰 트리를 생성하고 이전 뷰 트리와 두 단계로 diffing하여 필요한 부분만 실제 UI에 반영합니다.
```swift
// 상태
``` -->