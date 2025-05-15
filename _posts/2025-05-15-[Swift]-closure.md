---
title: "[Swift] Closure"
tags: 
- Swift
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## 클로저

클로저 표현식
```swift
 {(parameters) -> returnType in
    실행구문
 }
```

클로저 종류
- Named Closure = 함수
- Unnamed Closure

## **클로저는 Argument Label을 사용하지 않는다.**

- 클로저는 둘다 포함하지만 보통 Unnamed Closure를 말한다.
-  클로저도 익명이긴 하지만 함수이기 때문에, 함수형 프로그래밍이 가능하다.
-  Swift의 함수와 클로저는 **1급 객체(First-Class Citizen)**로 동작한다.

 1급 객체
 - 프로그래밍 언어에서 값처럼 다룰 수 있는 객체를 의미한다.
 - 1등 시민처럼, 많은 권한을 부여 받은 것

 권한
 - 변수 또는 상수에 `함수/클로저`를 담을 수 있다.
 - 인자(파라미터)로 `함수/클로저`를 전달할 수 있다.
 - 반환값(리턴벨류)으로 `함수/클로저`를 전달할 수 있다.

 클로저와 함수 차이
 - 클로저는 상위 스코프 변수 캡처 가능
 - 함수는 캡처 기본 제공 x

 용도
 - 클로저 - 일회성 로직 전달(ex. 콜백)
 - 함수 - 명시적 로직 분리

 ```swift
func doSomething() {
    print("hello world")
}
let closuredoSomething = { print("hello world") }



func doSomething2(name: String) {
    print("hello world \(name)")
}
let closuredoSomething2 = { (name: String) -> Void in
    print("hello world \(name)")
}
let closuredoSomething22: (String) -> Void = { name in
    print("hello world")
}

func doSomething3(name: String) -> String {
    return name
}
let closuredoSomethihg3: (String) -> String = { name in
    return name
}

func doSomething4(closure: () -> ()) {
    closure()
}

let closuredoSomethihg4: () -> () = {
    print("test")
}


@main
struct Main {
    static func main() {
        // doSomething()
        // closuredoSomething()
        doSomething2(name: "인덱스")
        closuredoSomething2("인덱스2")
        
        doSomething4(closure: closuredoSomethihg4)
        
        // MARK: - 마지막 매개변수가 클로저이면 후행 클로저를 사용할 수 있다.
        doSomething4 {
            closuredoSomethihg4()
        }
    }
}
 ```



 ## reference

 \- https://babbab2.tistory.com/81