---
title: "[Uikit] Combine"
tags: 
- Uikit
use_math: true
header: 
  teaser: /assets/img/Pasted image 20240213151745.png
---


<!-- https://medium.com/harrythegreat/swift-combine-입문하기-가이드-1-525ccb94af57 -->
<!-- https://velog.io/@newon-seoul/Combine-을-정리해보았습니다.-기초편 -->
# Combine이란
Combine이란 2019년에 Apple에서 출시한 비동기처리 이벤트를 처리하기 위한 first-party 프레임워크이다.  
Combine은 앱 내에서 일어나는 이벤트들의 진행 결과 등을 선언적으로 코딩할 수 있게끔 도와준다.  
어떠한 이벤트를 추적할 떄 Delegate패턴을 사용하거나, Completion 클로저를 사용하는 대신 Combine을 활용해볼 수 있다.


# 예시
- URLSession.shared.dataTask { }를 사용하면 completion()을 써야하고 class - delegate를 적용하는 상황들이 직관적이지 않고  
조금만 복잡해져도 스파게티 코드가 될 수 있다.

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
```
