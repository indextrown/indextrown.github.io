---
title: "[Swift] Swift 기초 문법 01"
tags: 
- ESTsoft
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
- 코드를 최적화하여 실행 시에 성능을 극대화하는 데◊ 중요한 역할을 하며, Swift 고성능 특징 중 하나이다.
- 컴파일러는 정적 타입 언어로서의 정점도 살려 안전성 및 컴파일 타임 체크를 제공하면서, 런타임에도 큰 영향을 미친다.

# Swift 주요 특징
- 타입 안전성: 런타임 에러를 최소화
- 성능: C++에 가까운 빠른 실행 속도
- 모던한 문법: 가독성과 표현력이 뛰어남
- 다중 패러다임 지원
- 객체지향, 함수형, 프로토콜 지향 프로그래밍
- 메모리관리: ARC를 통한 자동 메모리 관리

# iOS 기반 필수 Framework
- Foundation
- UIKit
- SwiftUI

# 변수
- `var` 키워드를 사용하여 선언한다.
- 선언 후 값을 변경할 수 있다.
- 필요한 이유  
-> 프로그램에서 데이터를 동적으로 처리할 수 있다.  

```swift
var number = 20  // 초기화(선언과 동시에 값을 할당)(정수 리터럴)
print(number)    // 20

number = 30
print(number)    // 30
```  

# 상수
- `let` 키워드를 사용하여 선언힌디.
- 선언 후 값을 변경할 수 없다.
- 필요한 이유  
-> 불변 데이터 처리: 값이 변하지 않는 데이터를 저장할 때(성별, API에서 받는 고정 값)  
-> 안전성: 코드에서 상수를 사용하면 의도치 않게 값을 변경할 위험을 줄일 수 있다.  
-> 성능 최적화: 컴파일러가 상수는 변경하지 않는 값을 미리 최적화 할 수 있기 때문에 성능이 조금 향상될 수 있다.  
-> 정리: 상수는 코드의 의도를 명확히 하고, 프로그램의 예측 가능한 동작을 보장하는 데 중요한 역할을 한다.  
```swift
let constantValue = 10
print(constantValue)  // 10
// constantValue = 20 -> [컴파일 오류] 상수는 값을 변경할 수 없다
```

<!-- # Model
- 폭포수
    
    특징: 순차적이고 계획적인 개발 방식
    
    장점: 계획이 명확하고 예측 가능, 문서화가 잘 되어있음
    
    단점: 요구사항 변경 어려움, 유연성이 부족
    
- 애자일(빨리 만들 때)
    
    특징: 반복적이고 유연한 개발 방식
    
    장점: 빠른 피드백, 변화에 유연함, 고객과의 협업 강조
    
    단점: 요구사항 변경 어려움, 유연성이 부족
    
- 스크럼
    
    특징: 애자일을 구현하는 프레임워크, 스프린트 기반으로 팀워크 강조
    
    장점: 반복적인 점진적 개발, 팀원들의 자율성과 협업 강조
    
    단점: 경험 많은 팀 필요, 스크럼 마스터와 제품 책임자의 역활 중요 -->

# 메모리 = RAM ( Random Access Memory)
### **Stack** (변수 - `var`)
- **빠른 할당과 해제**: LIFO 방식으로 메모리 할당과 해제가 이루어지기 때문에 빠르고 효율적이다.
- **값 타입**: `Int`, `Double`, `Struct`를 저장하는 메모리 영역이다.
- `var` 키워드로 선언된 변수는 **Stack**에 할당된다.
- 변수는 값이 변경 가능하고, 함수 호출 시 메모리에 빠르게 할당 및 해제된다.

### **Heap** (객체 -`class`)
- **Heap**은 **참조 타입**(예: `Class`, `Array`, `Dictionary`)을 저장하는 메모리 영역이다.
- **느린 할당과 해제**: Stack에 비해 할당과 해제가 느리다.
- **참조 타입**: 객체는 **참조**를 통해 관리된다. 여러 변수에 같은 객체를 참조할 수 있다.
- **자동 참조 카운팅(ARC)**: Swift는 **자동 참조 카운팅(ARC)**를 사용하여 객체가 더 이상 참조되지 않으면 자동으로 해제한다.

## **Data** (데이터 영역 - 상수, 초기화된 변수)
- **Data** 영역은 주로 **전역 변수**, **정적 변수**, **상수** 등이 저장된다.
- 이 영역은 프로그램 실행 중 고정된 값을 유지하며, 프로그램이 시작할 때 할당되고 종료될 때 해제된다.
- `let`으로 선언된 **상수**는 이 영역에 저장된다.

## **Code** (코드 영역 - 함수 및 메서드)
- **Code** 영역은 실행할 **프로그램의 코드** 자체가 저장되는 영역이다.
- 여기에 **함수**나 **메서드**가 저장되어 CPU가 이를 실행한다.
- `let`으로 선언된 상수의 명령은 **Code** 영역에 저장되지만, **상수**의 값은 **Data(()) 영역에 저장된다.

# 옵셔널
- 값이 있을 수도 있고 없을 수도 있는 변수이다.
- 옵셔널 타입은 ? 로 표시한다.
- 변수에만 적용 가능하다.

# 옵셔널 바인딩(`if let`)
- 옵셔널 값을 안전하게 추출한다.
- 값이 있으면 let에 담는다는 의미이다.
```swift
var name: String? = "Index"
if let unWrappedName = name {
    print("이름: \(unwrappedName)")
} else {
    print("값이 없습니다")
}
```

# 강제 언래핑(`!`)
- 옵셔널 값에 직접 접근한다.
- 값이 없으면 런타임 오류 발생한다.
```swift
var name: String? = "Index"
print(name!) // 출력: Index
```

# 옵셔널 기본값(`??`)
- 값이 없을 경우 기본값을 반환한다.
```swift
var name: String? = nil
print(name ?? "Unknown") // 출력: Unknown
```

# 사용자 입력(`readLine()`)
- 사용자가 입력한 값을 문자열로 반환한다.
- 반환값은 옵셔널 타입이다 `String?`  
  
```swift
print("이름을 입력하세요:")
if let input = readLine() {
    print("입력된 이름: \(input)")
} else {
    print("입력이 잘못되었습니다.")
}

print("숫자를 입력하세요:")
if let input = readLine(), let number = Int(input) {
    print("입력된 숫자: \(number)")
    print("2배: \(number * 2)")
} else {
    print("올바른 숫자를 입력하세요.")
}
```  

# 터미널에서 Swift코드 실행법
- cd ~/Library/Developer/Xcode/DerivedData/ESTSOFT-cqoylveavglfvdbfmajyjceadgbw/Build/Products/Debug/
- swfit 파일이름.swift

# 조건문
- 주어진 조건에 따라 코드 실행을 분기한다.
- Swift는 if, guard, switch와 같은 조건문을 제공한다.

# if 조건문
- `if` 조건문은 특정 조건이 True일 경우 실행된다.
- 조건이 거짓이면 `else` 블록이 실행된다.




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