---
title: "[Concurrency] Task-1"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
---

## 1. 기존 동시성 프로그래밍(GCD)

- 대기열 / 큐를 사용하였다
- 대기열에 넣어서 2번 cpu에 일을 시키는 방식으로 비동기 처리

  ```swift
  // 기존 동시성 프로그래밍(GCD)
  // 기본적으로 다른 쓰레드로 보내지 않았다면 1번 쓰레드(cpu)에서 실행한다
  print("메인 쓰레드에서 실행 - 1")
  print("메인 쓰레드에서 실행 - 2")
  
  // 무조건 2번(또는 특정의 백그라운드) 스레드로 보내서 실행하겠다는 의미(클로저 내에서는 순차적 실행) 
  DispatchQueue.global().async {
      print("백그라운드 쓰레드에서 실행 - 1")
      print("백그라운드 쓰레드에서 실행 - 2")
  }
  
  print("메인 쓰레드에서 실행 - 3")
  print("메인 쓰레드에서 실행 - 4")
  ```

## 2. Swift Concurrency(asyc/await/task)

### Task

- 비동기적인 일처리를 할 수 있는 하나의 **실행 작업 단위**를 만드는 것이다.
- 기존의 GCD방식과 거의 유사하다. (2번 스레드로 보내서 일을 시킨다는 점에서)

  ```swift
  print("메인 쓰레드에서 실행 - 1")
  print("메인 쓰레드에서 실행 - 2")
  
  Task {
      print("백그라운드 쓰레드에서 실행 - 1")
      print("백그라운드 쓰레드에서 실행 - 2")
  }
  
  print("메인 쓰레드에서 실행 - 3")
  print("메인 쓰레드에서 실행 - 4") 
  ```

### 서로 다른 작업 단위

- 각각의 Task는 다른 작업 단위이다.
- 예를 들어 Task1은 2번 Cpu에 일을 시킬 수 있고 동시에 Task2는 3번 Cpu에게 일을 시킬 수 있다.
- Task는 병렬적으로 동시에 일을 할 수 있도록 해준다.
- Task 클로저 내부는 순차적으로 실행된다.

  ```swift
  // Task 1: // 2번 cpu
  Task {
      print("백그라운드 쓰레드에서 실행 - 1")
      print("백그라운드 쓰레드에서 실행 - 2")
  }
  
  // Task 2: 3번 cpu
  Task {
      print("백그라운드 쓰레드에서 실행 - 3")
      print("백그라운드 쓰레드에서 실행 - 4")
  }
  
  // -> 2번, 3번 병렬적으로 동시에 일을 할 수 있게 만들어준다
  
  ```

### Task를 변수/상수에 담을수도 있다

- Task 자체를 타입으로 생성을 해서 변수에/상수에 담을 수 있다.
- 작업을 변수/상수에 담으면 변수에 접근하여 cancel 메서드(작업 취수) 사용 가능.
- Never: 일반적인 구조에서 에러 발생하지 않는다.

  ```swift
  let task: Task<Void, Never> = Task {
      print("비동기적인 일 - 7")
      print("비동기적인 일 - 8")
  }
  task.cancel()
  ```

### Task 작업의 결과로 문자열을 리턴할 수 있다

- task에서 문자열을 접근할 수 있다.

  ```swift
  let task: Task<String, Never> = Task {
      print("비동기적인 일 - 1")
      print("비동기적인 일 - 2")
      return "문자열"
  }
  // task.value -> Task 성공의 결과값에 접근
  // task.result -> Task를 Result 타입으로 변환 가능
  ```

### 동기 함수 내에서 비동기적인 일처리를 할 수 있다

