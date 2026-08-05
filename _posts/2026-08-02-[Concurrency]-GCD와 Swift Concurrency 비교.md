---
title: "[Concurrency] GCD와 Swift Concurrency 비교"
date: 2026-08-02
tags:
  - Concurrency
---

<!-- ## 동시성 프로그래밍

Computer Science에서는 특정 프로세스의 실행 시간이 다른 프로세스의 흐름과 겹치는 상황에서 동시에 실행한다고 말합니다.

## Swift 5.5 이전의 동시성

```swift
// 동시성 예제 코드
```

Swift 5.5에서 새로운 모델을 제시하기 전까지는 GCD(Grand Central Dispatch)와 CompletionHandler를 사용해 비동기 프로그래밍을 작성해왔습니다. CompletionHandler로 비동기가 끝나는 시점에 필요한 작업을 수행했습니다.

기존 GCD 방식은 너무 많은 CallBack이 발생하게 되고 들여쓰기가 많아지면서 가독성이 저하될 수 있었습니다. 또한 모든 case에서 CompletionHandler를 사용해 에러를 처리해주어야 했고 순환 참조의 발생 또한 개발자가 고려해야 하는 부분이었습니다.

&nbsp;

앱을 개발하다 보면 네트워크 요청, 이미지 처리, 파일 입출력처럼 시간이 오래 걸리는 작업을 만나게 됩니다.

이러한 작업을 메인 스레드에서 실행하면 작업이 끝날 때까지 화면이 멈추거나 사용자 입력에 반응하지 못할 수 있습니다. 이를 해결하기 위해 여러 작업을 효율적으로 나누어 처리해야 하는데, 이때 등장한 개념이 동시성 프로그래밍입니다.

&nbsp; -->

앱을 실행하면 하나의 주된 Main Thread가 배정되고 화면을 그리는 일처리를 하게 됩니다. 제가 사용하는 iphone 15 Pro Max는 화면 주사율이 최대 120Hz를 지원합니다. 즉 1초에 120번 화면을 그리는 동작을 Main Thread가 담당하게 됩니다.

Thread는 화면을 그리는 동작 뿐만 아니라 네트워크 요청, 이미지 처리, 파일 입출력처럼 시간이 오래 걸리는 작업도 처리합니다.  
이러한 작업을 Main Thread에서 처리하면 어떻게 될까요? 

Main Thread는 이미 1초에 120번 화면을 그리는 동작을 하고 있는데 무거운 작업을 하게 되면 해당 작업이 끝날 때 까지 화면이 멈추거나 사용자 입력에 반응하지 못할 수 있습니다. 이를 해결하기 위해 여러 **작업을 효율적으로 나누어 처리**해야 하는데 이때 등장한 개념이 **동시성 프로그래밍입니다.** 

## CS 개념

**동시(Concurrent)**는 CPU 코어 보다 더 많은 숫자의 소프트웨어 Thread를 생성하고 실행합니다. 실행되던 Thread 정보를 저장한 상태에서 context switching이 발생하면 **오버헤드**가 발생할 수 있고 운영체제에 의해 물리적인 CPU 코어보다 많은 Thread를 과하게 생성해서 **Thread 폭팔**도 발생할 수 있습니다. (GCD 방식)

