---
title: "[Concurrency] async-await-3"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
---

## 1. 에러 처리

- 에러를 던지는 비동기 함수 정의

- 에러를 던질 수 있는 비동기함수 실행시 try await 

- async 다음에 throws가 와야한다.

- try 다음에 await이 와야한다.

  ```swift
  // 1
  func throwingGetImage() async throws -> UIImage? {
      // 오래 걸리는 일.., 에러가 던질 수 있는 코드
      try await Task.sleep(for: .seconds(2))
      return UIImage(systemName: "heart")
  }
  
  // 에러를 던질 수 있는 비동기 함수 정의
  func asyncMethod() async throws -> String {
      let result = try await otherMethod()
      return result
  }
  
  // 원칙적 방법
  Task {
      do {
          let totalString = try await asyncMethod()
          print(totalString)
      } catch {
        	
      }
  }
  
  let task = Task {
      // 1. asyncMethod는 비동기 함수라서 await 붙혀준다
      // 2. 에러를 던질 수 있으므로 try 키워드를 붙혀준다
      // 3. 원칙적 처리로는 do-catch가 맞지만 처리하지 않아도 된다
      // 이유: Task 자체가 에러를 던질 수 있다
      let result = try await asyncMethod()
      print(result)
  }
  
  Task {
      await task.result
  }
  ```
  
  ## 2. 비동기 함수 실행방법 2가지
  
  - (1) Task 안에서 async 함수 호출
  
    ```swift
    Task {
        let image = await getImage()
    }
    ```
  
  - (2) 다른 async 함수 안에서 async 함수 호출 가능(비동기 컨텍스트)
  
    ```swift
    func getImages() async -> [UIImage?] {
        let image1 = await getImage()
        let image2 = await getImage()
        let image3 = await getImage()
      	
        return [image1, image2, image3]
    }
    
    Task {
        let images = await getImages()
    }
    ```
    
  
  ## 3. 언제든지 비동기적인 컨텍스트 만드는 것 가능
  
  - 비동기함수는 비동기적인 컨텍스트에서 호출되야한다 
  
    ```swift
    func someSyncFunc() {
        print("동기적인 작업 시작")
        Task {
            try await Task.sleep(for: .seconds(2))
            print("비동기적인 작업내에서의 작업")
        }
        print("동기함수 작업 종료")
    }
    ```
  
  
  ## 4. 비동기 함수 내에서 비동기 함수 호출
  
  - 각각의 함수 자체가 중간에 멈췄다가 다시 실행할 수 있다.
  - 순서대로 진행된다.
  - 비동기 함수 내에서 다른 비동기 함수를 호출을 하는것은 현재의 실행 컨텍스트 내에서 실행을 시키는 것이다(취소 전파도 가능하고, 하위 작업을 만드는 것이 아니다). 
  - 즉 구조적 동시성이 아니다.
  
    ```swift
    func parentFuncgion() async throws {
        // async 함수 내에서 다른 async 함수 호출: 동일한 비동기 컨텍스트 내에서의 실행(작업의 입루)
        try await asyncFunction()
        try await asyncFunction()

        // Task를 사용하여 명시적으로 다른 작업(Task) 생성 가능(구조적 동시성은 아니고 따로 작업을 만든다) 병렬 실행
        // 자식 작업의 생성 방식은 아니다
        Task {
            try await asyncParentFunction()
            try await asyncParentFunction()
        }
        
        print("비동기 함수 실행의 종료")
    }
    ```
  
    
  
  
  
  

