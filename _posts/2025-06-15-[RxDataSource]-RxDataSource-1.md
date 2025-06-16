---
title: "[RxDataSource] 1. Delegate, DataSource"
tags: 
- ReactiveX
- RxDataSource
header: 
  teaser: 
typora-root-url: ../

---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->




## iOS 메모리 재활용

iOS와 같은 휴대용 기기에서 메모리를 많이 사용하는 앱이 있을 경우 시스템이 앱을 종료시킬 수 있다. 이는 메모리 사용량이 배터리 소모와 직결되기 때문이다. 따라서 iOS는 화면에 보일때만 메모리에 올리고 안보일때는 메모리에서 내리자 = 즉 재활용(dequeReusable)하자는 개념이 등장했다. 

<img src="{{ '/assets/img/2025-06-15-[RxDataSource]-RxDataSource-1/tableMemory-9978088.png' | relative_url }}" alt="이미지" width="100%">

재사용 큐(dequeueReusableCell) 개념
- UITableView는 메모리 효율을 위해 스크롤이 끝난 셀을 메모리에서 제거하지 않고 재사용한다.
- 재사용 가능한 셀들을 큐에 저장되며, 새로운 셀이 필요하면 다시 꺼내서 데이터를 덮어씌운다.

화면에 막 등장하려는 셀 (셀6)
- 아직 완전히 보이지 않더라도, 곧 보여질 예정이라 미리 메모리에 할당됨 (preload 개념)

아직 안 보이는 셀 (셀7)
- 이 셀은 아직 메모리에 올라가지 않음
- 스크롤로 화면에 나타나게 되면 그때 cellForRowAt이 호출되어 메모리에 할당됨
- let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) // 셀 재활용 핵심 코드
<br/>

| 시점        | 메서드 / 동작              | 설명                     |
| --------- | --------------------- | ---------------------- |
| 셀 사라질 때   | `prepareForReuse()`   | 셀의 상태 초기화              |
| 셀 필요할 때   | `dequeueReusableCell` | 재사용 큐에서 꺼냄 (없으면 새로 생성) |
| 셀 화면 진입 시 | `cellForRowAt`        | 셀에 실제 데이터를 채워 넣음       |

<br/><br/><br/>
---

<img src="{{ '/assets/img/2025-06-15-[RxDataSource]-RxDataSource-1/delegate-9976300.png' | relative_url }}" alt="이미지" width="100%">

## Delegate란?

delegate는 대리자라는 뜻으로 어떤 객체의 특정 행동을 대신 처리해주는 객체이다. 예를 들어 UITableView는 셀을 선택시 어떤 동작을 할지 알지 못한다. 대신 그 역할을 외부 객체(보통 viewController)에게 위임한다. 이런 위임 구조가 delegate 패턴이다.
즉 delegate는

- 사용자의 행동(이벤트)에 대한 처리를 맡는다
- ex) 셀 선택시 스크롤이 시작되었을 때 등

## DataSource란?

dataSource는 delegate와 비슷하게 동작하지만, 데이터 자체에 대한 정보를 제공한다.
예를 들어 UITableView나 UICollectionView는 수많은 데이터를 표시할 수 있는 UI 컴포넌트인데, 다음과 같은 질문을 던진다.

- 몇 개의 셀을 보여줘야 하지?
- 각 셀에는 어떤 내용을 넣어야 하지?
    이러한 질문에 답해주는 것이 바로 DataSource이다.

DataSource는 주로 다음 두 가지 메서드를 구현해야 한다.
numberOfRowsInSection – 셀의 개수
cellForRowAt – 각 셀에 들어갈 내용과 셀 객체 반환

## 예시
UITableView나 UICollectionView는 셀을 스크롤할 때마다 필요한 셀만 메모리에 올리고, 보이지 않으면 메모리에서 제거한 뒤 재활용한다.
이로 인해 성능을 크게 향상시킬 수 있으며, 이 재활용 과정에서 각 셀의 개수와 내용은 dataSource가, 셀 선택 등의 사용자 이벤트는 delegate가 처리한다.



