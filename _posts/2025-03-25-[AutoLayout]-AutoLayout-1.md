---
title: "[AutoLayout]-오토레이아웃-1"
tags: 
- AutoLayout
header: 
  teaser: 
typora-root-url: ../
---

## 1. 오토레이아웃이란?

- 오토레이아웃이란 뷰 계층구조에 있는 모든 뷰의 **크기**와 **위치**를 제약조건(**constraints**)에 따라 **동적**으로 계산한다.
- 즉 자동으로 레이아웃을 그린다는 의미이다.

## 2. Constraints란?

- 제약조건(**Constraints**)란 뷰의 위치와 크기를 다른 객체로부터 상대적으로 나타내는 방법이다.
- 오토 레이아웃은 제약조건(**Constraints**)을 이용해서 크기와 위치를  정한다.
- view의 frame을 직접 지정해주는 것이 아니라 다른 객체(**SafeArea**)를 이용해 상대적으로 제약을 주는 것이다

## 3. 예시

### 기준 객체(Safe Area)로부터 왼쪽으로 30, 오른쪽으로 30, 위로 100만큼의 margin이 있고 heigh가 200이라는 제약조건이 있는 UIView를 그려보자.

- UIView의 width를 정해주지 않았지만 Leading / Trailing Constraints에 의해 서로 당기는 성질이 있어서 해상도 별로 width가 자동으로 저장된다.
- 만약 가로의 크기가 100인 해상도일 경우 UIView는 100 - 30 - 30 = 40만큼의 width를 가질 것이다.
- 오토 레이아웃은 크기와 위치가 제일 중요하다.
- 여기서 크기는 height: 200, width: SafeArea에서 좌우 margin(30)을 뺀 나머지 값(해상도별로 동적으로 변함)
- 여기서 위치는 Leading: 30, Trailing: 30, Top: 50

<img src="/assets/img/2025-03-25-[AutoLayout]-AutoLayout-1/image-20250325141039466.png" alt="image-20250325141039466" style="width:20%;">
