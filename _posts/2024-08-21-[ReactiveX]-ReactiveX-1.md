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
RxSwift를 알기 위해 [ReactiveX](https://reactivex.io/intro.html)에 대해 알아야 한다. ReactiveX 혹은 Reactive Extension, 혹은 Rx라고도 부른다. Rx는 마이크로소프트에서 개발한 비동기 이벤트를 핸들링해주는 오픈소스 라이브러리이다.

<!-- ### Rx 공식 홈페이지에서는 다음과 같이 설명한다.
> An API for asynchronous programming
with observable streams -->

### 옵저버 패턴
Rx는 비동기 이벤트 핸들링을 위해 **Observer(옵저버) 디자인 패턴**을 사용한다.
> Observer 패턴이란 **관찰자(Observer)**가 대상이 되는 객체를 등록 함으로서 해당 객체의 상태 변화를 관찰하고 관찰 대상인 객체가 상태 변화로 이벤트를 발생시킬 때 이 이벤트를 감지하여 처리한다.

<img src="{{ '/assets/img/2024-08-21-[ReactiveX]-ReactiveX-1/RX공부.png' | relative_url }}" alt="커스텀셀" width="100%">
- 여기서 1 -> 2 -> 3의 시간에 따라 순차적으로 흘러나오는 이벤트의 흐름을 **스트림**이라고 한다.

이런 옵저버 패턴은 네트워크 통신과 같은 비동기 이벤트와 함께 사용하면 좋은 궁합을 보여주는 데, 네트워크 통신과 같이 비교적 시간이 오래 걸리는 작업으로 값이 미래에 준비되는 상황에서 값이 준비될 때까지 대상을 관찰하다가 값이 도착했을 때 도착한 것을 감지하고 처리할 수 있다. 
Rx에서는 이런 관찰자를 **Observer**, 관찰 가능한 대상을 **Observable** 라고 한다.

### Q. 비동기 이벤트는 옵저버 패턴이 아니라도 단순 escaping 클로저로 가능한거 아닌가?
escaping 클로저로도 비동기 이벤트를 처리할 수는 있지만, escaping 클로저의 가장 큰 단점은 연쇄적인 비동기 이벤트가 발생하였을 때 **중첩된 형태의 클로저는 코드의 가독성 저해와 개발자의 실수를 유발**시키는 요인이 될 수 있다.

### @escaping 콜백지옥 예시
```swift
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

### RxSwift에서 콜백지옥 탈출 예시
```swift
import RxSwift

let disposeBag = DisposeBag()

// Observable 생성
func fetchUser() -> Observable<String> {
    return Observable.just("User123").delay(.seconds(1), scheduler: MainScheduler.instance)
}

func fetchPosts(for user: String) -> Observable<[String]> {
    return Observable.just(["Post1", "Post2"]).delay(.seconds(1), scheduler: MainScheduler.instance)
}

func fetchComments(for post: String) -> Observable<[String]> {
    return Observable.just(["Comment1", "Comment2"]).delay(.seconds(1), scheduler: MainScheduler.instance)
}

// Observable<T> 자체가 스트림(Stream)이다. 
// - 스트림이란 시간이 지나면서 이벤트(값)을 방출(push)하는 데이터 흐름이다.
// flatMap을 활용한 체이닝
fetchUser()                            // ✅ 스트림의 시작: Observable<String> 생성
    .do(onNext: { print("Fetched user: \($0)") })
    .flatMap { user in                 // ✅ 스트림 변형(연결): user → Observable<[String]>로 변환
        fetchPosts(for: user) 
    }
    .do(onNext: { print("Fetched posts: \($0)") })
    .flatMap { posts in               // ✅ 스트림 변형(연결): posts → Observable<[String]>로 변환
        fetchComments(for: posts[0])
    }
    .subscribe(onNext: { comments in // ✅ 스트림 소비: 최종 값 소비
        print("Fetched comments: \(comments)")
    })
    .disposed(by: disposeBag)       // ✅ 스트림 구독 유지 및 해제 관리
```
RxSwift는 비동기 이벤트를 처리하는 데 있어 간단하면서도 강력한 방식을 제공한다.   
Observable은 데이터의 흐름을 스트림(Stream) 형태로 나타내며,   
 이 스트림은 데이터가 변경될 때마다 값을 방출하고, 이를 Observer가 구독하여 처리할 수 있다.

특히 RxSwift는 **flatMap, map, filter** 같은 다양한 **Operator(연산자)**를 제공하여, 연속된 비동기 작업을 중첩 없이 깔끔하게 연결할 수 있게 해준다.  
이러한 구조 덕분에 중간 작업 삽입, 데이터 가공, 조건 처리 등이 매우 유연하게 이루어지며, 결과적으로 코드의 가독성과 유지보수성이 크게 향상된다.

---

## 2. 함수형 패러다임
> 함수형 패러다임에서 함수는 하나의 일급 객체로서 변수나 상수에 함수를 할당 가능하고 다른 함수의 전달인자로서 매개변수에 전달 가능하다.  

Rx 이야기를 하면서 함수형 패러다임 이야기가 나오는 이유는 Rx를 강력하게 만드는 기능 중 하나가 **함수형 패러다임**이다.  

ex) 비동기 네트워크 통신으로 서버로부터 데이터를 가져오는 상황을 가정해보자. 
서버로부터 가져온 데이터를 사용자의 입맛에 맞게 가공해보자.
- 사용자에게 불필요한 정보는 걸러낸다. (filter)
- 가져온 데이터를 다른 데이터 타입으로 변환한다. (map)
- 데이터를 하나 받은 후 어떤 동작을 수행한다. (onNext)
- 네트워크 통신이 완료된 후에 어떤 동작을 수행한다. (onComplete)
- 네트워크 통신에 실패한 경우 어떤 동작을 수행한다. (onError)

위의 과정은 하나의 stream을 만들고, 이러한 연속적인 Operator의 적용은 함수의 연쇄적인 체이닝을 통해 구현할 수 있고, stream을 선언적으로 표현할 수 있도록 한다. 다시 말해 **Rx는 이런 함수형 패러다임과 어울리는 궁합이다**.

### Rx에서 함수의 연쇄적인 체이닝 예시
```swift
import Foundation
import Rxswift

let disposeBag = DisposeBag()

Observable.from([1, 2, 3, 4, 5])
    .filter { $0.isMultiple(of: 2) } // 짝수만 필터링
    .map { String($0) }              // 문자열로 변환
    .subscribe(onNext: { 문자열숫자 in
        print(문자열숫자)
    })
    .disposed(by: disposeBag)

// 2
// 4
```

---

<br/><br/><br/>

<img src="{{ '/assets/img/2024-08-21-[ReactiveX]-ReactiveX-1/image-2-9913496.png' | relative_url }}" alt="커스텀셀" width="100%">



## 3. 반응형 프로그래밍이란?

> **Reactive Programming(반응형 프로그래밍)은 모든 것을 데이터 스트림으로 간주하고, 데이터(이벤트)에 따라 변경 내용을 전파하는 프로그래밍 방식이다.**

<!-- 데이터의 흐름 및 변경사항을 전파하는 데 중점을 둔 프로그래밍 패러다임이다.   
이 패러다임을 사용할 경우, 주변 환경/데이터 변화가 생길 때 연결된 실행 모델들이 이 이벤트를 받아 동작하도록 설계하는 방식이다.  -->

- **선(→)** : 시간에 따라 데이터가 흐르는 경로이며, **Observable**이라고 부른다.
- **점(●)** : 특정 시점에 발생하는 **이벤트(Event)** 하나를 의미한다.
- **debounce 박스** : 너무 잦은 이벤트를 필터링하는 **Operator(연산자)**이다.
- **아래쪽 선** : `debounce` 를 통과한 **구독자에게 전달되는 결과 흐름**을 나타낸다.

### 비유로 설명
**자동차(Event)**들이 **도로(Ovservable)**를 따라 달리고 있다.
이떄 **교통경찰(debounce)**이 너무 자주 지나가는 **자동차(Event)**를 관찰 및 통제한다.
일정 시간 동안 아무 차도 지나가지 않으면, **마지막으로 지나간 자동차(Event)**만 통과시킨다.  
즉 이벤트가 여러 번 발생하더라도 debounce를 통과한 이벤트만 최종적으로 전달한다.

### 반응형 프로그래밍 사용 예시
- 이벤트 처리
- 버튼 클릭
- 액션 처리
- delegate 패턴 -> reactive 방식
- notification -> reactive 방식
- API 요청을 반복처리 또는 동시처리

## 4. RxSwift란?
Reactive Extension/Programming + Swift로, 관찰 가능한 시퀀스를 사용하여 비동기 및 이벤트 기반 프로그램을 구성하기 위한 라이브러리다.  

Swift는 함수형 프로그래밍(Functional Programming) 패러다임을 강조하는 언어이다.   
이에 RxSwift는 반응형 프로그래밍(Reactive Programming)을 더하여, Swift에서 FRP(Functional Reactive Programming)을 따를 수 있도록 한다.  
즉 Swift를 반응형 프로그래밍 하는 것이다.

### 예시
```swift
Observable
    .combineLatest(firstName.rx.text, lastName.rx.text) {  $0 + " " $1 }
    .map { "Greetings, \($0)" }
    .bind(to: greetingLabel.rx.text)
    .disposed(by: DisposeBag)
```
- comBineLatest나 map을 RxSwift에서 Operator라고 부른다.
- 이러한 연산자를 사용해서 이벤트의 값을 여러 형태로 조합하거나 변경할 수 있다.
- 또한 MVVM패턴을 적용할 때 View와 ViewModel을 연결해주는, 데이터 바인딩을 수행해야 한다.  
이때 bind(정확히 말하자면 bind는 RxCocoa이다) 연산자를 사용하여 쉽게 바인딩이 가능하다.   
DisoatchQueue에서 직접 조정해야 했던 작업들을 자동으로 처리해준다.

## 5. RxSwift 사용 목적
```swift
func doSomethingIncredible(forWho: String) throws -> IncredibleThing

// 재시도
doSomethingIncredible("me")
    .retry(3)
```
- API 통신을 하다보면, 성공할 때도 있지만 실패할 때도 분명 존재한다.
- 실패시 단순히 끝나는게 아니라 3번 정도 재시도 할 수 있다면 좋겠지만 재시도 코드는 많이 복잡하고, 재사용하기도 어렵다.
- RxSwift를 사용하면 retry연산자를 사용해 쉽게 재시도 코드를 작성할 수 있다.
- 또한 초반부에 작성한 콜백 지옥을 해결하기 위해서도 사용한다.

## 6. Combine도 같은 개념이다
- RxSwift는 써드파티라서 Apple 입장에서는 시스템 통합이 어려웠다.
- SwiftUI를 만들면서 비동기 처리와 UI 바인딩을 자연스럽게 연동할 필요가 있었다.
- Swift에서 RxSwift와 동일한 반응형 프로그래밍을 지원하는 Apple 공식 프레임워크가 Combine이다.
- Combine은 iOS 13부터 내장되어 있으며, RxSwift와 거의 동일한 비동기 이벤트 스트림을 처리할 수 있다.

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

