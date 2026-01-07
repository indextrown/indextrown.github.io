---
title: "[Architecture] TCA 개념 정리"
tags: 
- Architecture
header: 
  teaser: 
typora-root-url: ../

---

<br/>

# TCA(The Composable Architecture)
TCA는 오픈소스 아키텍처 라이브러리다. Swift Composable Architecture, SCA라는 이름으로 부르는 경우도 있지만 공식문서상에는 TCA로 설명한다.
  
TCA는 SwiftUI에 적용하기 좋은 아키텍처다. 내부적으로 Combine이 활용되고 선언형 방식과 잘 맞는 아키텍처이기 때문이다. 물론 UIKit환경에서도 활용할 수 있다.
<br/><br/>

# TCA 특징
- Composable하다.(작은 요소 여러개가 합쳐져 하나의 큰 무언가를 이룬다)
- 데이터의 경로가 단방향이라 앱 흐름을 파악하기 용이하다.
- Side-Effect를 테스트할 수 있어 코드의 안전성을 높일 수 있다.
- 대규모 프로젝트에서 복잡한 앱의 상태 관리나 비즈니스 로직 처리, 테스트 코드 등을 작성하는데 있어 구조적으로 일관성을 유지하며 개발할 수 있도록 도와준다.
<br/><br/>

# TCA는 단방향 데이터 흐름을 기반으로 설계되었다
iOS 개발에서 가장 대중적인 MVVM구조를 보더라도 View와 ViewModel 사이가 양방향 데이터 흐름으로 이어지고 있다.    

양방향 데이터 흐름에서 데이터 흐름을 파악하기가 단방향에 비해 상대적으로 어렵고 양방향 관계에서는 강한 결합 문제가 발생할 수 있다는 근거도 일리는 있지만 꼭 단방향 흐름을 채택하는 아키테처를 사용해서 해결할 문제는 아니다.

이런 이유보다는 기존 명령형 UI인 UIKit에서 선언현 UI환경인 SwiftUI로 트렌드가 옮겨지는 과정에서 기존의 MVC, MVVM이 최선의 방식인가? 라는 질문에서 TCA의 선호 흐름을 봐야 할 필요가 있다는 주장이 있다.  

SwiftUI 데이터 바인딩은 viewModel을 두지 않더라도 View자체에서 프로퍼티 래퍼를 사용하는 방식으로 구현할 수 있다는 점, 하지만 비즈니스 로직까지 View에서 처리해야 하는 질문에는 답이 **No** 라는 점에서 해결책으로 등장한 흐름이 **단방향 데이터 흐름**이라는 점,  

여기서 데이터 바인딩이 아니라 비즈니스 로직을 View로부터 효율적으로 분리하는 과정에서 떠올리게 된 단방향 데이터 흐름 구조가 Flux였고 TCA는 이 단방향 데이터 흐름이라는 Flux 컨셉을 받아 발전시킨 아키텍처 라이브러리이다.

> - 선언형 프로그래밍인 SwiftUI에서 적합한 데이터 흐름 구조를 떠올리다가 등장한 것이 단방향 데이터 흐름 (Unidirectional Data Flow)이다.
> - 단방향 데이터 흐름을 제안한 대표 아키텍처가 Flux이고 이 컨셉을 발전시킨 것이 TCA (The Composable Architecure)이다.

<br/><br/>

# TCA 단방향 흐름 구조
- **State**: 애플리케이션의 상태를 나타내는 타입. 애플리케이션 상태란 UI를 그리기 위한 데이터나 비즈니스 로직이다.
- **Action**: 애플리케이션에서 발생하는 모든 이벤트를 정의한 열거형이다. 사용자의 버튼 탭, 네트워크 응답, 알림 등 모든 이벤트가 포함될 수 있다.
- **Reducer**: 입력된 Action에 따라 새로운 State 값을 업데이트하거나 API 요청과 같은 Effect를 반환하는 함수다.
- **Store**: State, Action, Reducer를 실제 관리하고 개발자가 정의한 애플리케이션 모든 기능이 동작하는 핵심 공간이다.
- **Environment**: 애플리케이션 외부로부터 데이터를 받아올 때 애플리케이션이 갖게 되는 의존성을 갖고 있는 타입이다.
<br/><br/>

# Reference
- [Document](https://github.com/pointfreeco/swift-composable-architecture)
- [Blog](https://mini-min-dev.tistory.com/320)