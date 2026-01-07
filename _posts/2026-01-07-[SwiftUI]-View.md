---
title: "[SwiftUI] Equatable, Identifiable" 
tags:
- SwiftUI
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<!-- ## SwiftUI는 뷰를 어떻게 구분하고 업데이트 하는가?
사전 지식으로 동등성(equality)와 동일성(Identity)가 필요하다. -->

## Equatable, Identifiable 요약
```swift
// id: 셀의 정체성 유지
// Equatable: 불필요한 리렌더링 방지
struct Item: Identifiable, Equatable {
    let id: UUID
    var title: String
}
```
- Equatable: 값이 같은가
- Identity: 같은 존재인가  

-> Equatable은 값 비교이고 Identifiable는 대상 식별이며 동일성은 id로 표현된다.



## List나 ForEach는 내부적으로 다음 플로우를 사용한다
```bash
1️⃣ Identifiable
   └─ 같은 Row인가?
      ├─ 아니면 → insert/delete/move
      └─ 맞으면 → 다음 단계

2️⃣ View 업데이트 판단
   ├─ Equatable 있음
   │    ├─ == true  → body skip
   │    └─ == false → body 재계산
   └─ Equatable 없음
        └─ 무조건 body 재계산
```
1. `Identifiable` 혹은 id로 판단
  - 같은 Row인가
  - insert/delete/remove 판단
2.  뷰 업데이트
  - `Equatable`을 채택하지 않은 경우
      -> 이전 view 새로운 view 비교할 방법이 없어서 비교를 포기하고 항상 해당 View와 자식 View들의 `body`를 다시 계산한다  
  - `Equatable` 채택한 경우  
      ->  `==`로 이전 view와 비교하여 같으면 자식 body 계산 생략하고 다르면 자식 body를 계산한다   

## Equatable는 선택적이지만 쓰면 이점이 있다
> Equatable이 없으면 같은 셀이어도 body는 항상 다시 계산되고,
Equatable이 있으면 내용이 같을 때 body 계산을 건너뛸 수 있다.

```swift
// ❌ Equatable 없음
// 상위 상태 변경
//  → List body 실행
//  → ForEach 실행
//  → 모든 RowView body 실행 ❗
struct RowView: View {
    let model: Item

    var body: some View {
        HeavyView(model: model)
    }
}
```
- 상위 View가 다시 그려지면 같은 id 셀이라도 RowView.body는 다시 실행된다
- 하지만 Heavy한 View에서는 문제가 된다.

```swift
// ✅ Equatable 있음
// 상위 상태 변경
//  → List body 실행
//  → ForEach 실행
//  → RowView == 비교
//      ├─ true → body skip
//      └─ false → body 실행
// 이전 RowView == 새로운 RowView ?
// ├─ true  → body 재계산 SKIP
// └─ false → body 재계산
struct RowView: View, Equatable {
    let model: Item

    static func == (lhs: RowView, rhs: RowView) -> Bool {
        lhs.model == rhs.model
    }

    var body: some View {
        HeavyView(model: model)
    }
}

RowView(model: model)
    .equatable()
```
- Equatable을 채택하면 아래와 같은 이점이 있다
줄어드는 것
- body 실행 횟수
- 내부 View 트리 생성
- Layout / Preference / Modifier 재평가
줄어들지 않는 것
- List의 diff 비교
- insert/delete/move판단
-> 즉 diff횟수는 감소되지 않고 render 판단 횟수가 감소한다

### 동등성(Equatable)
```swift
struct Person: Equatable {
    var name: String
    var age: Int
}

// Equtable은 값의 상태를 기준으로 비교하므로 두 인스턴스는 같다고 판단된다.
let user1 = Person(name: "홍길동", age: 25)
let user2 = Person(name: "홍길동", age: 25)
user1 == user2  // true
```
```swift
// 속성들이 Equatable이므로 컴파일러가 자동으로 만들어줌
static func == (lhs: Person, rhs: Person) -> Bool {
    lhs.name == rhs.name &&
    lhs.age == rhs.age
}
```
> 값 타입에서는 서로 다른 인스턴스라도 두 값의 전체 상태가 같거나 혹은 정의한 비교 규칙에 따라 일부 상태가 같다고 판단되면 동등하다

### Equatable 자동 완성 조건
- 타입이 struct 또는 enum이고
- 모든 저장 프로퍼티(또는 연관값)가 Equatable이고 
- 개발자가 `==` 을 직접 구현하지 않은 경우 컴파일러가 `==` 를 자동 합성한다.
-> 자동 합성된 `==`는 모든 저장 프로퍼티를 비교한다
-> 비교 기준을 일부 속성으로 제한하고 싶다면 `==`를 직접 구현해 커스텀 비교가 가능하다


### 동일성(Identity)
> 내부 상태가 달라도 같은 대상을 가리키는지를 의미한다

```swift
struct Person: Equatable {
    var name: String
    var age: Int
    var state: String
}
let user1 = Person(name: "홍길동", age: 25, state: "기분 좋음")
let user2 = Person(name: "홍길동", age: 25, state: "기분 나쁨")
user1 == user2 // false
```
- 이름도 같고 나이도 같기 때문에 같은 사람이라고 생각할 수 있다
- 하지만 Equatable로 비교하면 상태가 다르기 때문에 다르다고 나온다
- 만약 이 둘을 동일한 사람으로 생각하려면 같은 사람으로 식별할 무언가가 필요하다
- 주민등록번호같은 유일한 식별자가 필요하다
-> 이처럼 값의 상태만으로는 같은 대상을 판단할 수 없는 경우 동일성을 표현할 방법이 필요하다

### Identifiable 탄생
```swift
protocol Identifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}
```
- Identifiable는 값의 내용과 무관하게 대상을 구분하기 위한 고유 식별자를 제공한다.

### Identifiable 예제
```swift
struct Peron: Equatable, Identifiable {
    var id: String
    var name: String
    var age: Int
    var state: String
}
let user1 = Person(id: "고유식별자1", name: "홍길동", age: 25, state: "기분 좋음")
let user2 = Person(id: "고유식별자1", name: "홍길동", age: 25, state: "기분 좋음")
user1.id == user2.id  // true
```
- 두 값의 상태는 다르지만 
- id가 같기 때문에 같은 대상으로 판단할 수 있다
- 이 경우 두 값은 동일성(identity)이 같다


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