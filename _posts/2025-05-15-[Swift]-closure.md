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
> 클로저는 "나중에 실행될 로직을 값처럼 전달하는 것"이다.  
"지금은 실행하지 않고 나중에 필요할 때 로직을 전달하는 방법"이다
호출 시점은 클로저를 가진 쪽이 결정한다.

## 표현식
```swift
{(parameters) -> returnType in
실행구문
}
```

## 핵심 포인트
- 함수도 값이다
- 실행 시점이 미뤄진다
- 누가 실행할지는 호출자가 결정한다

## 예제: 버튼 클릭
- 어떤 버튼이 눌렸는지
- 눌렸을 때 무슨 일을 할지는 외부에서 정하고 싶다.

1. 클로저 없는 구조의 한계
    ```swift
    class CustomButton {
        func tapped() {
            print("버튼 눌림")
        }
    }
    ```
- 버튼이 무슨 일을 해야 하는지 스스로 결정
- 재사용 불가
- 버튼마다 로직이 달라지면 구조가 깨짐

2. 클로저를 도입하면 관점이 바뀐다
- 버튼은 "눌렸다는 사실"만 알린다
- 실제 행동은 외부에서 주입한다

3. 클로저의 생명주기 (개념)

    ```swift
    1. 외부에서 버튼 생성
    2. 버튼에 클로저 전달
    3. 사용자가 버튼을 누름
    4. 버튼 내부에서 클로저 호출
    5. 외부 로직 실행

    // 1. 정의: 자리를 만든다
    // - 나중에 실행돌 코드를 여기에 넣을 수 있다
    // - 아직 실행하지 않는다
    // - 비어 있을 수도 있다
    var onTap: (() -> Void)?

    // 2. 할당: 무슨 일을 할지 정한다
    // - 이 시점에 실행되지 않는다
    button.onTap = {
        print("외부에서 정의한 동작")
    }

    // 3. 실행
    onTap?()
    ```





## 클로저 종류
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
- https://babbab2.tistory.com/81