- 함수 내부에 작업을 만들어서 비동기적인 일처리 가능하다.

  ```swift
  func doSomething() {
      Task {
          try await Task.sleep(for: .seconds(2))
          print("함수 내부의 비동기적인 일 - 1")
          print("함수 내부의 비동기적인 일 - 2")
      }
  }
  /*
  함수 내부의 비동기적인 일 - 1
  함수 내부의 비동기적인 일 - 2
  */
  
  func doSomething2() {
      print("함수 내부의 동기적인 실행 - 1")
      
      // 2번 Cpu에서 비동기적인 일 실행 가능
      Task {
          // 2초동안 일을 멈추는 코드.. 즉 2초정도 걸림
          try await Task.sleep(for: .seconds(2))
          print("함수 내부의 오래걸리는 일")
      }
      print("함수 내부의 동기적인 실행 - 2")
  }
  
  /*
  함수 내부의 동기적인 실행 - 1
  함수 내부의 동기적인 실행 - 2
  함수 내부의 오래걸리는 일
  */
  ```


### 작업의 우선순위는 6가지가 존재한다

- 우선순위 지정은 선택사항이다.
- 우선순위를 사용하지 않는 방법이 일반적이다.

  ```swift
  // 선택사항 우선순위 지정가능
  task = Task(priority: .우선순위) {
    // 비동기적인 일(비동기 함수 실행)
  }
  
  // 현재 우선순위를 볼 수 있다
  Task(priority: .userInitiated) {
    	print("우선순위: \(Task.currentPriority)")
  }
  
  /// 작업 실행 우선 순위의 종류
  /// ===============================
  /// TaskPriority.userInitiated - 25
  /// TaskPriority.high - 25
  /// TaskPriority.medium - 21
  /// TaskPriority.low - 17
  /// TaskPriority.utility - 17
  /// TaskPriority.background - 9
  /// ===============================
  ```
  

### 작업은 지금 실행 컨텍스트(실행되고 있는 환경)의 메타데이터를 그대로 상속해서 사용한다(구조적 동시성은 아니다)

- 내부에서 자동으로 현재의 컨텍스트(어떤 환경에서 실행되는지)를 파악하고

- 우선순위 -> 실행액터 -> 로컬변수(Task-Local 변수)

- 취소는 상속되지 않는다.

  ```swift
  let task = Task(priority: .background) {
      sleep(2)
      print("비동기적인 일 실행: \(Task.currentPriority)")
      print("Task 내부에서 취소 여부: \(Task.isCancelled)")
    
      // 내부의 작업 -> 부모 작업의 메타데이터(우선 순위 등)를 상속 사용(취소는 상속 불가)
      // 작업 안에서 작업을 다시 생성하는 것은 구조화를 시키지 않는다(하위 작업이 되는 것이 아니다)
      Task {
          print("비동기적인 일 실행: \(Task.currentPriority)")
          print("Task 내부의 Task에서 취소 여부: \(Task.isCancelled)")
      }
  }
  
  // task.cancel() 하더라도 내부 Task는 실행된다 -> 상속이 안되기 때문
  task.cancel()
  
  /*
  print("비동기적인 일 실행: \(Task.currentPriority)")
  print("Task 내부의 Task에서 취소 여부: \(Task.isCancelled)")
  */
  ```

  

### 특징

- 작업은 비동기적인 일처리를 위한 기본단위이다. (모든 비동기적인 일처리는 Task 일부)

- 우선순위 지정은 선택사항이다.

- 구조체로 만들어져있다.

- 인스턴스를 생성하자마자 operation 파라미터에 해당하는 클로저를 전달하면서, 작업(Task)을 생성 및 클로저로 전달된 작업을 즉시 실행한다.

- 즉 클로저를 할당하여 작업을 만들고 클로저를 바로 실행하여 Task를 생성한다.

- Task 클로저 내에서 비동기적인 일 수행 가능하다.

- 비동기 실행 컨텍스트(비동기 함수기 실행될 수 있는 환경)을 만드는 것이다.

- Swift Concurrency에서 작업 Task는 기본 단위이다.

- Task는 트레일링 클로저 형태로 사용한다.

- 작업 클로저를 생성하자마자 작업 즉시 실행한다.

- https://developer.apple.com/documentation/swift/task

  ```swift
  // 에러를 던지지 않는 함수
  Task(priority: <#T##TaskPriority?#>, operation: <#T##() async -> Sendable#>)
  // 에러를 던질 수 있는 함수
  Task(priority: <#T##TaskPriority?#>, operation: <#T##() async throws -> Sendable#>)
  ```

  
  
  
  
  

​	
