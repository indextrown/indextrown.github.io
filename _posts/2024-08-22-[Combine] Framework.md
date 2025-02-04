---
title: "[Combine] 개념 및 예제"
tags: 
- Combine
use_math: true
header: 
  teaser: /assets/img/Combine/Combine.png

#   teaser: /assets/img/Pasted image 20240213151745.png
---


<!-- https://medium.com/harrythegreat/swift-combine-입문하기-가이드-1-525ccb94af57 -->
<!-- https://velog.io/@newon-seoul/Combine-을-정리해보았습니다.-기초편 -->
# Combine이란
2019년에 Apple에서 출시한 비동기처리 이벤트를 처리하기 위한 first-party 프레임워크이다.  
Combine은 앱 내에서 일어나는 이벤트들의 진행 결과 등을 선언적으로 코딩할 수 있게끔 도와준다.  
어떠한 이벤트를 추적할 떄 Delegate패턴을 사용하거나, Completion 클로저를 사용하는 대신 Combine을 활용해볼 수 있다.

# Combine 주요 개념
### Stream
- 데이터의 흐름이라고도 부르며 시간에 따라 순차적으로 전달되는 값들의 흐름이다
- 이 데이터는 비동기적으로 전달가능하다
- 전달 과정에서 변환, 필터링, 결합 등이 가능하다

### Publisher
- 데이터를 만들어내고 이를 스트림 형태로 방출한다
- 값을 방출하거나 성공적으로 완료하거나 오류로 실패한다

### Subscriber
- Publisher로부터 완료 신호를 수신하는 역할을 한다
- Publisher가 방출하는 값을 처리하고, 완료나 실패 이벤트를 받으면 스트림을 정리한다

### Operator
- Publisher가 생성하는 이벤트를 변환하거나 처리하는 데 사용된다
- map, filter, reduce등의 연산자가 존재한다
- 연산자를 사용하면 복잡한 비동기 작업을 쉽게 구성할 수 있다

### sink
 - Combine 퍼블리셔(Publisher)에서 방출된 데이터를 소비(consume)하기 위해 사용하는 **구독자(Subscriber)**이다
 - 퍼블리셔가 내보내는 데이터를 받아서 처리하는 역할을 한다
 - sink를 호출하면 퍼블리셔를 구독한다
 - sink 메서드는 두 가지 클로저를 전달받는다
 - receiveCompletion: 스트림이 종료될 때(완료 또는 에러 발생 시) 호출되는 클로저
 - receiveValue: 스트림에서 방출된 값을 처리하는 클로저

### receiveCompletion
- sink 메서드의 첫번째 클로저
- 스트림이 종료(completion) 또는 에러 발생시 호출
- 두가지 상태를 처리한다
- finished(스트림 정상 종료)
- failure(스트림에서 에러가 발생하여 종료)
 
### receiveValue
- sink메서드의 두번째 클로저
- 퍼블리셔가 방출한 값을 받을 때 호출
- 여기서 값을 처리하거나 화면에 표시하는 등의 작업을 수행

### .store(in: &cancellables)
- sink 연산자로 반환된 AnyCancellable 객체를 cancellables에 저장한다
- 스트림이 종료되거나 cancellables가 해제되면 자동으로 구독이 취소된다
 
# cancellables:
- Set<AnyCancellable> 타입의 저장소이다
- 여기 저장된 AnyCancellable 객체는 구독이 유지되는 동안 메모리에서 해제되지 않도록 보장한다

# 스트림의 중요한 특징
- 시간 기반(스트림은 데이터가 시간에 따라 순차적으로 흘러가는 형태)
- 비동기 처리(스트림은 데이터가 준비될 때마다 이벤트 발생시키므로 비동기 작업과 어울림)
- 연속성(데이터가 중단되지 않고 계속 흐를 수도 있고, 완료(completion) 또는 에러(error)가 발생하여 종료될 수 있다

# 예제

### 예제 1) sink
- AnyCancellable 객체를 반환한다
- 퍼블리셔와 구독자의 생명주기를 관리하는 데 사용된다
- 구독 취소 전까지 스트림이 유지된다
- AnyCancellable을 저장하지 않으면 구독이 즉시 해제되어 데이터 스트림이 동작하지 않는다  

```swift
// AnyCancellable을 저장할 곳
var cancellables = Set<AnyCancellable>()
        
// 퍼블리셔
let stream = [1, 2, 3].publisher

stream
    .sink { completion in
        print("스트림 완료: \(completion)")
    } receiveValue: { value in
        print("받은 값: \(value)")
    }
    // 구독 저장(반환된 AnyCancellable 저장)
    .store(in: &cancellables)

/*
받은 값: 1
받은 값: 2
받은 값: 3
스트림 완료: finished
*/
```
### 예제 2) Fail 
```swift
// 커스텀 에러 타입 정의
enum MyError: Error {
    case testError
}

// AnyCancellable을 저장할 곳
var cancellables = Set<AnyCancellable>()

// 퍼블리셔
let publisher = Fail<Int, MyError>(error: .testError)

publisher
    .sink { completion in
        switch completion {
        case .finished:
            print("스트림 완료")
        case .failure(let error):
            print("스트림 에러 (항상)발생: \(error)")
        }
    } receiveValue: { value in
        print("받은 값: \(value)")
    }
    .store(in: &cancellables)

// 스트림 에러 (항상)발생: testError
```

### 예제 3) Just
- 단 하나의 값을 방출하는 Publisher
- 값을 방출한 후 즉시 완료(finished)된다
- 실패하지 않는다(Failure 타입이 Never)  

```swift
var cancellables = Set<AnyCancellable>()
        
let justPublisher = Just(100)

let subscription = justPublisher.sink { completion in
    print("완료: \(completion)")
} receiveValue: { value in
    print("받은 값: \(value)")
}

/*
받은 값: 100
완료: finished
*/
```

### 예제 4) Empty
- 값을 생성하지 않고 완료만 하는 Publisher  
- 에러 없이(failure == Never) 종료한다
- 주로 기본값이 없거나, 특정 조건에서 Publisher를 반환해야 할 때 사용된다  

```swift
var cancellables = Set<AnyCancellable>()
        
let emptyPublisher = Empty<Int, Never>()

emptyPublisher.sink { completion in
    print("완료: \(completion)")
} receiveValue: { value in
    print("받은 값: \(value)")
}.store(in: &cancellables)

// 완료: finished
```
### 예제 5) Future
- 비동기 작업을 처리할 때 유용
- ex) 네트워크 요청, 파일 읽기, 데이터베이스 작업
- 한번만 값을 방출(Just와 유사하지만 비동기적으로 동작)
- 성공(.success(value)) 또는 실패(.failure(error))로 완료됨

