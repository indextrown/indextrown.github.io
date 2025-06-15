---
title: "[RxSwift] 2. 개념 및 예제"
tags: 
- ReactiveX
- RxSwift
header: 
  teaser: 
typora-root-url: ../
---

<img src="{{ '/assets/img/2025-03-25-[RxSwift]-RxSwift-1/image.png' | relative_url }}" alt="커스텀셀" width="70%">

## 1. Observable & Observer
- 데이터를 연결해줄 수 있는 이벤트가 있고, 이 이벤트에 따라 변경되는 뷰, 로직이 있다.
- 즉 이벤트를 방출할 수 있는 Observable가 있고, 이벤트를 처리하는 Observer가 있다.
- Observable와 Observer를 통해 데이터의 흐름(=Stream)을 통제할 수 있고
- Operator를 통해 Stream을 변경, 조작할 수 있다.

### 사용자에게 텍스트 필드로 입력값을 받아서, 해당 입력값으로 닉네임을 저장할 때 아래의 그림과 같다.

<img src="{{ '/assets/img/2025-04-21-[RxSwift]-RxSwift-2/good.png' | relative_url }}" alt="커스텀셀" width="70%">

<img src="{{ '/assets/img/2025-04-21-[RxSwift]-RxSwift-2/good-9965934.png' | relative_url }}" alt="커스텀셀" width="70%">
예시로 표현하자면 유투버(Observable)은 영상을 올리고, 구독자(Observer)는 그 영상을 구독하고 알림을 받는다.

<img src="{{ '/assets/img/2025-04-21-[RxSwift]-RxSwift-2/bad2-9966743.png' | relative_url }}" alt="커스텀셀" width="70%">
반대로 구독자(Observer)는 영상을 올리고 유투버(Observable)가 그 영상을 구독할 수 없다,

```swift
// 가능한 방식
nicknameTextField.rx.text            // ControlProperty<String> - UIKit 요소를 Rx로 다룰 수 있게 만든 특별한 Observable
    .orEmpty
    .withUnretained(self)            // 메모리 누수 방지 + self 캡처
    .bind(onNext: { vc, value in     // 텍스트 변경시마다 nickname에 저장
        vc.nickname = value
    })
    .disposed(by: disposeBag)        // 구독해제는 disposeBag에 맞김

// 불가능한 방식
nicknameTextField.rx.text = nickname
```
- Observable은 subscribe를 하지 못하기 때문에 이벤트 방출만 할 수 있고 이벤트에 대한 처리는 할 수 없다.
- Observer역시 받은 이벤트를 다른 Observer에게 전달하지 못한다.
- nicknameTextField.rx.text = nickname 처럼 (Observable)에 바로 nickname이벤트 전달이 안된다.
- 이를 해결하기 위해 Observer와 Observable 역할을 모두 할 수 있는 Subject가 등장하였다.

---

## Subject
- Subject는 이벤트를 발행(emit)하고 구독(subscribe)모두 할 수 있는 중간 다리 역할을 한다.
    - Observable처럼 이벤트를 방출할 수 있고
    - Observer처럼 다른 Observable로부터 이벤트를 받을 수 있다.    
    - 즉 입출력이 모두 가능한 특별한 Observable 이다.
- Subject는 4가지 종류가 있다.
    - Publish Subject: 구독 이후에 발생한 이벤트만 전달
    - Behavior Subject: 구독 시 마지막 이벤트 + 이후 이벤트 전달
    - Replay Subject: 지정한 수만큼 과거 이벤트를 버퍼로 저장해 구독 시 전달
    - Async Subject: 완료 시점에 발생한 마지막 값만 전달
- 하지만 UI에 좀 더 적합한 형태가 필요하였고 Subject를 Wrapping한 Relay를 제공한다.

---

## Relay
- Relay는 두 가지 종류가 있다.
    - Publish Relay
    - Behavior Relay
- Subject와 거의 유사하지만 UI에 특화된 형태이다.
- Subject와의 가장 큰 차이점은:
    - Relay는 .completed와 .error 이벤트를 전달하거나 처리하지 않는다.

