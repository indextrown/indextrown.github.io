---
title: "[ReactiveX] 1. 반응형 프로그래밍이란?"
tags: 
- ReactiveX
- RxSwift
- Combine
header: 
  teaser: /assets/img/2025-03-25-[RxSwift]-RxSwift-1/image.png
typora-root-url: ../
---

<img src="{{ '/assets/img/2025-03-25-[RxSwift]-RxSwift-1/image.png

' | relative_url }}" alt="커스텀셀" width="70%">

## 1. ReactiveX란 무엇인가?
RxSwift를 알기 위해 ReactiveX에 대해 알아야 한다.
ReactiveX 혹은 Reactive Extension, 혹은 Rx라고도 부른다. 
Rx는 마이크로소프트에서 개발한 비동기 이벤트를 핸들링해주는 오픈소스 라이브러리이다.

Rx 공식 홈페이지에서는 다음과 같이 설명한다.
> An API for asynchronous programming
with observable streams

### 옵저버 패턴
Rx는 비동기 이벤트 핸들링을 위해 Observer(옵저버) 디자인 패턴을 사용한다.
> Observer 패턴이란 관찰자(옵저버)가 대상이 되는 객체를 등록 함으로서 해당 객체의 상태 변화를 관찰하고 관찰 대상인 객체가 상태 변화로 이벤트를 발생시킬 때 이 이벤트를 감지하여 처리한다.

이런 옵저버 패턴은 네트워크 통신과 같은 비동기 이벤트와 함께 사용하면 좋은 궁합을 보여주는 데, 네트워크 통신과 같이 비교적 시간이 오래 걸리는 작업으로 값이 미래에 준비되는 상황에서 값이 준비될 때까지 대상을 관찰하다가 값이 도착했을 때 도착한 것을 감지하고 처리할 수 있다. Rx에서는 이런 관찰자를 Observer, 관찰 가능한 대상을 Observable 라고 한다.

### Q. 비동기 이벤트는 옵저버 패턴이 아니라도 단순 escaping 클로저로 가능한거 아닌가?
escaping 클로저로도 비동기 이벤트를 처리할 수는 있지만, escaping 클로저의 가장 큰 단점은 연쇄적인 비동기 이벤트가 발생하였을 때 중첩된 형태의 클로저는 코드의 가독성 저해와 개발자의 실수를 유발시키는 요인이 될 수 있다.

```swift
// 콜백지옥 예시
// 콜백지옥 예시
func fetchUser(completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion("User123")
    }
}

func fetchPosts(for user: String, completion: @escaping ([String]) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion(["Post1", "Post2"])
    }
}

func fetchComments(for post: String, completion: @escaping ([String]) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion(["Comment1", "Comment2"])
    }
}

// 중첩된 콜백지옥
fetchUser { user in
    print("Fetched user: \(user)")
    fetchPosts(for: user) { posts in
        print("Fetched posts: \(posts)")
        fetchComments(for: posts[0]) { comments in
            print("Fetched comments: \(comments)")
            // 계속 중첩된다면...
        }
    }
}
```

Rx는 비동기 이벤트 핸들링을 위한 간단하고 강력한 기능을 제공하는데, Rx의 Observable는 데이터 변화에 대한 값을 방출하는 data flow, 즉 Stream을 만들어 낼 수 있다. 이러한 Stream은 데이터를 전달할 수 있는 통로를 만들어 Observer에게 전달될 수 있도록 한다.
Rx가 좀 더 강력한기능을 제공할 수 있는 이유는 Stream을 통과 하면서 다양한 Operator(연산자)를 거치면 데이터를 입맛에 맞게 조작하거나 변형을 가해서 Obserber에게 전달할 수 있기 때문이다.



## 2. 반응형 프로그래밍이란?
데이터의 흐름 및 변경사항을 전파하는 데 중점을 둔 프로그래밍 패러다임이다.   
이 패러다임을 사용할 경우, 주변 환경/데이터 변화가 생길 때 연결된 실행 모델들이 이 이벤트를 받아 동작하도록 설계하는 방식이다. 

