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

<img src="{{ '/assets/img/2025-04-21-[RxSwift]-RxSwift-2/RxObservable.drawio-9895447.png' | relative_url }}" alt="커스텀셀" width="70%">

```swift
// 코드로 구현
nicknameTextField.rx.text
    .orEmpty
    .withUnretained(self)
    .bind { vc, value in
        vc.nickname = value
    }
    .disposed(by: disposeBag)
```
- 하지만 Observable은 subscribe를 하지 못하기 때문에 이벤트 방출만 할 수 있고 이벤트에 대한 처리는 할 수 없다.
- Observer역시 받은 이벤트를 다른 Observer에게 전달하지 못한다.


## 1. Rx란?
파이프라인 연결이다

## 2. 구성
- 보내는 것 - Observable
- 연결 - subScribe
- 중간처리 - 연산자

## 3. 큰 개념
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

  ## Reference
  - https://so-kyte.tistory.com/192
