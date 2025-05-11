---
title: "[CleanArchitecture] 클린 아키텍처"
tags: 
- CleanArchitecture
header: 
  teaser: 
typora-root-url: ../
---



<!-- - 소프트웨어를 **유지보수**하기 쉽고, **테스트 가능**하며 **확장 가능한 구조**로 만드는 아키텍처 설계 원칙이다.
- 클린 아키텍처의 목적은 더 적은 인력으로 더 결함율이 낮고 더 빠르게 개발할 수 있는 코드를 작성하는 것이다. -->


## Clean Architecture란?   
로버트 C 마틴(Robert C. Martin), 별명으로는 엉클 밥(Uncle Bob)이 제안한 아키텍처로 소프트웨어를 다양한 계층(Layer)으로 분리해서 다음과 같은 목표를 추구한다
- 아키텍처는 특정 소프트웨어 라이브러리에 의존하지 않는다.
- **비즈니스 로직**은 UI, DB, 웹 또는 기타 외부 요소 없이 테스트 할 수 있다.
- **UI는 비즈니스 로직과 분리되어**, 시스템 로직을 변경하지 않고도 UI를 교체할 수 있다.
- 비즈니스 로직은 데이터베이스와 바인딩되어 있지 않다.
- 비즈니스 로직은 외부 세계(입출력 등)에 대해 아무것도 알지 못한다.

> 요약하자면, **소프트웨어를 역할별로 레이어를 나누고**   
> 각 레이어를 **완전히 분리하여 의존성을 낮추는 것**  이 클린아키텍처의 핵심이다.  
> 이를 통해 변화에 유연하고 테스트하기 쉬운 구조를 만들 수 있다.

## 왜 아키텍처가 필요한가?
개발자는 돈을 받고 코드를 만드는 사람이다.  
회서에서 가장 즁요한 것은  
1. **낮은 인건비로**
2. **결함이 적은 소프트웨어를 빠르게 개발**하는 것  

이다. 하지만 모든 개발자들이 **적은 인력으로 유지보수가 가능하면서 결함율이 낮은** 소프트웨어를 만들어낼 수 없다.  
오히려 **많은 인력을가지고도 유지보수도 못하고 버그는 많이 생기는** 소프트웨어를 만든다.

> 소프트웨어를 만드는 건 누구나 할 수 있지만,  
> **적은 인력으로 유지보수가 쉬운 '좋은 소프트웨어'를 만드는 건 어렵다.**   

그렇기 떄문에 **좋은 아키텍처** 의 개념이 중요하다.  
좋은 아키텍처는 **변화에 강하고, 유지보수가 쉽고, 테스트가 쉬운 구조**를 만드는 데 핵심이 된다.

## 모바일에서의 클린아키텍처
<div style="display: flex; justify-content: space-between;">
  <img src="/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean1.png" alt="clean1" style="width: 50%;">
  <img src="/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean3.png" alt="clean3" style="width: 50%;">
</div>

엉클밥의 클린아키텍처 컨셉을 보면 계층을 4개로 분리하였다.  
모바일 설계에서의 클린 아키텍처를 적용하기 위한 방법 중 하나로 3Layer 형태로 주로 사용한다.

### 1.Domain Layer
- Entity와 UseCase 계층을 묶어 Domain Layer 라고 부른다.
- Entity 
    - 앱의 핵심 데이터구조이다.
- UseCase 
    - 핵심 비즈니스 로직이다.
    - 유저 리스트 불러오기
    - 유저 상세 데이터 불러오기
    - 유저를 내부 저장소에 저장하기
- Repository 인터페이스
    - UseCase와 Data Layer(서버 API, 로컬 DB)를 연결해주는 중간 다리 역할이다.
    - Domain Layer에서 Repository는 인터페이스(Protocol)만 존재한다.
    - 실제 구현은 Data Layer에서 한다.

### 2. Data Layer
- 통신 및 데이터 관리 로직을 담당하는 계층이다.
- DB, API
    - 실제 데이터의 입출력을 담당한다.
- Repository 구현체
    - 데이터를 조정하는데 UseCase가 필요로 하는 데이터 저장/수정하는 기능을 한다.
    - 데이터소스(ex. DB)를 Protocol같은 인터페이스 형태로 참조하기 때문에 데이터 소스 객체를 갈아끼울 수 있는 형태로, 외부 API를 호출하거나 로컬 DB에 접근하거나 테스트를 위한 MockObject로 전환할 수 있다.
    
### 3. Presentation Layer
- UI표시, 애니메이션, 이벤트 핸들링 같은 UI 관련 모든 처리를 담당하는 계층이다.
- View(ViewConroller, View)
    - UI 화면 표시와 사용자의 터치 이벤트를 수신한다.
    - 화면에 그리는게 어떤 의미인지는 모르고, 어떤 색으로 그리는지와 같은 View적인 요소만 결정한다.
    - 단순히 Presentor(ViewModel)에서 받은 데이터나 상태에 따라 뷰의 표시를 전환한다.
- Presenter(ViewModel)
    - MVP/VIPER라면 Presenter역할, MVVM이라면 ViewModel역할과 동일하다. 
    - 사용자의 이벤트에 대한 판단과 대응을 진행한다. 뷰에 그려지는게 어떤 의미인지, 무엇을 그려야하는지 알고 있다.

## 의존성 규칙
클린 아키텍처에서 지켜야 할 규칙으로 의존성 규칙이 있다.  
> 안쪽 원을 향하는 방향이 규칙이므로
> Data Layer와 Presentation Layer가 Domain Layer를 바라보는 방향으로 의존성 방향이 지켜져야 한다.


<img src="/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean4.png" alt="clean4" style="width: 50%;">


## Reference
- https://sunny-maneg.tistory.com/entry/iOS-설계에서의-Clean-Architecture
- https://yoojin99.github.io/app/클린-아키텍처/
- https://mini-min-dev.tistory.com/284
- https://velog.io/@woohm402/clean-architecture-short-summary

