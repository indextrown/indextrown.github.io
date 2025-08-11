---
title: "[AutoLayout] 0. 오토레이아웃 개념"
tags:
- AutoLayout
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout0/image-20250808170826492.png' | relative_url }}" alt="이미지" width="70%">
ViewController에서 View는 화면을 그리는 부분이다.  
UI를 만들기 위한 그래픽 환경을 InterfaceBuilder라고 한다.



<img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout0/image-20250808174834409.png' | relative_url }}" alt="이미지" width="70%">
현재 SafeArea위에 View를 올렸다. View 자체는 크기가 없기 때문에 크기 지정을 해주자.  
오토 레이아웃에서는 **크기와 위치가** 중요하다. **크기**를 지정하고 **위치**를 지정해주는게 핵심이다.  
사진에서는 위치는 좌측과 상단만 anchor를 걸고 크기는 width, height를 고정값으로 지정하였다.  

먄약 좌우로 앵커를 걸면 width 고정값을 없애주자. 좌우 앵커일 때 width 고정값이 존재한다면 기기에 따라 에러가 발생할 수 있어서 width 고정값을 없애주자. 그럼 서로 늘어당기는 성질이 있어서 알아서 너비가 정해진다. 가능한 이유는 기종에 따라 크기를 알 수 있기 때문이다. 

