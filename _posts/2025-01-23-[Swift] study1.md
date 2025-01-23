---
title: "[Swift] Study1"
tags: 
- Uikit
use_math: true
header: 
  teaser: 
---

# Swift
- 자동 참조 카운팅(ARC)를 사용하여 메모리 관리를 효율적으로 처리한다.
- C++처럼 수동적으로 메모리를 관리할 필요 없이 객체의 참조가 더 이상 필요없을 때 자동으로 메모리를 해제하는 방식으로 동작한다.
- 이러한 접근법 덕분에 Swift는 C++에 가까운 성능을 제공하면서 메모리 관리가 수월해진다.
- Swift는 LLVM 기반의 최적화된 컴파일러를 사용하여 빠른 실행 속도를 보장한다.

# 컴파일러
- 코드를 최적화하여 실행 시에 성능을 극대화하는 데 중요한 역할을 하며, Swift 고성능 특징 중 하나이다.
- 컴파일러는 정적 타입 언어로서의 정점도 살려 안전성 및 컴파일 타임 체크를 제공하면서, 런타임에도 큰 영향을 미친다.

# Swift 주요 특징
- 타입 안전서성: 런타임 에러를 최소화
- 성능: C++에 가까운 빠른 실행 속도
- 모던한 문법: 가독성과 표현력이 뛰어남
- 다중 패러다임 지원
- 객체지향, 함수형, 프로토콜 지향 프로그래밍
- 메모리관리: ARC를 통한 자동 메모리 관리

# iOS 기반 필수 Framework
- Foundation
- UIKit
- SwiftUI


<!-- 
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
``` -->