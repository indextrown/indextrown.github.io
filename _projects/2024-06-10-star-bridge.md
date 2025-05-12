---
title: "Star Bridge: 생일카페 알리미"
date: 2024-06-10
image: /assets/img/Projects/Starbridge/Starbridge.png
github: https://github.com/indextrown/senior-project
tags:
  - SwiftUI
  - Selenium
  - AWS EC2
  - Firebase
summary: "K-pop 팬들을 위한 생일카페 정보를 자동으로 수집하고, 알림으로 제공하는 스케줄 앱"
---

## 소개

- **서비스 설명**: K-pop 팬들을 위한 생일카페 정보를 자동으로 수집하고, 알림으로 제공하는 스케줄 앱
- **프로젝트 유형**: 팀 프로젝트 (졸업작품)
- **개발 기간**: 24.03 ~ 24.12
- **Github 링크**: [https://github.com/indextrown/senior-project](https://github.com/indextrown/senior-project)
- **기술 스택**: SwiftUI, Selenium, AWS EC2, Firebase

## 기여한 부분
1. SNS 기반 생일카페 스케줄 자동화 시스템 설계 및 구현

## 도입 배경
Swift를 배우기 시작하던 시기에 졸업 프로젝트에 합류하게 되어 앱 UI 구현보다는 시스템 개발 파트에 더 집중할 수 있었습니다.  
크롤링 → GPT로 데이터 정제 → API 연동으로 백엔드 중심의 구조를 직접 설계하며, 정보를 어떻게 모으고, 걸러내고, 사용자에게 전달할지를 하나의 흐름으로 구현해보는 데 초점을 맞췄습니다.

## 해결 방법
<img src="{{ '/assets/img/Projects/Starbridge/Starbridge1.png' | relative_url }}" alt="커스텀셀" width="70%"> 
<img src="{{ '/assets/img/Projects/Starbridge/Starbridge2.png' | relative_url }}" alt="커스텀셀" width="70%"> 
1. **크롤링 자동화**  
   - 로그인 및 차단 문제 해결을 위해, 수동 로그인 후 발급한 쿠키를 저장하고 이를 크롤링 시 재사용하여 안정성 확보.

2. **GPT 기반 정보 정제**  
   - 크롤링된 게시물에서 연예인 이름, 날짜, 장소를 GPT API로 추출.

3. **Google Maps API 장소 검증**  
   - GPT가 추출한 장소를 지도 API로 확인, 유효하지 않은 데이터는 자동 제외.

4. **실시간 앱 연동**  
   - 1~3단계 결과를 AWS EC2 서버에서 30분 주기로 자동화.
   - 정제된 데이터를 MySQL에 저장하고, SwiftUI 앱에서 실시간 조회 가능하게 구성.

## 성과

- 2024 한국멀티미디어학회 Best Paper 수상.
- SNS 크롤링 → GPT 정제 → 장소 검증 → 앱 연동까지 자동화 파이프라인 완성.
- 데이터 정확도 98.0%, 알림 98.5% 달성.
- Swift 학습 초기였지만, 앱과 서버를 연동하고 데이터 흐름을 설계하며 실질적인 서비스 구축 경험 쌓음. 