```swift
import Combine
import SwiftUI

func fetchData() -> Future<String, Error> {
    return Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // let success = Bool.random()
            let success = false
            
            if success {
                promise(.success("데이터 가져오기 성공"))
            } else {
                promise(.failure(URLError(.badServerResponse)))
            }
        }
    }
}

// AnyCancellable을 저장할 곳
var cancellables = Set<AnyCancellable>()

let cancellable = fetchData()
    .sink { completion in
        switch completion {
        case .finished:
            print("스트림 완료")
        case .failure(let error):
            print("에러 발생: \(error)")
        }
    } receiveValue: { value in
        print("받은 값: \(value)")
    }.store(in: &cancellables)

// RunLoop를 사용해 비동기 작업 대기
RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
```

```swift
// 1. 구독 저장소
var cancellables = Set<AnyCancellable>()

// 2. 비동기 작업을 수행하는 Future Publisher 생성
let futurePublisher = Future<Int, Error> { promise in
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        let result = 42 // 비동기 작업 결과
        promise(.success(result)) // 성공적으로 값을 방출
    }
}

// 3. 구독 시작 및 결과 처리
futurePublisher
    .sink { completion in
        switch completion {
        case .finished:
            print("스트림 완료")
        case .failure(let error):
            print("에러 발생: \(error.localizedDescription)")
        }
    } receiveValue: { value in
        print("받은 값: \(value)")
    }
    .store(in: &cancellables) // 구독 유지

// RunLoop를 사용해 비동기 작업 대기
RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))
```







<!-- 
# 예시
- URLSession.shared.dataTask { }를 사용하면 completion()을 써야하고 class - delegate를 적용하는 상황들이 직관적이지 않고  조금만 복잡해져도 스파게티 코드가 될 수 있다.

![alt text](/assets/img/Combine.png)


 Combine은 정리하자면  
 Publisher라는 이벤트 반응 전송기계  
 Subscriber라는 이벤트 수집기계  
 이 두개를 연결해주는 프레임워크이다.  
   

Subscriber 는 Publisher 에게 데이터를 받기만 하는 일방향적 관계이며,  
Subscriber 가 Publisher 에게 요청할 수 있는것은 데이터를 달라는 요청만 할 수 있다.
<br/><br/>
  
  
Publisher 는 Subscriber 에게 데이터를 전달할 때, 바로 전달할 수도 있지만  
Operator 를 활용해서, 데이터를 가공해서 줄 수 있다.
<br/><br/>
  
Operator 는 Swift 에서 일상적으로 쓰는 메소드들인  
map, flatMap, compactMap, filter 등의 이름을 따서 만든 메소드들로, 이름과 유사한 기능들을 제공한다.
<br/><br/>

더 쉽게 말하자면  
Publisher 는 데이터를 전송만 담당,  
Subscriber 는 데이터 수신만 담당  
Operator 는 Publisher 가 데이터 전송할 때, 중간에 수정하는 역할이다.
<br/><br/>
  


# 코드 예시


```swift

``

```swift
import UIKit
import Combine

// publisher 생성: [1, 2, 3]이라는 이벤트를 즉각적으로 보내겠다
var myIntArrayPublisher: Publishers.Sequence<[Int], Never> = [1, 2, 3].publisher

// 퍼블리셔에 대한 구독을 시작한다.
// 'sink' 메서드를 사용하여 퍼블리셔의 값을 수신하고 처리한다
myIntArrayPublisher.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        print("완료")
    case .failure(let error):
        print("error: \(error)")
    }
}, receiveValue: { receivedValue in
     print("값을 받았다: \(receivedValue)")
})
``` -->
