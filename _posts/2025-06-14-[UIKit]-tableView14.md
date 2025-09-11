---
title: "[TableView] 14. DiffableDataSource"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# DiffableDataSource
Diffable
- 다른 이라는 뜻이다. 
- 아이템들간의 서로 다름을 알게 되는 것이다.
- 애니메이션 처리가 자연스럽게 되는 데이터소스이다. 

datasource 
- cellProvider - 셀 만들기 가능하다.

snapshot(사진 찍어둠)
- 테이블뷰 로드방식이 기존 테이블뷰와 다르다.
- dataSource.apply(스냅샷) -> 이런 데이터를 보여줄거라고 스냅샷이라는 사진을 찍어두고 찍어둔 사진을 반영한다.

 