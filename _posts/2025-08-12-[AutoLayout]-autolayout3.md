---
title: "[AutoLayout] 3. 컨테이너"
tags:
- AutoLayout
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

## View vs label
- 일반적인 view는 크기와 위치를 지정해줘야 한다.
- label은 자체적으로 크기를 가지기 때문에 크기는 정해주지 않아고 위치만 정해준다.
- 크기를 대신해줄 수 있는 것은 **constraints**이다.


<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-08-12-[AutoLayout]-autolayout3/image-20250812164741262.png' | relative_url }}" alt="커스텀셀1" width="90%"></td>
    <td><img src="{{ '/assets/img/2025-08-12-[AutoLayout]-autolayout3/image-20250812165643354.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">Yellow의 위치와 크기 고정</td>
    <td style="text-align:center;">Yellow의 위치만 고정(크기x)</td>
  </tr>
  <tr>
    <td style="text-align:center; font-size:14px; color:#666;">
    컨테이너 뷰(Yellow)의 크기와 위치를 모두 고정하는 방식<br/>
    width와 height를 직접 지정하여 레이아웃을 확정한다.
    </td>
    <td style="text-align:center; font-size:14px; color:#666;">
      크기는 직접 지정하지 않고 내부 Yellow 컨테이너의 subview들의 constraints로 대체하는 방식.      
      예를 들어, <code>yellow</code>의 subview(top)와 label의 top, bottom을 서로 연결하면  
      label의 높이가 곧 yellow의 높이가 된다.<br/> 
      width는 subview 또는 label에서 yellow로 <b>leading</b> 제약을 주어 결정할 수 있다.
    </td>
  </tr>
</table>

## 정리
크기를 대신해서 할 수 있는게 constraints이다.   
yellow container의 크기를 해당 컨테이너 내부의 constraints로 대체할 수 있다.   
가능한 이유는 yellow의 subview의 top이 존재하고 label의 top과 subView의 바텀이 연결되어 있다. 추가적으로 label의 bottom을 yellow의 bottom으로 연결해주면 높이는 대체가 된다.
width는 label이나 subView에서 yellow로 왼쪽으로 작살을 던져주면 해결된다.   
  
(subView의 top이 yellow의 top에 연결되어 있고 subView가 가운데 정렬이기 때문에 subView에서 왼쪽으로 anchor를 놓든 subView의 leading을 따르는 label의 왼쪽으로 anchor를 놓든 width를 결정할 수 있다.)
