---
title: "[AutoLayout] 2. 다른 뷰에 뷰를 연결하는법"
tags:
- AutoLayout
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->


<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-08-12-[AutoLayout]-autolayout2/image-20250812160116357.png' | relative_url }}" alt="커스텀셀1" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-08-08-[AutoLayout]-autolayout1/image-20250812160511084.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">Leading</td>
    <td style="text-align:center;">Option + Leading</td>
  </tr>
  <tr>
    <td style="text-align:center; font-size:14px; color:#666;">
    green view에서 yellow view로 드래그 해서 Leading을 해주면<br/>yellow view leading과 동일한 효과를 얻을 수 있다.
    </td>
    <td style="text-align:center; font-size:14px; color:#666;">
    green view에서 yellow view로 드래그 할 때 option을 누르면서 Leading을 해주면<br/> 현재 green위치에서 yellow leading 사이의 여백을 더해줄 수 있다.
    </td>
  </tr>
</table>

<br/><br/><br/><br/>

<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-08-12-[AutoLayout]-autolayout2/image-20250812161107136.png' | relative_url }}" alt="커스텀셀1" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-08-12-[AutoLayout]-autolayout2/image-20250812161522955.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">Top Anchor 1번방식</td>
    <td style="text-align:center;">Top Anchor 2번방식</td>
  </tr>
  <tr>
    <td style="text-align:center; font-size:14px; color:#666;">
    green에서 Top Anchor를 설정하면 작살이 위로 날라가서 제일 가까운 top에 꽃힌다.
    </td>
    <td style="text-align:center; font-size:14px; color:#666;">
    만약 1번방식 대신 드래그로 하는방법은 green의 top을 yellow의 바텀으로 거는 설정이 없기 때문에
    yellow의 바텀으로 일단 걸고 우측 인스펙터에서 green Bottom -> green Top으로 옮기고 constant를 주면 된다.
    </td>
  </tr>
</table>

