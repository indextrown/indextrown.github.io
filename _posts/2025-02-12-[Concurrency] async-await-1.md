---
title: "[Concurrency] async-await-1"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
---

## 1. 기존의 비동기 함수

### 기존의 비동기 함수 정의 방법

- 오래 걸려서 얻는 결과값을 반드시 콜백 클로저 형태로 돌려받아야 했다.
- 올바르지 않은 형태

  ```swift
  // 기존 방식에서 잘못된 함수 설계의 형태
  func getImage1() -> UIImage? {
      var image: UIImage?
      
      /// 오래 걸리는 일(2번 cpu에게 일을 시킨다)
      DispatchQueue.global().async { 
          sleep(5)
          image = UIImage(systemName: "heart")
      }
      ///
    
      /// 1번 cpu에서 일을 한다
      return image 
      ///
  } // 기다리지 않고 image는 무조건 nil이 나옴.. 
  ```

- 올바른 형태

  ```swift
  // 올바른 형태 (콜백함수 방식으로 설계해야 한다)
  func getImage2(callback: @escaping (UIImage?) -> Void) {
      
      // 오래 걸리는 일
      DispatchQueue.global().async {
          sleep(5)
          let image = UIImage(systemName: "heart")
          callback(image) // 콜백함수를 호출하여 데이터 전달
      }
  }
  ```

  

## 2. async/await라는 개념이 등장

- getImage1()처럼 리턴을 하는 것도 가능하도록 설계 가능해졌다.

- ⚠️**비동기 작업을 수행하면서도 특정 작업의 순서를 보장하고 싶을 때 `await`을 사용**

  ```swift
  // async: (이미지를 받아오는데) "오래걸리는 함수" 의미
  func getImage() async -> UIImage? {
      var image: UIImage?
      image = UIImage(systemName: "heart")
      return image
  }
  
  // async 함수는 호출시 await로 호출해야한다, Task 내에서 호출해야한다.
  // Task는 비동기 작업을 의미
  Task {
      let image1 = await getImage()
      let image2 = await getImage()
      let image3 = await getImage()
      let image4 = await getImage()
  }
  ```

- 비동기 함수 안에서도 await 호출 가능하다. 이때는 Task 필요 x

  ```swift
  func doSomething() async {
      let image1 = await getImage()
      let image2 = await getImage()
      let image3 = await getImage()
      let image4 = await getImage()
  }
  ```

- 기존 방식인 sleep -> Task.sleep 방식으로 변경 
- Sleep(5)는 해당 CPU가 **일을 하지 못하게** 만드는 코드였다.(Blocking 방식)
- Task.sleep은 함수가 실행되다가 **잠깐 멈췄다가 나중에 n초 뒤에 다시 실핼할 수 있다.**(non-Blocking 방식)
  - 스레드가 비우게 만들어서 이 스레드에서 **다른 일처리를 가능**하게 해준다.
  - Await: **다시 실행되기를 기다리겠다**

  

  ```swift
  // async: (이미지를 받아오는데) "오래걸리는 함수" 의미
  func getImage() async throws -> UIImage? {
      var image: UIImage?
    
      // sleep(5)
      // 기존 5초간 잠재우는 방식에서 변경
      try await Task.sleep(for: .seconds(5)) 
      // try가 들어간 에러를 던질 수 있는 함수이므로 함수 정의부분에 throws 추가(에러를 다시 밖으로 던질 수 있어야 한다)
      // 이유: 함수 내부에서 do-catch 문 처리를 하지 않아서 throws 키워드를 붙혀야 한다
      // 오래동안 걸리는 비동기 함수로 정의되어서 await도 추가..
    	
      image = UIImage(systemName: "heart")
      return image
  }
  
  
  // try? throws즉 에러를 던지지 않아도 된다
  // 에러 발생시 nil 리턴
  func getImage() async -> UIImage? {
   
      // 이를 실행하면 중단됬다가 5초뒤에 재개가능
      // 그동안 이를 사용하는 스레드는 다른 일처리가 가능해짐
      // 이미지가 생기는 시점에 다시 일처리가 재개
      try? await Task.sleep(for: .seconds(5)) 
      let image = UIImage(systemName: "heart")
      return image
  }
  
  // 비동기로 정의된 함수를 await로 호출해야한다는 의미는 (1)비동기는 함수가 오래 걸릴 수 있는 함수임을 의미하기도 하지만 (2)잠시 멈췄다가 다시 실행될 수 있는 함수이다.
  Task {
      let image = await getImage()
  }
  ```

  