## ❓왜 .error와 .completed를 막았을까?
- 일반적인 Subject는 .onNext, .onCompleted, .onError 3가지 이벤트를 처리한다.
- 그러나 UI에서 사용하는 스트림은 에러나 종료가 발생하지 않고 계속 살아 있어야 한다.
- 만약 .error 또는 .completed 이벤트가 전달되면
    - 스트림이 종료(disposed)되고
    - 이후 .next 이벤트를 받을 수 없고
    - Rx의 반응형 업데이트 흐름이 끊기게 된다.

## Relay 주요 특징
- .next 이벤트만 전달하며, accept(_:) 메서드를 통해 값을 방출한다.
- .error, .completed는 전달하지 않기 때문에 dispose되지 않습니다.
    - 그렇기에 Relay는 명시적으로 disposeBag에 담거나, deinit시점에 수동으로 정리해주어야 한다.
- 항상 살아 있는 스트림이므로 UI 바인딩에 안정적으로 사용된다.

---

## Driver
- UI 바인딩 특화된 Observable로, 메인스레드 보장 + 에러 무시 + 공유를 기본으로 가진 RXCocoa 전용 타입이다.
    - 메인스레드 보장 -> .observe(on: MainScheduler.instance)가 내장
    - 에러 발생 x -> .onError가 자동으로 무시되거나 기본값으로 대체됨
    - 공유(share) -> 여러 곳에서 구독해도 side effect 없이 공유됨 (hot observable)
    - Subscrive만 가능하고 값 변경 불가
    - bind와 다르게 stream 공유가 된다.
        - bind는 subscribe의 별칭
        - drive는 내부적으로 share(replay: 1, scope: .whileConnected)가 구현되어 있다.

## Driver가 필요한 이유
- 일반 Observable은
    - UI 스레드 보장 안되고
    - 에러 발생시 스트림 끈힉고
    - 매 구독마다 실행(side effect)이 발생할 수 있다.
- 그래서 UI에 직접 바인딩시 Driver가 훨씬 안전하다.
- Relay는 값을 저장 & 전달하는(Input)용
- Driver는 UI 바인딩에 최적화된 Observable(Output)용

| 항목         | `Relay`                | `Driver`                       |
| ---------- | ---------------------- | ------------------------------ |
| 주 용도       | ViewModel **Input 처리** | ViewModel → View **Output 전달** |
| 에러 처리      | `.error` 불가            | `.error` 불가 + **자동 대체 필요**     |
| 스레드 보장     | ❌ MainScheduler 보장 없음  | ✅ 항상 MainScheduler에서 실행        |
| 공유 여부      | ❌ 직접 `.share()` 필요     | ✅ 내부적으로 `share(replay:1)` 적용됨  |
| 값 수동 전달    | ✅ `.accept()` 사용 가능    | ❌ 수동 값 전달 불가 (`drive`로만 가능)    |
| bind 가능 대상 | `Relay`, `Binder` 등    | `Binder`, `drive(to:)`         |

--- 

<br/><br/><br/>




<!-- |  RxSwift  |  RxCocoa   |
| :-------: | :--------: |
| Subscribe | Bind/Drive |
|  Subject  |   Relay    | -->

## 구독 방식

### 1. Subscribe
```swift
button.rx.tap // ControlEvent<Void> (Observable<Void>를 래핑한 타입)으로 내부적으로 .error 이벤트를 방출하지 않도록 설계되어 있어 스트림이 끊기지 않는다
    .observe(on: MainScheduler.instance) 
    .withUnretained(self)
    .subscribe { vc, _ in
        vc.label.text = "hello world
    }
    .disposed(by: disposeBag)
```
- button.rx.tap은 Observable<Void> 타입의 ControlEvent 버튼이 탭될 때마다 이벤트를 방출한다.
- 이 Observable를 구독한다.
- Background Schedular에서 동작할 가능성(네트워크 통신)이 있기 때문에 Observable 데이터 흐름을 MainSchedular(메인 스레드)에서 동작할 수 있도록 변경한다.

