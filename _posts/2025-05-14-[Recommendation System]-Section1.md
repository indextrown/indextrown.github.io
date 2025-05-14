---
title: "[Recommendation System] 1. 추천시스템 소개"
tags: 
- Recommendation System
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 추천 시스템이란
추천 시스템이란 사용자의 과거 행동 데이터를 바탕으로 사용자에게 필요한 정보나 제품을 제시하는 시스템이다.

# 추천 시스템의 여러 기술
- 협업 필터링(Collaborative Filtering)
- 내용 기반 필터링(Content-Based Filtering)
- 지식 기반 필터링(Knowledge-Based Filtering)
- 딥러닝(Deep Learning)
- 하이브리드 필터링(협업필터링 & 딥러닝)

# 1.1 협업 필터링 (Collaborative Filtering)
구매 및 소비한 제품에 대한 소비자의 평가 패턴이 비슷한 집단 속에서 서로 접하지 않은 제품을 추천하는 기술이다.
한계 - 소비자의 평가정보를 구하기 어렵다 ex)신규/휴먼 고객
해결책 - 구매가 아니라 클릭, 체류시간으로 간접적인 데이터로 협업 필터링 가능

# 1.2 내용 기반 필터링(Content-Based Filtering)
제품의 내용을 분석해서 추천하는 기술이다.

# 1.4 지식 기반 필터링(Knowledge-Based Filtering)
특정 분야 전문가의 도움을 받아서 그 분야에 대한 전체적인 지식 구조를 만들어서 활용하는 방법이다.

# 1.5 딥러닝(Deep Learning)
AI 알고리즘 중 현재 가장 많이 사용되는 딥러닝 방법이다.

# 1.6 하이브리드 필터링(협업필터링 & 딥러닝)
두가지 이상의 알고리즘 혼합을 통한 하이브리드 형태이다.