- **선(→)** : 데이터가 흐르는 경로이며, **Observable**이라고 부른다.
- **점(●)** : 시간에 따라 발생하는 **이벤트(Event)** 하나를 의미한다.
- **debounce 박스** : 이벤트를 필터링하는 **Operator(연산자)**로, 너무 잦은 이벤트를 제어한다.
- **아래쪽 선** : `debounce` 이후 실제로 **구독자에게 전달되는 결과 흐름**을 보여준다.  

### 비유로 설명
자동차(Event)들이 도로(Ovservable)를 따라 달리고 있을 때,
교통경찰 역할을 하는 debounce가 너무 많은 차를 제어해준다.  
지나치게 빠르게 지나가는 차들은 걸러내고, 일정 시간 동안 마지막으로 지나간 차(이벤트)만 통과시킨다.  
즉 이벤트가 여러 번 발생하더라도 debounce를 통과한 이벤트만 최종적으로 전달한다.


## 3. RxSwift란?
Reactive Extension/Programming + Swift로, 관찰 가능한 시퀀스를 사용하여 비동기 및 이벤트 기반 프로그램을 구성하기 위한 라이브러리다.  

Swift는 함수형 프로그래밍(Functional Programming) 패러다임을 강조하는 언어이다.   
이에 RxSwift는 반응형 프로그래밍(Reactive Programming)을 더하여, Swift에서 FRP(Functional Reactive Programming)을 따를 수 있도록 한다.  
즉 Swift를 반응형 프로그래밍 하는 것이다.

### 예시
```swift
Observable
    .combineLatest(firstName.rx.text, lastName.rx.text) {  $0 + " " $1 }
    .map { "Greetings, \(#0)" }
    .bind(to: greetingLabel.rx.text)
    .disposed(by: DisposeBag)
```
- comBineLatest나 map을 RxSwift에서 Operator라고 부른다.
- 이러한 연산자를 사용해서 이벤트의 값을 여러 형태로 조합하거나 변경할 수 있다.
- 또한 MVVM패턴을 적용할 때 View와 ViewModel을 연결해주는, 데이터 바인딩을 수행해야 한다.  
이때 bind(정확히 말하자면 bind는 RxCocoa이다) 연산자를 사용하여 쉽게 바인딩이 가능하다.   
DisoatchQueue에서 직접 조정해야 했던 작업들을 자동으로 처리해준다.

## 4. RxSwift 사용 목적
```swift
func doSomethingIncredible(forWho: String) throws -> IncredibleThing

// 재시도
doSomethingIncredible("me")
    .retry(3)
```
- API 통신을 하다보면, 성공할 때도 있지만 실패할 때도 분명 존재한다.
- 실패시 단순히 끝나는게 아니라 3번 정도 재시도 할 수 있다면 좋겠지만 재시도 코드는 많이 복잡하고, 재사용하기도 어렵다.
- RxSwift를 사용하면 retry연산자를 사용해 쉽게 재시도 코드를 작성할 수 있다.

## 4. Combine도 같은 개념이다

Swift에서 RxSwift와 동일한 반응형 프로그래밍을 지원하는 Apple 공식 프레임워크가 Combine이다.
Cimbine은 iOS 13부터 내장되어 있으며, RxSwift와 거의 동일한 비동기 이벤트 스트림을 처리할 수 있다.

| 개념               | RxSwift                                        | Combine                           |
| ------------------ | ---------------------------------------------- | --------------------------------- |
| 데이터 스트림      | `Observable`                                   | `Publisher`                       |
| 구독               | `subscribe()`                                  | `sink()`                          |
| 데이터 조작        | `map`, `filter`, `flatMap`, `combineLatest` 등 | 동일                              |
| 메모리 해제        | `DisposeBag`                                   | `AnyCancellable` (store in `Set`) |
| 비동기 이벤트 처리 | 가능                                           | 가능                              |

```swift
import Combine

// 텍스트 필드 두 개를 결합해서 라벨에 표시
Publishers.CombineLatest(firstNamePublisher, lastNamePublisher)
    .map { "Greetings, \($0) \($1)" }
    .sink { [weak self] in self?.greetingLabel.text = $0 }
    .store(in: &cancellables)

```



## Reference
- https://velog.io/@gnwjd309/RxSwift-1
- https://reactivex.io/intro.html
- https://github.com/ReactiveX/RxSwift
- https://babbab2.tistory.com/182
- https://ios-development.tistory.com/95
- https://velog.io/@jeunghun2/ReactiveX란-무엇인가

