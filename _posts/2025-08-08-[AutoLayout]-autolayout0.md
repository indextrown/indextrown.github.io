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
<br/><br/><br/><br/>


<img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout0/image-20250808174834409.png' | relative_url }}" alt="이미지" width="70%">
현재 SafeArea위에 View를 올렸다. View 자체는 크기가 없기 때문에 크기 지정을 해주자.  
오토 레이아웃에서는 **크기와 위치가** 중요하다. **크기**를 지정하고 **위치**를 지정해주는게 핵심이다.  
사진에서는 위치는 좌측과 상단만 anchor를 걸고 크기는 width, height를 고정값으로 지정하였다.  
<br/><br/><br/><br/>

## Tip
만약 **좌우로 앵커를 모두 설정**한다면, `width` 고정값은 제거하자.  
좌우 앵커와 width 고정값이 동시에 존재하면,  
기기 화면 크기에 따라 **레이아웃 충돌 에러**가 발생할 수 있다.

width 고정값을 제거하면 좌우 앵커가 서로 당기는 힘을 주어,  
기기 화면 크기에 맞춰 **자동으로 너비가 결정**된다.  
이는 기종별 화면 크기를 오토레이아웃이 인식하기 때문에 가능하다.

## 정리
- 오토레이아웃은 항상 크기와 위치가 필요하다.                                               
- 크기를 만들고 위치를 지정하자.                                                                  
- anchor를 한 방향에서 서로 걸게 되면 서로 당기는 성질이 있어서 별도로 크기를 지정하지 않아도 핸드폰이 자체적으로 크기를 결정할 수 있다.  

