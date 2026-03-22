---
title: "[SwiftUI] Diffing, 끝까지 파고들었습니다."
tags:
  - RxSwift
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->
  
<!-- <img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%" align="left"> -->

> "왜 특정 셀 하나 바꿨는데 전체가 다시 그려질까?"
PopPang 서비스에서 특정 화면에서 메모리가 상승하는 문제가 있었습니다.
처음에는 단순히 데이터 양 문제라고 생각했습니다. 하지만 실제 원인은 다른 곳에 있었습니다.
이 글에서는 문제를 어떻게 정의했고, 어떤 기준으로 해결했는지를 공유합니다.

<img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%">

## 문제
- 리스트의 특정 셀 상태만 변경
- 그런데 전체 리스트의 'Body' 다시 호출됨
- 스크롤 시 버벅임 + 메모리 증가 발생
👉 “SwiftUI가 생각보다 많이 다시 그린다”

---

## 의문
- SwiftUI는 왜 이렇게 많이 다시 그릴까?
- Diffing은 정확히 어떻게 동작할까?
- 내가 뭘 잘못 쓰고 있는 걸까?
👉 여기서부터 **Diffing을 끝까지 파보기 시작했습니다**

---

## ⚙️ SwiftUI Diffing의 핵심
SwiftUI는 상태가 바뀌면 이렇게 동작합니다.
```swift
// invalidation: 재계산 트리거
[1단계: 업데이트 트리거]
1. 상태 변경 감지 (@State, @ObservedObject 등)
2. 해당 View가 invalidation됨 (body 재계산 필요 표시)

[2단계: 렌더링 & Diffing]
3. 업데이트 사이클에서 body 실행 → 새로운 View 트리 생성
4. 이전 View 트리와 diffing 수행 (하위 View까지 재귀적으로 비교)
5. 변경된 부분만 실제 UI에 반영
```



<!-- ## 고민했던 문제
SwiftUI를 사용하면서 이런 경험을 한번 쯤 하게 됩니다.  
1. List 스크롤 시 왜 버벅거리지?
2. 특정 셀의 상태만 변경되도 왜 전체 화면이 다시 그려지지?
3. ForEach에서 id: \.self를 쓰면 안된다는데 정확히 이유가 뭐지?
4. 에어비엔비는 15% 렌더링 성능 개선을 어떻개 했을까?

## SwiftUI가 화면을 그리는 기본 메커니즘
> SwiftUI는 선언형 UI 프레임워크로 상태가 변경될 때마다 새로운 뷰 트리를 생성하고 이전 뷰 트리와 두 단계로 diffing하여 필요한 부분만 실제 UI에 반영합니다.
```swift
// 상태
``` -->