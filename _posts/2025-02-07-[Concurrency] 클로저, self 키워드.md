---
title: "[Concurrency] 클로저와 self 키워드"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
typora-root-url: ../

---

# 클로저와 self 키워드 

# 클로저 (Closures)

**명명된 함수 없이 실행할 수 있는 코드 블록이다.**
클로저(Closures)는 코드에서 주변의 값을 전달받아 사용할 수 있는 자체 포함된 기능 블록이다.  
Swift의 클로저는 다른 프로그래밍 언어에서 클로저, 익명함수, 람다, 블럭과 유사하다. 
Swift의 클로저는 정의된 컨텍스트에서 모든 상수와 변수에 대한 참조를 **캡처하고 저장**할 수 있다. 
이러한 방식으로 캡처된 상수와 변수를 **폐쇄(closing over)**한다고 한다.

## 클로저 3가지 형태

- **전역 함수(Global Functions)**: 이름을 가지며, 어떠한 값도 캡처하지 않는 클로저.

  ```swift 
  func globalFunction () {
    	print("전역 함수 실행")
  }
  ```

- **중첩 함수(Nested Functions)**: 이름을 가지며, 둘러싼 함수에서 값을 캡처할 수 있는 클로저.

  ```swift
  func outerFunction() {
      var number = 10
      
      func nestedFunction() {
          print("캡처된 값: \(number)")
      }
      nestedFunction()
  }
  ```

- **클로저 표현식(Closure Expressions)**: 주로 컨텍스트에서 값을 캡처할 수 있는 경량 구문으로 작성된, 이름이 없는 클로저.

  ```swift
  let closureException = { (name: String) in
  		print("Hello, \(name)!")
  }
  
  closureExpression("Swift")
  ```

  

























# Reference

- https://bbiguduk.gitbook.io/swift/language-guide-1/closures#closure-expressions

  

