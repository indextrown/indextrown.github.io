---
title: "[CleanArchitecture]-객체 지향 설계의 5원칙 SOLID"
tags: 
- CleanArchitecture
header: 
  teaser: 
typora-root-url: ../
---
## SOLID 원칙이란
*SOLID* 원칙이란 객체지향 설계에서 지켜야 할 5개의 소프트웨어 개발 원칙을 의미한다.   
특정 프로그래밍 언어 혹은 프레임워크를 위해 만든 원치이 아니다.


## 객체 지향 설계의 5원칙 SOLID
- 단일 책임 원칙 (Single Responsibility Principle)
- 개방 폐쇄 원칙 (Open Closed Principle)
- 리스코프 치환 원칙 (Liskov Subsitution Principle)
- 인터페이스 분리 원칙 (Interface Segregation Principle)
- 의존 역전 원칙 (Dependency Inversion Principle)


*SOLID* 원칙은 oop 4가지 특징(추상화, 상속, 캡슐화, 다형성)과 더불어, 객체 지향 프로그래밍의 단골 면접 질문 중 하나이다. 또한 *Design Pattern*들이 SOLID 설계 원칙에 입각해서 만들어진 것이기 때문에 표준화 작업에서부터 아키텍처 설계에 이르기까지 다양하게 적용되는 이의 근간이 되는 *SOLID* 원칙에 대해 정확히 이해할 필요가 있다.  
  
    
좋은 소프트웨어란 변화에 대응을 잘 하는 것을 말한다. 예를 들어 클라이언트가 추가적인 요청을 한다면 구현을 할 때 애로사항없이 잘 대응하기 위해서 소프트웨어 설계 근간이 좋아야 한다.  

  
좋은 설계란 시스템에 새로운 요구사항이나 변경사항이 있을 때, 영향을 받는 범위가 적은 구조를 말한다.  
그래서 시스템에 예상치 못한 변경사항이 발생하더라도, 유연하게 대처하고 이후에 확장성있는 시스템 구조를 만들 수 있다.  
  
  
즉 *SOLID* 객체 지향 원칙을 적용하면 *코드를 확장*하고 *유지보수 관리*가 쉬워지며 불필요한 *복잡성을 제거*하여 리팩토링 소요 시간을 줄임으로써 프로젝트 *개발의 생산성*을 높일 수 있다.

