---
title: "[Concurrency] Task-3"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
---

## 1. Task 클로저에서 self 키워드 사용

- Task {} 로 작업을 만들 수 있다.

- 클로저를 할당하면 클로저를 바로 실행하면서 Task를 생성한다.

  ```swift
  struct Work: Sendable {}
  
  class Worker {
      var work: Task<Void, Never>?
      var result: Work?
    
      deinit {
          print("인스턴스 해제")
      }
    	
      func start() {
          // 클로저를 통해 작업 생성
          work = Task {
              print("작업의 시작")
              try? await Task.sleep(for: .seconds(3))
              // 주의: Task클로저에서 외부변수 result 접근
              // self를 부쳐도 된다(원칙이 아님.. 암시적으로 self를 캡처하기 때문-> 문법적 약속)
              // 암시적 캡처란 현재 실행 컨텍스트를 캡처하여 현재의 액터 또는 클래스 인스턴스와 같은 실행 환경을 포함하기 때문에 이미 컴파일러가 self를 안전하게 참조할 수 있도록 처리하기 때문에 명시적으로 캡처할 필요가 없는 것이다.
              result = Work()
              print("작업의 완료")
          }
      }
    	
      // 클래스 내부에서 @escaping 클로저 사용하는 경우
      // (self가 캡처되니 주의해서 사용해라는 의미에서) self 키워드 반드시 필요하다(원칙 -> 문법적 약속)
      func start2() {
          DispatchQueue.global().async {
              self.result = Work()
          }
      }
  }
  ```

  

## 2. Task 클로저에서 [weak self] 사용 필요 x

- [weak self] in 쓸 필요 없다.

- 이유: Task는 작업이 끝나면 self 참조도 해제가 되어 강한 순환 참조가 일어날 수 없다.

  ```swift
  class Worker {
      var work: Task<Void, Never>?
      var result: Work?
    
      deinit {
          print("인스턴스 해제")
      }
    	
      func start() { 
          work = Task { // [weak self] in // 쓸 필요 없다
              // 이유: Task는 작업이 끝나면 self 참조도 해제가 된다
              print("작업의 시작")
              try? await Task.sleep(for: .seconds(3))
              result = Work()
              print("작업의 완료")
          }
      }
    
      func start2() { 
          // 비동기작업이 20초 걸린다고 가정시 self를 캡처한다면 20초동안 붙잡아두는데 이렇게 오래동안 붙잡아두는 상황을 피하기 위해 [weak self]를 사용은 가능하다. 일반적인 상황에서는 사용하지 않는다.
          work = Task { [weak self] in 
              print("작업의 시작")
              try? await Task.sleep(for: .seconds(3))
              self?.result = Work()
              print("작업의 완료")
          }
      }
    
      // detached를 붙히면 self 필수이다. 
      // detached도 작업의 종류 중 하나인데 독립적인 작업을 만드는 것이다.
      // 기존의 컨텍스트를 물려받지 않고(메타데이터를 상속해서 사용하지 않고 즉 무시하고) 독립적인 작업을 만든다.
      func start3() { 
            work = Task.detached {
                print("작업의 시작")
                try? await Task.sleep(for: .seconds(3))
                self.result = Work()
                print("작업의 완료")
            }
       }     
  
       func start4() {
        	DispatchQueue.global().async { [weak self] in
            	self?.result = Work()
          }
      }
  }
  ```

  
