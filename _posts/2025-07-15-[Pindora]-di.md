---
title: "[Pindora] Dependency Injection란?"
tags: 
- Pindora
header: 
  teaser: 
typora-root-url: ../
---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## Dependency Injection란 무엇인가?
DI는 Dependency Injection의 줄임말로, 다양한 우리말 번역이 있지만, 이 글에서는 의존성 주입이라는 말로 사용하고자 한다.
먼저 의존성, 주입, 의존성 주입 순서대로 알아보자.

### Dependency(의존성)
객체 지향 프로그래밍에서 Dependency, 의존성은 `서로 다른 객체 사이에 의존 관계가 있다는 것`을 말한다. 즉 `의존하는 객체가 수정되면 다른 객체도 영향을 받는다는 것`이다.

```swift
import Foundation

class A부품 {
    var name: String = "A부품"
}

class B부품 {
    var name: String = "B부품"
}


/// ex: ViewController()
class C완성품 {
    
    /// ex: NetworkManager()
    // C완성품이 A부품에 의존한다 = 의존성이 생긴다
    // A부품의 코드가 바뀌면 C완성품의 코드를 바꿔줘야하는 문제가 생긴다
    // 부품을 바꾸고 싶을 때는 코드를 B부품으로 버꿔야 하는 문제가 생긴다
    var a: A부품 = A부품()
    
    func printName() {
        print(a.name)
    }
}
```
하나의 객체가 다른 객체에 의존하고 있는 코드를 의존하고 있다고 말한다.
이렇게 의존성이 생기는 코드를 확장성있게 바꾸기 위해 의존성 주입을 통해 코드를 개선할 수 있다.

## 주입(Injection)

생성자를 통해 저장속성을 외부에서 주입하는 개념이다.  
의존성 코드에서는 저장속성에 기본값을 인스턴스로 생성&할당하여 생성자를 만들어 주지 않아도 괜찮았다.     

```swift
// 주입(Injection)
class Person {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

// 외부에서 값을 주입(할당/초기화)해서 인스턴스 생성
let people = Person(name: "Index")
```
실제로는 기본값보다는 생성자를 통해서 외부에서 들어온 값을 통해 저장속성에 할당할 수 있게 해주는 개념인 주입의 개념을 실제로 많이 사용한다.
정리하자면 인스턴스를 생성할 때 저장속성을 외부에서 할당(=주입=초기화)해줄 수 있다고 한다. 

## 의존성 주입
```swift
import Foundation

class A부품 {
    var name: String = "A부품"
}

class B부품 {
    var name: String = "B부품"
}

class C완성품 {
    
    var a: A부품
    
    init(a: A부품) {
        self.a = a
    }
    
    func printName() {
        print(a.name)
    }
}

// 1. 인스턴스를 미리 만들고
let a: A부품 = A부품()
a.name = "비싼 A부품"

// 2. C완성품을 만들 때 주입(Injection)을 해줄 수 있다
// 하지만 이 코드를 의존성 주입(Dependency Injection)이라고 부르지는 않는다
let c: C완성품 = C완성품(a: a)
```
C완성품을 만들 때 미리 만들어 둔 A부품을 주입할 수 있지만 이 코드를 의존성 주입이라고 부르지는 않는다.  
의존적이지 않게 만들어주는 코드를 추가해야 의존성 주입이라는 개념이 된다.

### 주입을 의존성 주입으로 개선
```swift
// protocol은 자격증이라고 생각하자
// 각 부품에서 이 자격증을 채택한다
// 자격증을 정의할 때 name이라는 속성을 가지면서 읽기, 쓰기가 가능한 name이라는 속성을 가진다고 정의하고 이를 각 모듈에서 채택한다
// 이 protocol 덕분에 모듈화가 가능해지고 확장적인 코드를 작성할 수 있게 된다
protocol 모듈화된부품 {
    var name: String { get set }
}

class A부품: 모듈화된부품 {
    var name: String = "A부품"
}

class B부품: 모듈화된부품 {
    var name: String = "B부품"
}

class C완성품 {
    
    // 프로토콜로 타입을 선언하여 이 프로토콜(자격증)을 채택한 모든 타입들을 할당해줄 수 있다
    var a: 모듈화된부품
    
    init(a: 모듈화된부품) {
        self.a = a
    }
    
    func printName() {
        print(a.name)
    }
}

@main
struct Main {
    static func main() {
        let moduledA = A부품()
        let moduledB = B부품()
        
        // 모듈화된 A를 주입할 수도 있고 모듈화된 B를 주입할 수도 있다
        let c1: C완성품 = C완성품(a: moduledA)
        let c2: C완성품 = C완성품(a: moduledB)
        
        c1.printName()
        c2.printName()
    }
}
```
주입 코드를 의존성 주입으로 개선하기 위해 protocol을 선언하고 클래스의 저장속성 타입들이 해당 protocol을 채택하면 된다.   
이를 통해 C완성품은 저장속성으로 A부품도 주입할 수 있고 B부품도 주입할 수 있다. 

정리하자면 각 부품이 서로 다른 타입이지만 모듈화가 가능해지고 확장적인 코드를 작성할 수 있게 된다.   
protocol 자체를 타입으로 사용할 수 있어서 모듈화를 시킬 수 있는 장점이 존재하고, protocol을 채택한 여러 타입들이 속성에 할당될 수 있는 것이다.

## 정리
의존성
- 서로 다른 객체 사이에 의존 관계가 있다는 것
- (한 객체가 다른 객체에 직접 접근하거나 사용하는 관계)

주입
- 외부에서 객체(또는 데이터)를 생성해서 생성자를 통해 넣는 것
- (클래스 내부에서 직접 생성하지 않고, 외부에서 주입)

의존성 주입(개선된 의존성)
- 프로토콜을 사용해서 의존성을 분리시키고 의존관계를 역전 시킨다  
  - 객체 간의 결합도를 낮추고, 의존 관계를 외부로 분리하여 더 유연한 구조를 만드는 설계 방식
  - **의존 관계 역전 원칙(DIP)**과 **단일 책임 원칙(SRP)**을 따르도록 도와준다
  - 주입 시 **프로토콜(인터페이스)**을 사용하면 모듈화와 확장성이 높아진다
  - 이를 통해 구체적인 클래스가 아닌 추상화(프로토콜)에 의존하게 되고, 이것이 바로 의존 관계의 역전


## Reference
- https://eunjin3786.tistory.com/233
- https://medium.com/@jang.wangsu/di-dependency-injection-이란-1b12fdefec4f
- https://medium.com/@jang.wangsu/di-inversion-of-control-container-란-12ecd70ac7ea
- https://tecoble.techcourse.co.kr/post/2021-04-27-dependency-injection/
- https://dokit.tistory.com/54
- https://80000coding.oopy.io/68ee8d89-5d05-449d-87e2-5fba84d604ca
- https://www.inflearn.com/courses/lecture?courseId=328390&type=LECTURE&unitId=163822&subtitleLanguage=ko&tab=curriculum