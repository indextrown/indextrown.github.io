---
title: "[AutoLayout] 1. Constraint"
tags:
- AutoLayout
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

- 오토레이아웃에서는 크기와 위치가 중요하다. 기본 개념은 크기를 지정하고 위치를 지정해준다.

<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout1/image-20250812152018585.png' | relative_url }}" alt="커스텀셀1" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout1/image-20250812152323796.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout1/image-20250812153048794.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout1/image-20250812153505739.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">크기를 지정하고<br/>위치를 지정</td>
    <td style="text-align:center;">상단 위치만 지정하고<br/>수평 정렬</td>
    <td style="text-align:center;">상단 위치만 지정하고<br/>좌우 앵커 지정</td>
    <td style="text-align:center;">상단 위치만 지정하고<br/>좌측 앵커와 가운데 정렬, width 제거</td>
  </tr>
  <tr>
    <td style="text-align:center; font-size:14px; color:#666;">
    크기와 위치를 모두 지정해<br/>레이아웃 고정.
    </td>
    <td style="text-align:center; font-size:14px; color:#666;">
    가운데 정렬로 기기별 가로 위치 일관성 확보.
    </td>
    <td style="text-align:center; font-size:14px; color:#666;">
      기기마다 크기가 달라서 문제가 발생할 수 있다.<br/>이때는 width를 없애주자.
    </td>
    <td style="text-align:center; font-size:14px; color:#666;">
      좌측 앵커만 수정해도 좌우 여백을 조절할 수 있다.
    </td>
  </tr>
</table>

