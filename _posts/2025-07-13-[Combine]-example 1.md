---
title: "[Combine] 예제 1"
tags: 
- Combine
header: 
  teaser: 
typora-root-url: ../
---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## Combine 예제

<img src="{{ '/assets/img/2025-06-18-[Combine]-/image-20250714015117890.png' | relative_url }}" alt="이미지" width="70%">
#### 1. scrollView 추가 및 상하좌우 제약 0 설정
<br/><br/>


<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250714020253349.png' | relative_url }}" alt="이미지" width="70%">
#### 2. UIView 추가 및 추가한 UIView를 Content Layout Guide에 드래그하여 상하좌우 제약 0 설정
- UIView를 Frame Layout Guide로 드래그해서 Equal Width 해주자
- size inspactor에서 width(가로막대) 더블 클릭 -> Proportional Widt~ 클릭 -> Multiplier를 1로 설정
- 이상태에서 빨간 오류 뜨는 이유는 View에 대한 내용물이 없어서 즉 크기가 없어서 그렇다
<br/><br/>



<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250714020847129.png' | relative_url }}" alt="이미지" width="70%">

#### 3. View에 Vertical Stack View 생성
- Stack View를 View로 드래그하여 상하좌우 제약 0으로 설정
- vertical stack에서 가로 크기를 꽉 채우기 위해 alighment는 fill 설정
- vertical stack에서 내용물을 동일하게 분배시키기 위해 fill equally 설정
- spacing 20 설정
- 이제 크기가 있는 애를 스택뷰에 넣으면 오토레이아웃이 잡힌다
- 추가적으로 size inspactor에서 simulated size를 Fixed -> Freeform으로 변경한다, 높이를 1000으로 설정한다.
<br/><br/>


#### 4. 결과
<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250714021514646.png' | relative_url }}" alt="이미지" width="70%">