## 2. bind
```swift
// bind(onNext:)
button.rx.tap 
    .withUnretained(self)
    .bind(onNext: { vc, _ in
        vc.label.text = "hello"
    })
    .disposed(by: disposeBag)
```
- subscribe와 유사하지만 MainSchedular(메인 스레드)동작 보장과 Error 이벤트를 방출하지 않는 특성을 통해 스트림이 끊기지 않는다.

```swift
// bind(to:)
// 예시1
button.rx.tap // ControlEvent<Void> (Observable<Void>를 래핑한 타입)
    .map { "hello world" }
    .bind(to: label.rx.text) 
    .disposed(by: disposeBag)
// 예시2
viewModel.nickname // Observable<String>
    .bind(to: nicknameLabel.rx.text) // Binder<String>
    .disposed(by: disposeBag)
```
- tap의 ControlEvent<Void>를 map Operator를 통해 데이터의 흐름을 조작한다.
- ControlEvent<Void> 타입이 String 타입으로 변경 되면서 label.rx.text로 간단히 bind 가능하다.
- bind(to:), bind(onNext:) 두 형태 모두 메인 스레드에서 실행되고 에러를 무시하기 때문에, UI 바인딩에 적합하다.

|                          bind(to:)                           |                        bind(onNext:)                         |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
|              observable.bind(to: label.rx.text)              |          observable.bind(onNext: { value in ... })           |
|                          UI 바인딩                           |                      클로저에서 값 처리                      |
| `Binder<T>` 타입의 대상에만 가능 자동으로 메인 스레드에서 동작 에러 무시 | 직접 처리 가능 (print, 가공, 저장 등)<br/>에러 무시<br/>메인 스레드에서 동작 보장 |

### ✅ 정리
- bind(onNext:): 클로저 내에서 직접 처리할 때 사용
- bind(to:): 값을 다른 Rx 객체(UI 속성, Relay 등)에 전달할 때 사용
- 둘 다:
    - MainSchedular에서 항상 동작하고
    - .error 이벤트를 방출하지 않으며
- → 결과적으로 스트림이 끊기지 않으며, UI 바인딩에 매우 안정적




## drive
```swift
viewModel.nicknameDriver // Driver<String>
    .drive(nicknameLabel.rx.text)   // drive(to: Binder<String>)
    .disposed(by: disposeBag)
```
- drive는 Driver 전용 구독 연산자로,
    - MainSchedular에서 항상 동작하고
    - .error 이벤트를 방출하지 않으며
    - 내부적으로 share(replay: 1)가 적용되어 여러 구독자에게 안전하게 공유된다.
- bind(to:)와 유사하지만 Driver의 안정성을 최대한 활용하기 위한 전용 바인딩 방법이다.
- 오직 Driver 타입에서만 사용할 수 있으며, 일반 Observable에는 사용할 수 없다.






<!-- ## 1. Rx란?
파이프라인 연결이다 -->

--- 

## 에제

## 1. 구성
- 보내는 것 - Observable
- 연결 - subScribe
- 중간처리 - 연산자

## 2. 큰 개념
### 보내는 것 - 옵저버블(총알 = 구독 가능한 것)
1. Observable
  - 가장 기본 베이스, 생성하자마자 이벤트를 전달한다
  - .onNext(), .onError(), .onCompleted()를 통해 이벤트를 받을 수 있다
  - .subscribe()를 통해 이벤트를 발행 가능
  - 이벤트를 정의하고, 정적인 스트림 생성(한방향: 선언 -> 구독)

    ```swift
    // 1. Observable은 가장 기본적인 Rx 스트림
    // 내부에서 [1, 2, 3]을 한번 방출하고 끝
    let observable = Observable<[Int]>.just([1, 2, 3])
    
    // 2. subscribe를 통해 값을 받아 처리
    observable
        .subscribe(
            onNext: { value in
                print("Received: \(value)")
            },
            onError: { error in
                print("❌ onError: \(error.localizedDescription)")
            },
            onCompleted: {
                print("✅ Stream Completed")
            },
            onDisposed: {
                print("🧹 Subscription Disposed")
            }
        ).disposed(by: disposeBag)
    ```

