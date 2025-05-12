---
title: "반창고: 건강 관리 앱"
date: 2024-11-01
image: /assets/img/Projects/Banchango/banchango1.png
github: https://github.com/indextrown/Ban-Chang-Go
tags:
  - SwiftUI
  - MapKit
  - CoreLocation
  - CoreMotion
  - Firebase
summary: "주변 약국 위치를 지도에서 확인하고, 걸음 수와 칼로리를 기록·조회할 수 있는 건강 관리 앱"
---

## 소개

- **서비스 설명**: 주변 약국 위치를 지도에서 확인하고, 걸음 수와 칼로리를 기록·조회할 수 있는 건강 관리 앱
- **프로젝트 유형**: 개인 프로젝트
- **개발 기간**: 24.11 ~ 24.12
- **Github 링크**: [https://github.com/indextrown/Ban-Chang-Go](https://github.com/indextrown/Ban-Chang-Go)
- **기술 스택**: SwiftUI, MapKit, CoreLocation, CoreMotion, Firebase

## 기여한 부분
1. 약국 운영 여부 포함 리스트 구성 (async / await 기반 연쇄 API 흐름 구조)

## 도입 배경
- 위치 기반 약국 API는 약국명과 위치만 제공하고 실제 운영 중인지 알 수 없었습니다.
- 반면 운영 여부 API는 약국 이름만 검색이 가능해 단독으로는 사용할 수 없었습니다.
- 사용자에게 실시간으로 문을 연 약국만 보여주기 위해 두 API의 흐름을 연결하는 구조가 필요했습니다.

## 해결 방법

- 위치 API로 받은 약국 리스트를 기준으로, 운영 여부 API를 순차 호출하는 구조 설계.
- 지도 이동 시 과도한 호출은 DispatchWorkItem과 Debounce로 조정.
- 이미 조회한 약국은 Set에 저장해 중복 호출 방지.

## 성과

- 운영 중인 약국은 빨간 핀, 종료 약국은 회색 핀으로 표시해 직관성 향상.
- 지도 이동 시 API 중복 호출을 차단해, 핀 렌더링 속도를 평균 1.2초 → 0.4초로 단축. 