---
title: "[Swift] 7. 메모리"
tags: 
- Swift
- Grammer
use_math: true
header: 
  teaser: 
typora-root-url: ../

---

## OS 메모리 구조
<img src="{{ '/assets/img/2025-02-10-[Swift]Memory/스크린샷 2025-06-10 오전 12.12.15.png' | relative_url }}" alt="이미지" width="100%">

- Swift에서 메모리는 주로 4개의 영역으로 나눌 수 있다.


---

### 1) Code 영역
- 실행 가능한 프로그램 코드를 기계어 형태로 저장한다.
- 이 영역은 읽기 전용(Read-Only) 이며, 프로그램의 실행 중에 변경되지 않는다.

---

### 2) Data 영역
- Swift 정적 변수, 상수, 타입 메타데이터 등을 저장한다.
- 프로그램 시작과 동시에 할당되어 프로그램이 종료디면 메모리가 해제된다.
- 실행 도중 변경될 수 있다.(Read-Write)

  ```swift
  // 전역 변수: 데이터 영역 (.data), Read-Write
  var name: String = "Index"
  var age: Int = 26
  
  struct People {
      // 타입(static) 상수: 읽기 전용 데이터 영역 (.rodata), Read-Only
      static let country: String = "Korea"
      
      // 인스턴스 프로퍼티:
      // — 선언된 컨텍스트가 전역(let people)일 경우 .data (Read-Only*)
      // — 함수 내부(let localPeople)일 경우 스택 (Read-Write)
      var name: String
  }
  
  // 전역 상수: 데이터 영역 (.data), Read-Only*
  let people = People(name: "Index")
  ```

### 타입 메타데이터
- Swift 데이터 영역에는 **런타임에 타입 자체를 설명해 주는 메타데이터**가 올라가 있어서, 제네릭 처리, 런타임 캐스팅, 동적 디스패치 등이 가능해진다.
- 이 타입이(Person, Int, String 등) 메모리에서 어떻게 생겼는지, 어디에 무엇이 들어있는지 등을 적어 놓은 설명서이다.
- 필드 위치, 크기, 프로토콜 구현 정보 등 포함
- 데이터 영역에 저장 -> 프로그램이 동작할 때 언제든 참조한다.

---

### 3) Heap 영역
- 동적 메모리 할당을 위해 사용된다.
- 힙 메모리는 프로그래머가 명시적으로 할당하고, 해제해야 하며, 힙 메모리 크기는 가상 메모리 크기에 의해 결정된다.
- 힙 매모리는 느리게 접근 되지만, 프로그래머가 필요에 따라 메모리를 할당하고 해제할 수 있어서 유연성이 높다.
- 클래스 인스턴스, 클로저와 같은 **참조 타입**의 값이 힙에 자동 할당된다.

  ```swift
  class People {
      let country: String = "korea"
      let age: Int = 26
  }
  
  // 인스턴스는 Heap 영역에 할당 된다. 
  // Heap 메모리는 가상 메모리의 크기에 의해 결정되며, Heap 메모리의 크기는 실행 시점에 결정된다.
  let people = People()
  ```

  ---

### 4) Stack 영역
- 함수 호출과 로컬 변수의 생명주기를 관리한다.
- 스택은 LIFO(Last in First Out) 방식으로 동작하며, 함수가 호출될 때마다 새로운 스택 프레임이 생성되고, 함수가 종료될 때 스택 프레임이 해제된다.

```swift
// result는 스택 영역에 할당된다.
// 함수가 종료되면 result 변수는 자동으로 스택에서 해제된다,
func add(a: Int, b: Int) -> Int {
    let result = a + b
    return result
}
```

## Reference
- https://tdcian.tistory.com/405





<!-- 
## 1. let 사용이 성능적으로 유리한 이유

- Stack 메모리 사용으로 메모리 할당이 빠르다.
- 컴파일러가 최적화 가능하여 불필요한 연산을 제거한다.
- 멀티스레드 환경에서 안전하며 동기화 비용이 절감된다.
- CPU 명령어 최적화로 실행 속도 증가한다.
- ARC 부담 감소로 불피요한 참조 카운트 연산이 감소한다.



## Stack vs Heap 

1. Stack

   - 함수나 스코프 내에 선언된 **값타입(Valur Type)**은 Stack에 저장된다.
   - 메모리 할당과 해제가 빠르다 **(LIFO 방식)**
   - let, var 모두 Stack에 저장될 수 있다 **(값 타입일 경우)**
   - 값 타입(Value Type, Struct, Int, String, Array 등)

     ```swift
     func example() {
         var number: Int = 10 // 값 타입(Int)이므로 Stack에 저장됨
         number += 5 // 여전히 Stack에서 관리됨
     }
     ```

     

2. Heap

   - 객체(클래스, 클로저 등)처럼 **참조 타입(Reference Type)** 은 Heap에 저장된다.
   - 여러 변수에서 공유될 수 있으며, ARC로 관리된다.
   - 메모리 할당과 해제가 상대적으로 느리다.
   - 참조 타입(Reference Type, Class, Closure 등)

     ```swift
     class Person {
         var name: String
         init(name: String) {
             self.name = name
         }
     }
     
     func example() {
         var person1 = Person(name: "Alice") // Heap에 저장됨
         var person2 = person1 // 같은 객체를 참조 (참조 카운트 증가)
     
         person1.name = "Bob" // 변경하면 person2도 영향을 받음 (같은 객체이므로)
     }
     ```

     



### 	
 -->
