---
title: "[RxSwift] 2. RxSwift개념"
tags: 
- RxSwift
header: 
  teaser: 
typora-root-url: ../
---

<img src="/assets/img/2025-03-25-[RxSwift]-RxSwift-1/image.png" alt="clean1" style="width: 70%;">


## 1. Rx란?
파이프라인 연결이다

## 2. 구성
- 보내는 것 - Observable
- 연결 - subScribe
- 중간처리 - 연산자

## 3. 큰 개념
### 보내는 것 - 옴저버블(총알 = 구독 가능한 것)
1. Observable
  - 가장 기본 베이스, 생성하자마자 이벤트를 전달한다
  - .onNext(), .onError(), .onCompleted()를 통해 이벤트를 받을 수 있다
  - .subscribe()를 통해 이벤트를 발행 가능
  - 이벤트를 정의하고, 정적인 스트림 생성(한방향: 선언 -> 구독)

    ```swift
    // 1. Observable은 가장 기본적인 Rx 스트림
    let observable = Observable<Int>.just(1)
    
    // 2. subscribe를 통해 값을 받아 처리
    observable
        .subscribe(onNext: { value in
            print("Received: \(value)")
        })
        .disposed(by: disposeBag)
    ```

2. Subject
  - Observable(구독 가능한 것)이면서 Observer(관찰자)
  - 일단 연결을 해두고 원하는 시점에 이벤트를 보낸다.
  - 외부에서 직접 값을 넣고, 동적인 스트림 생성(양방향)
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

      // 3. 이벤트 발생 (구독 이후라 전달됨)
      publishSubject.onNext("첫 번째 이벤트")
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