2. Subject

  - 기본 Observable은 생성될 때 방출할 값이 정해져 있고, 외부에서 값을 주입할 수 없다. 그래서 외부에서 직접 값을 전달하고 싶을 때는 Subject를 사용한다.
  - Subject는 값을 방출할 수도 있고, 다른 Observable처럼 구독도 받을 수 있는 양방향 통로다.
  - Observable(구독 가능한 것)이면서 Observer(관찰자)
  - 일단 연결을 해두고 원하는 시점에 이벤트를 보낸다.
  - 외부에서 직접 값을 넣고, 동적인 스트림 생성(양방향)
      ```swift
    // "Hello"라는 값을 한번 방출하고 끝. 외부에서 바꿀 수 없음
    Observable.just("Hello")
    
    // 외부에서 onNext("Hello")로 값을 보내면 그때 스트림이 시작됨
    PublishSubject<String>()
    ```
    - BehaviorSubject - 상태
      - 초기값 필수
      - 구독 시, 가장 최신값 1개를 즉시 전달받음
      - 이후에는 일반 Observable처럼 .onNext 이벤트를 수신

      ```swift
      // 1. BehaviorSubject는 초기값을 설정하고, 구독 시 가장 최근 값을 전달
      let behaviorSubject = BehaviorSubject<String>(value: "초기값")
      
      // 2. 구독 설정 → "초기값"이 바로 전달됨
      behaviorSubject
          .subscribe(onNext: { print("BehaviorSubject:", $0) })
          .disposed(by: disposeBag)
      
      // 3. 새로운 이벤트 전달
      behaviorSubject.onNext("새로운 값")
    ```
    
    - PublishSubjcet - 단방향 이벤트
      - 구독 이후 이벤트만 받음(초기값 없음)
      - 주로 이벤트 전달용
    
      ```swift
      // 1. PublishSubject는 구독 이후에 발생한 이벤트만 전달
      let publishSubject = PublishSubject<String>()
    
      // 2. 구독 설정
      publishSubject
          .subscribe(onNext: { print("PublishSubject:", $0) })
          .disposed(by: disposeBag)
    
      // 3. 이벤트 직접 발생 (구독 이후라 전달됨)
      publishSubject.onNext("첫 번째 이벤트")
    
      // subject는 구독을 받고, 동시에 외부에서 onNext로 값을 직접 보낼 수 있는 Observable
      // Observable처럼 구독자를 가질 수 있고, Observer처럼 값을 외부에서 직접 넣을 수 있음 (onNext() 등)
    ```


3. Relay
  - Subject의 변형으로, error가 없고 UI바인딩에 최적화
  - PublishRelay 
    - 단방향 이벤트 전달(버튼 클릭)

      ```swift
      // 1. PublishRelay는 error가 없고 UI에 최적화된 Subject
      let publishRelay = PublishRelay<String>()
      
      // 2. 구독 설정
      publishRelay
          .subscribe(onNext: { print("PublishRelay:", $0) })
          .disposed(by: disposeBag)
      
      // 3. 이벤트 발생 → accept()로 전달
      publishRelay.accept("이벤트 발생!")
      ```
    

    - BehaviorRelay
    - 상태 저장, 초기값 필수 -> accept() 사용  

      ```swift
      // 1. BehaviorRelay는 초기값이 필요하며, 상태 저장에 적합
      let behaviorRelay = BehaviorRelay<String>(value: "기본값")
      
      // 2. 구독 설정 → "기본값"이 바로 전달됨
      behaviorRelay
          .subscribe(onNext: { print("BehaviorRelay:", $0) })
          .disposed(by: disposeBag)
      
      // 3. 값 업데이트 → accept() 사용
      behaviorRelay.accept("업데이트된 값")
      ```

