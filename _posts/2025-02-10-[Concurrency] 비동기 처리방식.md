---
title: "[Concurrency] Swift 비동기 처리방식"
tags: 
- Concurrency
use_math: true
header: 
  teaser: 
---

## 📝 Swift 비동기 처리방식 

### 1. NSThread

- Object-C 시절부터 사용되었다

- 직접 스레드를 셍성하고 괸리해야 한다.

- 수동으로 동기화 해야하다.

- GCD나 OperationQueue에 비해 사용성이 떨어진다.

- ❌ 현재 사용 여부: 현재 거의 사용되지 않는다.

  ```swift
  let thread = Thread {
    	print("Background 작업 실행")
  }
  
  thread.start()
  ```

### 2. OperationQueue (iOS 2.0/2008)

- GCD보다 객체 지향저깅고 세밀한 제어 가능하다.

- 여러 작업을 동시에 실행 가능하다.

- 의존성(Dependency) 설절 가능하다.

- ✅ 현재 사용 여부: 여러 작업 간 의존성이 있는 경우 사용된다.

  ```swift
  let queue = OperationQueue()
  let operation = BlockOperation {
    	print("Background 작업 실행")
  }
  queue.addOperation(operation)
  ```

### 3. GCD(Grand Central Dispatch) (iOS 4.0/2010)

- 백그라운드 실행이 간편하다.

- 성능 최적화된 C 기반 API이다.

- 메인 스레드에서 UI 업데이트 가능하다.

- ✅ 현재 사용 여부: 많이 사용된다. (백그라운드 처리, UI 업데이트)

  ```swift
  DispatchQueue.gloal(qos: .background).async {
   		// Background 작업 실행
    	let result = heavyTask() 
    
    	DispatchQueue.main.async {
        	updateUI(with: result)
      }
  }
  ```

### 4. RxSwift (ReactiveX)

- 오픈소스 라이브러리이다.

- 리액티브 프로그래밍을 위한 강력한 프레임워크다.

- 비동기 데이터 스트림을 선언적으로 처리 가능하다.

- Obserable과 Observer 패턴 사용한다.

- ✅ 현재 사용 여부: 많이 사용된다. (MVVM 아키텍쳐에서 활용됨)

  ```swift
  import RxSwift
  
  let disposeBag = DisposeBag()
  let observable = Observable.just("Background 작업 실행")
  
  observable.subscribe(onNext: { value in
      print(value)
  }).disposed(by: disposeBag)
  ```

### 5. Combine (iOS 13.0/2019)

- 리액티브 프로그래밍 프레임워크이다.

- 데이터 스트림을 다룰 때 유용하다.

- Publisher와 Subscriber 패턴을 사용한다.

- ✅ 현재 사용 여부: 특정 상황에서 사용된다. (API 응답, 데이터 스트림 처리 등)

  ```swift
  import Combine
  
  let publisher = Just("Background 작업 실행")
  let cancellable = publisher.sink { value in
   		print(value)                                
   }
  ```

### 6. Async/await (Switt Concurrency) (iOS 15.0/2021/Swift5.5)

- 가독성이 뛰어난 최신 비동기 처리 방식이다.
- 동기 코드처럼 작성 가능하다
- Task를 활용해 SwiftUI에서도 사용 가능하다.
- ✅ 현재 사용 여부: 가장 추천되는 방식이다. (Swift 5.5+ 환경에서 최적의 선택)

```swift
func fetchData() async -> String {
  	// Background 작업 실행
		try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
  	return "Fetched Data"
}

Task {
		let data = await fetchData()
  	print(data)
}
```



## ✅ 정리 (비동기 처리 방식 비교)

| 도입 순서 | 비동기 방식           | 특징                                       | 현재 사용 여부         |
| --------- | --------------------- | ------------------------------------------ | ---------------------- |
| **1**     | `NSThread`            | 직접 스레드 관리, 수동 동기화 필요         | 거의 안 씀 ❌           |
| **2**     | `OperationQueue`      | 객체 지향적, 작업 의존성 설정 가능         | 사용됨 ✅               |
| **3**     | `GCD (DispatchQueue)` | 백그라운드 처리, UI 업데이트 가능          | 많이 사용됨 ✅          |
| **4**     | `RxSwift`             | 리액티브 프로그래밍, Observable 활용       | 많이 사용됨 ✅          |
| **5**     | `Combine`             | 데이터 스트림을 다루는 리액티브 프로그래밍 | 특정 상황에서 사용됨 ✅ |
| **6**     | `async/await`         | 최신 Swift 비동기 처리 방식, 가독성이 좋음 | 가장 추천됨 🚀✅         |
