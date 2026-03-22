---
title: "[SwiftUI] Lifecycle"
tags:
  - RxSwift
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%" align="left"> -->

## SwiftUI View Life Cycle
- Lifecycle는 뷰의 생성부터 소멸까지 생기는 일련의 이벤트이다.
- SwiftUI의 각 뷰에는 관찰하고 조작할 수 있는 세 가지 주요 단계가 있다.
- 이 세 가지 단계는 *Appearing*, *Updating*, *Disapperaing*이다.

## Appearing
- 뷰 그래프에 뷰를 삽입하는 것을 의미한다.
- 뷰는 초기화되고 state를 구독하여 처음으로 렌더링된다.

![img](/assets/img/2026-03-21-[SwiftUI] lifecycle/img.png)


## Reference
- https://www.vadimbulavin.com/swiftui-view-lifecycle/
- https://janechoi.tistory.com/84
- https://doh-an.tistory.com/43