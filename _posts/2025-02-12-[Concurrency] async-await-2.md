---
title: "[Concurrency] async-await-2"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
---

## 1. GCD 비동기 vs Swift ConCurrency 비동기

### GCD 비동기

- 다른 쓰레드로 일을 시키고, 기다리지 않는다.
- 해당 작업이 끝나는 시점에 콜백 함수를 통해 값을 리턴 받거나 끝난 시점을 알려준다.

  ```swift
  // 정의
  func method(closure: @escaping (String) -> Void) {
      // 함수 내부 정의
      closure(result)
  }
  
  // 실행
  method { result in
      print(result)	      
  }
  ```

### Async 비동기 "**함수**"

- async 키워드를 보면 먼저 생각할 것 **"(1) 함수가 오래 걸릴 수 있다" "(2) 실행되던 함수가 중간에 멈췄다가 재개될 수 있다."**
- 중간에 잠깐 멈췄다가(suspend) 다시 재개(resume)될 수 있는 함수다.
- CPU(쓰레드)는 해당 (함수) 작업을 실행시키지만 중간에 멈출 수 있는 포인트(suspension point)에서 작업의 진행상황을 시스템(운영체제)에 잠깐 저장했다가 나중에 다시 실행시킬 수도 있다.

- (함수 실행시 비동기 컨텍스트에서 호출해야한다)

  ```swift
  // 정의
  func asyncMethod() async -> String {
      // 함수 내부 정의
      let result = await otherMethod()
      return result
  }
  
  // 실행
  // Task: 비동기적인 환경을 만들어준다
  Task {
      let result = await asyncMethod()
      print(result)
  }
  ```

## 2. 비동기(async)함수 정리

- 중간에 잠깐 멈췄다가(suspend or pause) 재개(resume)될 수 있는 함수이다.
- Cpu(쓰레드)는 해당 (비동기 함수) 작업을 실행시키지만 중간에 멈출 수 있는 포인트(suspension point)에서 쓰레드 제어권을 시스템(운영체제)에 넘긴다. 시스템은 다른 작업을 수행할 수 있다.
- 반드시 작업(Task) 내부 또는 다른 비동기 함수 내부(즉 비동기 컨텍스트)에서만 호출 가능하다.
- 데드락 원천적 방지(non-blockig 방식) 즉 잠시 멈춘 동안에 쓰레드를양보해서 다른 작업이 사용할 수 있도록 양보.

## 3. GCD vs async/await (Pyramid of doom)

### GCD 불편함

- 비동기 함수의 일이 종료되는 시점을 연결하기 위해 끊임없는 콜백함수를 연결해야 함.
- 죽음의 피라미드...

  ```swift
  func gcdImageData(completionBlock: (_ result: Image) -> Void) {
      loadWebResource("dataprofile.txt") { dataResource in
          loadWebResource("imagedata.dat") { imageResource in
              decodeImage(dataResource, imageResourc) { imageTMP in
                  dewarpAndCleanupImage(imageTMP) { imageResult in
                      completionBlock(imageResult)
                  }
              }
          }
      }
  }
  ```

### async/await

- 콜백함수를 계속 들여쓰기 할 필요없이 반환(return) 시점을 기다릴 수 있고, 직관적인 코드 처리 가능하다.
-  오래 걸릴 수 있는 함수를 호출하면 **데이터가 생기는 시점**에 변수에 바인딩 가능하다.
- **함수이 호출이 오래걸리더라도 콜백 방식 사용 필요 없디.**
- 동기방식으로 순차적으로 코드를 읽을 수 있다.
- ⚠️ 각 비동기 함수가 완료된 후에 다음 줄이 실행된다! 

  ```swift
  
  func asyncImageData() async throws -> Image {
      let dataResource = try await loadWebResource("dataprofile.txt")
      let imageResource = try await loadWebResource("imagedata.dat")
      let imageTmp = try await decodeImage(dataResource, imageResource)
      let imageResult = try await dewarpAndCleanupImage(imageTMP)
      return imageResult
  }
  ```
  
  