4. Driver
  - 메인스레드, share(1)
  - UI 바인딩 전용으로 사용되는 옵저버블

        ```swift
          // 1. Relay에서 값을 가져와 Driver로 변환
        let textRelay = BehaviorRelay<String>(value: "Hello")
      
        // 2. Driver로 변환 (에러 없이, MainThread에서 작동)
        let textDriver = textRelay.asDriver()
      
        // 3. UI 요소에 drive (drive는 MainThread에서 UI 바인딩 시 사용)
        textDriver
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        ```

### 구독
1. subscribe(onNext:)
  - next, error, completed 시퀀스 이벤트를 받을 수 있다
  - 직점 onError 처리 가능하다
  - viewModel 내부, 로직 처리, 이벤트 감지, 에러 대응
  - Disposable 반환해야한다
  - 모든 Observable계열 구독 가능
  - bind(onNext:) 보다 범용적, 완료/에러 받을 수 있다

        ```swift
        // 1. onNext만 사용하는 기본적인 구독
        let observable = Observable.just("Hello, RxSwift!")
      
        observable
            .subscribe(onNext: { value in
                print("onNext:", value)
            })
            .disposed(by: disposeBag)
      
        // 2. onNext, onError, onCompleted 모두 명시
        let observable = Observable<String>.create { observer in
            observer.onNext("첫 번째 이벤트")
            observer.onCompleted()
            return Disposables.create()
        }
      
        observable
            .subscribe(
                onNext: { print("onNext:", $0) },
                onError: { print("onError:", $0.localizedDescription) },
                onCompleted: { print("onCompleted") },
                onDisposed: { print("onDisposed") }
            )
            .disposed(by: disposeBag)
        ```


2. bind(to:)
  - UI 컴포넌트 프로퍼티에 바인딩할 때 사용
  - 구독과 동시에 값이 특정 속성에 직접 들어가는 방식
  - 값을 특정UI의 속성에 직접 구독해서 바인딩
  ```swift
  // label.text = title처럼 자동으로 연결하는 직접 바인딩 방식
  viewModel.title
      .bind(to: label.rx.text)
      .disposed(by: disposeBag)
  ```
3. bind(onNext:)
  - 단순히 이벤트를 수신하고 구독 형태
  - 내부에 명시적으로 처리 로직을 작성해야 함
  - 값을 받아서 직접 처리(프린트, 로직 실행)하는 방식으로 구독
  ```swift
  viewModel.title
      .bind(onNext: { text in
          print("값 출력: \(text)")
      })
      .disposed(by: disposeBag)
  ```

4. 비교

    ```swift
    // 1. 자동 UI 업데이트 (bind to UI)
    viewModel.username // Observable<String>
        .bind(to: label.rx.text) // 📲 label.text = 값
        .disposed(by: disposeBag)

    // 2. 내가 직접 프린트 (bind with closure)
    viewModel.username
        .bind(onNext: { name in
            print("유저 이름은 \(name)")
        })
        .disposed(by: disposeBag)
    ```

5. drive (RxCocoa 전용 UI 바인딩 방식)
- Driver 타입만 사용할 수 있는 구독 방식
- UI 업데이트에 특화 → MainThread 보장 + 에러 자동 무시 + 공유(share) 내장
- .asDriver(onErrorJustReturn:) 또는 .asDriver()를 통해 변환 후 사용
- UI 요소(UILabel, UIButton, UISwitch, etc.)에 직접 바인딩 가능
- 내부적으로 bind(to:)와 매우 유사하지만, Driver만 사용할 수 있음

    ```swift
    // 예시 1: ViewModel의 Driver<String>을 UILabel에 바인딩
    viewModel.nicknameDriver
        .drive(nicknameLabel.rx.text)
        .disposed(by: disposeBag)

    // 예시 2: ViewModel의 Driver<Void>을 버튼 클릭에 바인딩
    viewModel.didTapSomething
        .drive(onNext: {
            print("탭 감지됨!")
        })
        .disposed(by: disposeBag)
    ```


## Reference
- https://so-kyte.tistory.com/192