**병렬(Parallel)**은 실제 물리적인 CPU 코어가 동시에 일하는 것입니다. CPU 코어 하나당 하나의 Thread만 존재하게 되고, context switching이 일어나지 않습니다. 이것이 기존의 GCD와는 다르게 **협력적 쓰레드풀**이 동작하는 것이라고 말합니다. 기존의 GCD 이상으로 효율적으로 동작할 수 있는 이유는 Thread 사용하지 않는 동안 Thread 제어권을 운영체제에 양보하기 때문에(다른 작업이 Thread를 점유하고 사용할 수 있기 때문에) GCD처럼 Thread를 계속 생성하지 않고도 효율적으로 동작할 수 있는 것입니다. (Swift Concurrcncy 방식)  [참고](https://www.inflearn.com/community/questions/1632250/협력적-쓰레드-풀에서-쓰레드-운영방식-질문-드립니다?srsltid=AfmBOoqVVslrI5D5BxXTm-Dmkfv8uxcmvGYkxwq95sFr7Zy3IxqVyUV3)

**협력적 쓰레드 풀(Cooperative Thread Pool)**은 여러 비동기 작업이 한정된 수의 Thread를 함께 사용하면서 스스로 실행권을 양보하도록 설계된 Thread 관리 방식입니다. Non-Blocking 방식을 통해 종단 지점에서 스스로 Thread를 운영체제에 양보해서 즉 제어권을 반환해서 다른 일처리를 할 수 있습니다. 

**프로세스(Process)**란 컴퓨터에서 실행되고 있는 하나의 프로그램/어플리케이션입니다. 별도의 독립된 메모리 영역을 운영체제로부터 할당받아 실행됩니다.

**스레드(Thread)**란 Process 내에서 실행되는 실행 흐름의 단위고 프로그램 내에서 여러 Thread가 동시에 실행되어 하나의 프로그램이 동작할 수 있습니다.

<!-- ## 동시성(Concurrency)

여러 작업을 동시에 실행하는 것이 아니라 CPU가 작업마다 시간을 분할해 적절하게 Context Switching함으로써 동시에 실행되는 것처럼 보이게 하는 것을 동시성이라고 부릅니다.

## 병렬성(Parallelism)

독립적으로 동시에 여러 작업을 실행하는 것을 병렬성이라고 부르며, 동시성과는 다르게 여러 작업을 다른 코어, 프로세스에서 동시에 실행하는 것을 병렬성이라고 부릅니다. -->

## GCD

Objective-C부터 존재하던 개념으로 동시성 프로그래밍에 대한 높은 추상화를 제공합니다. Serial DispatchQueue는 한 번에 하나의 Task를 순차적으로 실행하고 Concurrent DispatchQueue는 많은 작업을 동시에 실행합니다. 두 경우 모두 작업이 실행되는 순서는 FIFO 입니다. GCD를 이용하면 async로 작업을 수행하고 나서 보통 탈출 클로저를 이용한 completion handler를 통해 해당 작업이 끝났을때의 처리를 해주게 됩니다.

## Swift Concurrency

[++WWDC 2021++](https://developer.apple.com/videos/play/wwdc2021/10132/)에서 새로 소개된 동시성 프로그래밍 API입니다. Swift Concurrency는 동시성 프로그래밍을 가독성이 좋은 코드로 작성하고자 도입된 개념입니다. async, await 키워드를 이용해 비동기 코드를 작성할 수 있습니다. await 키워드로 인해 중지되면 이후에 사용해야 하는 데이터를 heap 영역에 저장해 두고, 이후에 다시 heap 영역에서 해당 데이터를 가져와 사용합니다.

## GCD의 비동기 vs Swift Concurrency 비동기 개념 차이

GCD 비동기 함수는 다른 Thread로 작업을 시키고 기다리지 않습니다. 해당 작업이 끝나는 시점에 콜백 함수를 통해 값을 리턴받습니다. **기존 비동기 개념은 작업 진행이 되면서 작업이 끝나는 것을 기다리지 않았습니다. (언젠가 실행되겠지...)**

Swift Concurrency의 async 함수는 중간에 잠깐 멈추었다가(suspend) 다시 재개(resume)될 수 있는 함수입니다. 해당 작업을 실행시키지만 중간에 멈출 수 있는 suspension point에서 운영체제에게 스레드 제어권을 양보하고(작업의 진행상황을 운영체제에 잠시 저장) 나중에 다시 실행할 수 있습니다. **새로운 비동기 개념은 Thread가 해당 작업을 실행시키다가 중간에 멈출 수 있는 suspension point에서 작업의 진행상황을 운영체제에 저장했다가, 나중에 다시 실행시킬 수 있습니다.**

## 문법적 차이: 가독성

```swift
func loadProfile(completion: @escaping (Profile) -> Void) {
    fetchUser { user in
        fetchPosts(for: user) { posts in
            fetchThumbnailURL(for: posts[0]) { thumbnailURL in
                fetchImage(from: thumbnailURL) { image in
                    completion(Profile(user: user, posts: posts, thumbnail: image))
                }
            }
        }
    }
}
```

escaping closure와 completion handler를 이용한 코드 작성 방식은 가독성을 저하시킬 수 있습니다. 이는 [++SE-0296++](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md)에서 제기된 [++Problem 1: Pyramid of doom++](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md#problem-1-pyramid-of-doom)에 해당합니다. GCD 방식의 동시성 프로그래밍은 잦은 completion handler사용으로 너무 많은 콜백이 발생하여 들여쓰기가 중첩되어 가독성을 중첩시킬 수 있습니다.

```swift
func loadProfile() async throws -> Profile {
    let user = try await fetchUser()
    let posts = try await fetchPosts(for: user)
    let thumbnailURL = try await fetchThumbnailURL(for: posts[0])
    let image = try await fetchImage(from: thumbnailURL)

    return Profile(user: user, posts: posts, thumbnail: image)
}
```

반면 같은 코드를 Swift Concurrency로 작성하면 위처럼 작성할 수 있습니다.   
들여쓰기가 적어지고 가독성이 좋은 코드가 되었습니다.

## 문법적 차이: 에러 헨들링 안전성

```swift
func downloadImageWithURL(
    url: URL,
    session: URLSession,
    completionHandler: @escaping (UIImage?, Error?) -> Void
) {
    session.dataTask(with: url) { data, response, error in
        guard let imageData = data else {
            completionHandler(nil, DownloadManagerError.invalidData)
            return
        }

        guard let urlResponse = response as? HTTPURLResponse,
              urlResponse.statusCode == 200 else {
            completionHandler(nil, DownloadManagerError.networkFail)
            return
        }

        let image = UIImage(data: imageData)
        completionHandler(image, nil)
    }.resume()
}
```

기존 방식의 코드에서는 completion handler에 데이터의 에러 정보를 같이 보내주는 방법을 주로 사용합니다. guard 구문을 보면 에러 처리를 위해 completion handler를 사용하지만. 작성하지 않아도 컴파일 에러는 발생하지 않습니다. 따라서 코드 작성 시 에러 핸들링을 누락하지 않았는지 주의할 필요가 있습니다. 개발자가 코드 작성 과정에서 확인해야 하지만, 누락이 있을 수 밖에 없습니다. 또한 발생할 수 있는 에러나 올바른 결과마다 핸들러를 작성해야 하는 번거로움이 있습니다.

```swift
@available(iOS 15.0, *)
func downloadImageWithURLSwiftConcurrency(
    url: URL,
    session: URLSession
) async throws -> UIImage {
    let (data, response) = try await session.data(from: url)

    guard let urlResponse = response as? HTTPURLResponse,
          urlResponse.statusCode == 200 else {
        throw DownloadManagerError.networkFail
    }

    guard let image = UIImage(data: data) else {
        throw DownloadManagerError.invalidData
    }

    return image
}
```

Swift Concurrency로 작성하면 에러 핸들링은 throw로 작성하고, 데이터 전달은 return으로 분리할 수 있습니다. 이런 식으로 작성하면 guard let - else 구문에서 completion handler를 누락하는 실수를 방지할 수 있습니다. 함수에서 에러를 throw하거나 이미지를 return해야 하기 때문입니다. 또한 completion handler를 사용하지 않아도 콜백이 없어 가독성이 좋아집니다.

## 동기화 처리의 차이

동시성 프로그래밍을 할 때 중요한 것은 **하나의 데이터에 여러 쓰레드에서 동시 접근 가능성**입니다. 여러 쓰레드에서 공유될 수 있는(ex: 전역 변수, 타입 저장 속성...) var로 선언된 데이터는 **Thread-Safety** 문제가 발생할 수 있습니다. 여러 스레드가 같은 데이터에 접근하고 값을 변경한다면 동기화 여부에 따라 **Data Race**가 발생할 수 있습니다. 

GCD에서 동기화를 안전하게 처리하는 방법은 DispatchQueue.sync를 통해 순서대로 접근하는 것을 보장하거나 Mutex나 Semaphore를 이용하는 방법 등이 있습니다. 다만 동기화를 올바르게 처리했는지를 컴파일러가 확인해 주지는 않기 때문에 공유 상태에 접근하는 모든 코드가 같은 동기화 규칙을 따르도록 개발자가 코드 작성 시 유의해서 작성하거나 테스팅 및 디버깅을 통해 확인해야 합니다.

Swift Concurrency에서는 이를 컴파일 단계에서 확인해 동기화를 제대로 처리하지 않은 코드가 있다면 컴파일 에러를 발생시킵니다. 개발자의 실수를 미연에 방지해 주는 안전장치 역할을 해주는 것입니다.

#### 예시

```swift
```swift
// 동기화하지 않은 코드
for _ in 0..<numberOfImages {
    downloadManager.downloadImageWithURL(url: url, session: session) { image, error in
        guard let downloadedImage = image else { return }

        // 여러 completion이 동시에 실행되면 Data Race가 발생할 수 있지만 컴파일러는 오류를 발생시키지 않음
        self.finishedImages += 1
        let progress = Float(self.finishedImages) / Float(self.numberOfImages)

        DispatchQueue.main.async {
            self.updateUIs(image: downloadedImage, progress: progress)
        }
    }
}

// 직렬 큐를 이용해 동기화한 코드
private let finishedImagesQueue = DispatchQueue(
    label: "com.example.image-download.finished-images"
)

for _ in 0..<numberOfImages {
    downloadManager.downloadImageWithURL(url: url, session: session) { image, error in
        guard let downloadedImage = image else { return }

        let progress = self.finishedImagesQueue.sync {
            self.finishedImages += 1
            return Float(self.finishedImages) / Float(self.numberOfImages)
        }

        DispatchQueue.main.async {
            self.updateUIs(image: downloadedImage, progress: progress)
        }
    }
}
```

코드를 보면 이미지 다운로드가 완료될 때마다 1씩 증가시킵니다. 하지만 여러 completion handler가 동시에 실행되면 동일한 가변 상태인 finishedImages에 동시에 접근할 수 있으므로 Data Race가 발생할 수 있습니다. finishedImages += 1은 하나의 연산처럼 보이지만 실제로는 기존 값을 읽고 1을 더한 뒤 계산한 값을 다시 저장합니다. 여러 스레드가 이 과정에 동시에 접근하면 일부 증가 연산이 반영되지 않을 수 있습니다. 하지만 GCD를 사용하는 코드에서는 이러한 문제가 있어도 컴파일러가 오류를 발생시키지 않습니다. 따라서 개발자가 공유 상태에 대한 접근을 직접 동기화해야 합니다. 

이를 해결하기 위해서는 DispatchQueue.sync를 이용해 코드를 작성하거나 Mutex나 Semaphore를 이용해 독립적인 접근을 보장해 주어야 합니다. 두 번째 코드에서는 DispatchQueue.sync를 사용해 finishedImages 증가와 진행률 계산이 하나의 직렬 큐에 순차적으로 실행되도록 처리했습니다. 이 외애도 Mutex나 Semaphore 등의 동기화 방식으로 공유 상태에 대한 상호 베타적인 접근을 보장할 수 있습니다.

```swift
try await withThrowingTaskGroup(of: UIImage.self) { group in
    for _ in 0..<self.numberOfImages {
        group.addTask(priority: .background) {
            let image = try await self.downloadManager.downloadImageWithURLSwiftConcurrency(
                url: url,
                session: session
            )

            // 컴파일 에러 발생
            // property 'finishedImages' isolated to global actor 'MainActor' can not be mutated from a non-isolated context
            self.finishedImages += 1
            await self.updateUIs(image: image)
            return image
        }
    }
}
```

반면 Swift Concurrency를 사용하면 data race를 미연에 방지할 수 있습니다. 같은 역할을 하는 코드를 Swift Concurrency를 이용해 작성한 예시입니다. 기존 GCD 코드의 경우 컴파일 에러가 발생하지 않았지만 Swift Concurrency를 사용하면 비 독립적(non-isolated) 구문이 변할 수 있는 프로퍼티에 접근하는 것을 금지한다는 메시지와 함께 컴파일 에러가 발생합니다. 이를 통해 개발자의 실수로 data race문제가 발생하는 것을 방지할 수 있습니다.

## 성능적 차이

GCD를 이용해 코드 작성 시 주의해야 할 점은 thread explosion입니다. thread explotion이 발생하면 context switching이 많아지고 성능이 저하될 수 있습니다. 또한 블록된 스레드가 어떤 자원을 잠그고 있을 때 dead lock을 발생시킬 수 있습니다. 그래서 thread explosion을 막기 위해 하나의 서브시스템에 하나의 DispatchQueue 또는 DispatchQueue 위계(hierarchy)를 할당하는 것이 권장되고 있습니다. 이렇게 하면 서로 연관된 작업이 하나의 스레드에서 실행될 수 있게 됩니다.

반면 Swift Concurrency에서는 보다 편하게 관리할 수 있습니다. Swift Concurrency에서 await으로 중단됐을 때, CPU가 context switching을 해서 다른 Thread를 불러오는 것이 아니라 같은 Thread에서 다음 작업을 실행시킵니다. 즉 하나의 코어가 하나의 스레드를 실행하도록 유지하는 것을 보장합니다.

#### 성능 측정 코드

```swift
// MARK: - GCD
func gcdConcurrency() {
    let backgroundWorkItem = DispatchWorkItem(qos: .background) {
        let array = range.map { number in
            1_000_000 - number
        }
        let _ = array.sorted(by: <)
    }

    let group = DispatchGroup()
    let queue = DispatchQueue(label: "GCD", qos: .background, attributes: .concurrent)

    for _ in 0..<numberOfConcurrency {
        queue.async(group: group, execute: backgroundWorkItem)
    }

    group.wait()
}

// MARK: - Swift Concurrency
func swiftConcurrency() async {
    await withTaskGroup(of: Double.self) { group in
        for _ in 0..<numberOfConcurrency {
            group.addTask(priority: .background) {
                await sortArray()
                return 0
            }
        }
    }
}

private func sortArray() async {
    await Task.yield()

    let array = range.map { number in
        1_000_000 - number
    }

    await Task.yield()
    let _ = array.sorted(by: <)
}
```

![붙여넣은 이미지](/assets/img/2026-08-02-[Concurrency]-GCD와 Swift Concurrency 비교/pasted-image-20260805T062613-2.png)

GCD와 Swift Concurrency가 같은 비동기 작업을 처리할 때 사용하는 스레드 수와 컨텍스트 스위칭 횟수를 비교하기 위해 Instruments의 `System Trace`를 사용했습니다. 템플릿을 열고 Deferred 체크 후 GCD, Swift Concurrency 각각 Run 단위 녹화 하였습니다. 측정 환경에 따른 오차를 줄이기 위해 실기기 iphone 15 pro max 릴리스 모드에서 측정했습니다.

측정 후 각각 Instrument 좌측 목록에서 **Time Profiler의 CPU Usage 그래프를 확인**해서 정렬 버튼을 누르면 CPU 사용량이 크게 상승하는 **구간을 선택**합니다. 구간을 선택하는 방법은 사용량이 상승하기 직전부터 낮아지는 지점까지 우측 타임라인 영역을 마우스로 드래그하면 됩니다. 해당 영역이 분석에 사용되는 범위가 됩니다.

&nbsp;

#### 100만 개의 요소를 가진 배열을 정렬하는 작업  50개를 비동기적으로 실행할 때 실제로 동시에 실행되는 스레드 수  측정

<div style="display: flex; gap: 1rem;">
  <figure style="flex: 1 1 0; min-width: 0; margin: 0; text-align: center;">
    <img src="/assets/img/2026-08-02-[Concurrency]-GCD와 Swift Concurrency 비교/pasted-image-20260805T062702-2.png" alt="GCD 스레드 수 측정" style="display: block; width: 100%; height: auto; margin: 0 !important;">
    <figcaption style="display: block; width: 100%; margin: 0.15rem 0 0 !important; text-align: center !important;">GCD</figcaption>
  </figure>
  <figure style="flex: 1 1 0; min-width: 0; margin: 0; text-align: center;">
    <img src="/assets/img/2026-08-02-[Concurrency]-GCD와 Swift Concurrency 비교/pasted-image-20260805T062924-2.png" alt="Swift Concurrency 스레드 수 측정" style="display: block; width: 100%; height: auto; margin: 0 !important;">
    <figcaption style="display: block; width: 100%; margin: 0.15rem 0 0 !important; text-align: center !important;">Swift Concurrency</figcaption>
  </figure>
</div>



&nbsp;

컨텍스트 스위칭을 확인하기 위해 왼쪽의 **Thread State Trace를 클릭**합니다. 화면 아래 Detail 영역의 보기 방식을 **Context Switches로 변경**했습니다. 그러면 선택한 시간 범위에서 발생한 컨텍스트 스위칭 횟수가 프로세스별로 표시됩니다. GCD에서는 5,282회, Swift Concurrency에서는 2,908의 컨텍스트 스위칭이 발생한 것을 확인할 수 있습니다.

Swift Concurrency에서도 2,908의 컨텍스트 스위칭이 발생한 이유가 뭔지 궁금했는데 이부분은 GPT에게 물어보았습니다. Swift Task는 Thread가 아니지만 실제 코드는 cooperative thread pool의 worker thread 위에서 실행되며, 이 Thread들은 운영체제 스케줄러에 의해 선점되거나 재배치될 수 있기 때문이라고 합니다.(상단에서 이미 협력적 쓰레드풀 이라고 정리한개념!!) 또한 테스트 코드의 Task.yield() 와 자식 Task t생성/완료, 메인 스레드 및 UI 관련 스레드 실행도 앱 프로세스 전체 컨텍스트 스위칭 값에 포함되기 때문이라고 합니다. 그래서 Swift Concurrency는 컨텍스트 스위칭을 제거하는 것이 아니라 제한된 worker thread를 재사용해 불필요한 스위칭을 줄이는 방식으로 이해하면 될 것 가습니다.

&nbsp;

## 전체 코드

```swift
import SwiftUI

struct ContentView: View {
    private let benchmark = Benchmark()

    var body: some View {
        VStack(spacing: 20) {
            Text("GCD vs Swift Concurrency")
                .font(.title2)
                .bold()

            Text("100만 개의 정수를 정렬하는 작업을 50개 실행합니다.")
                .foregroundStyle(.secondary)

            Button("GCD 실행") {
                benchmark.gcdConcurrency()
            }
            .buttonStyle(.borderedProminent)

            Button("Swift Concurrency 실행") {
                Task {
                    await benchmark.swiftConcurrency()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private nonisolated struct Benchmark: Sendable {
    private let numberOfConcurrency = 50
    private let range = 0..<1_000_000

    // MARK: - GCD
    func gcdConcurrency() {
        let backgroundWorkItem = DispatchWorkItem(qos: .background) {
            let array = range.map { number in
                1_000_000 - number
            }

            let _ = array.sorted(by: <)
        }

        let group = DispatchGroup()

        let queue = DispatchQueue(
            label: "GCD",
            qos: .background,
            attributes: .concurrent
        )

        for _ in 0..<numberOfConcurrency {
            queue.async(
                group: group,
                execute: backgroundWorkItem
            )
        }

        group.wait()
    }

    // MARK: - Swift Concurrency
    func swiftConcurrency() async {
        await withTaskGroup(of: Double.self) { group in
            for _ in 0..<numberOfConcurrency {
                group.addTask(priority: .background) {
                    await sortArray()
                    return 0
                }
            }
        }
    }

    private func sortArray() async {
        await Task.yield()

        let array = range.map { number in
            1_000_000 - number
        }

        await Task.yield()

        let _ = array.sorted(by: <)
    }
}

#Preview {
    ContentView()
}

```

## Reference

- [https://1000one.tistory.com/66](https://1000one.tistory.com/66)
- [https://developer.apple.com/documentation/DISPATCH](https://developer.apple.com/documentation/DISPATCH)
- [https://iosios.tistory.com/30](https://iosios.tistory.com/30)
- [https://dawning-record.tistory.com/129](https://dawning-record.tistory.com/129)
- [https://bbiguduk.gitbook.io/swift/language-guide-1/concurrency](https://bbiguduk.gitbook.io/swift/language-guide-1/concurrency)
- [https://josephcha.tistory.com/30](https://josephcha.tistory.com/30)
- [https://ios-development.tistory.com/1289](https://ios-development.tistory.com/1289)
<!-- - [https://engineering.linecorp.com/ko/blog/about-swift-concurrency](https://engineering.linecorp.com/ko/blog/about-swift-concurrency) -->

<!-- ## 스레드 개수를 파악해 보려고 시도.. 하지만 스레드 개수가 큰 차이가 없없습니다.

ios버전, 기기별 차이가 있을 것 같아서 추후에 다시 측정 해 보겠습니다.

!\[붙여넣은 이미지\](/assets/img/2026-08-02-\[Concurrency\]-GCD와 Swift Concurrency 비교/pasted-image-20260805T065044.png)

!\[붙여넣은 이미지\](/assets/img/2026-08-02-\[Concurrency\]-GCD와 Swift Concurrency 비교/pasted-image-20260805T065002-2.png)

&nbsp;

&nbsp; -->
&nbsp;
