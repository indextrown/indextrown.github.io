---
title: "[AutoLayout] 5. 스택뷰"
tags:
- AutoLayout
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

## 스택뷰

<img src="{{ '/assets/img/2025-08-14-[AutoLayout]-autolayout5/image-20250814162747463.png' | relative_url }}" alt="이미지" width="70%">

label클릭 후 우측하단 박스모양 클릭 후 view눌러주면 편하게 uiview를 감쌀 수 있다.  
하지만 오토레이아웃은 안잡힌 상태라서 지정해주자.
- 나는 수평정렬, 수직정렬을해서 가운데로 지정해주었다.
- 그리고 label에서 view로 leading, top을 걸어주었다.
- 이러면 크기는 지정된다. 마지막으로 view를 위치만 잡아주면 된다.

<img src="{{ '/assets/img/2025-08-14-[AutoLayout]-autolayout5/image-20250814165609486.png' | relative_url }}" alt="이미지" width="100%">
하나의 컨테이너를 만들었다면
- 2개 더 복붙하여 3개를 드래그하여 우측하단 박스 눌러서 stackView눌러주면 스택뷰 안에 들어가게 되고 기존 외부 오토레이아웃은 사라진다.
- 스택뷰를 leading, top으로 앵커를 걸어준다. 그리고 horizontally 정렬을 해준다(좌우정렬 )
- 각각 노란 컨테이너의 width(고정값)을 없애주고 스택뷰에서 option + command + 5에서 distribution을 fill equally로 하면 너비가 균등하게 분배된다.
- 이러면 leading을 조절해도 내부 컨테이너들의 너비는 알아서 균등하게 조절된다.

장점
- 작은 사이즈의 기기에서도 균일하게 각 컨테이너들이 보일 수 있다.
- 하지만 작은 사이즈의 기기에서는 컨테이너들이 일그러질 수 있다.
- 보통 대표 기종 기기를 정해둔다.