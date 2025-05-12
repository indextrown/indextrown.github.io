---
title: "코드라운지: 개발자 Q&A 학습 서비스"
date: 2024-11-10
image: /assets/img/Projects/CodeLounge/CodeLounge.png
github: https://github.com/team-GitDeulida/CodeLounge-iOS
# image_width: 300%
tags:
  - SwiftUI
  - Combine
  - fastlane
  - Firebase
summary: "CS, iOS 면접 질문과 답변을 마크다운 형식으로 정리하여 제공하는 학습용 서비스"
---

## 소개

- **서비스 설명**: CS, iOS 면접 질문과 답변을 마크다운 형식으로 정리하여 제공하는 학습용 서비스
- **프로젝트 유형**: 개인 프로젝트
- **개발 기간**: 24.11 ~ 25.01
- **Github 링크**: [https://github.com/team-GitDeulida/CodeLounge-iOS](https://github.com/team-GitDeulida/CodeLounge-iOS)
- **기술 스택**: SwiftUI, Combine, fastlane, Firebase

## 기여한 부분
1. SwiftUI 기반 마크다운 렌더링 직접 구현

## 도입 배경
- 코드라운지는 CS·iOS 면접 질문과 답변을 제공하는 학습 앱입니다.
- SwiftUI 기본 Text 컴포넌트는 표현과 커스터마이징에 한계가 있어, 고급 마크다운 처리가 가능한 파서를 직접 구현하게 되었습니다.

## 해결 방법
<img src="{{ '/assets/img/Projects/CodeLounge/CodeLounge1.png' | relative_url }}" alt="커스텀셀" width="70%"> 
<img src="{{ '/assets/img/Projects/CodeLounge/CodeLounge2.png' | relative_url }}" alt="커스텀셀" width="70%"> 
- 대학에서 배운 프로그래밍언어 과목의 EBNF 문법과 Top-Down, 재귀 하강 파싱 개념을 앱에 적용.
- 전체 문서를 EBNF 기반으로 문법적으로 정의한 후, Heading, ListItem, Paragraph 등 Top Down 방식의 블록 단위 파싱을 구현.
- 줄 내에 있는 Bold, Underline 등은 재귀 하강 파싱으로 중첩 구조까지 분석.
- 파싱된 결과는 SwiftUI에서 Text, HStack, VStack 등으로 동적으로 렌더링.

## 성과

- 텍스트 강조, 코드블럭, 밑줄 표현이 가능한 마크다운 메서드 구현.
- 긴 텍스트를 가독성 높게 표현할 수 있게 됨.
- 다양한 기기에서도 일관된 텍스트 크기와 여백을 자동으로 조정하는 라이브러리 구현.
- 기능을 범용 라이브러리 형태로 분리하여 프로젝트 간 재사용이 가능하도록 모듈화. 