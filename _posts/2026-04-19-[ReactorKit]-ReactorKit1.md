---
title: "[ReactorKit] 개념"
tags:
  - ReactorKit
header:
  teaser:
typora-root-url: ../
---

## ReactorKit
- Flux와 반응형 프로그래밍을 결합한 개념이다.
- Rx의 개념인 Observable과 함께 사용하여 비동기적으로 데이터를 처리하고, UI와의 상호 작용을 쉽게 관리할 수 있는 구조를 만든다.
- MVVM 모델의 ViewModel 역할을 하며 비즈니스 로직을 처리하고 View와 상호 작용하는 방법을 제공한다.
- UI관련 코드와 비즈니스 로직을 분리하고, 코드의 재사용성이 높아진다.

## 핵심 장점
- 사용법이 간단하다.
- 특정 부분에만 적용할 수 있다.
- 테스트하기 쉽다. (Reactor와 View에 대해 의존성이 없기 때문)
- 유지보수하기 쉽다. (상태값 관리 용이)
- 코드가 간결해진다. (ViewController에 있는 로직을 분리해서)

![flow1](/assets/img/2026-04-19-[ReactorKit]-ReactorKit1/flow1.webp)
- 사용자의 Action은 Reactor로, Reactor에서 방출된 State는 Observable 스트림을 통해 전달된다.
- View는 Action만 방출할 수 있으며, Reactor는 State만 망출할 수 있다.
- 단방향적 흐름으로 View와 비즈니스 로직을 분리할 수 있으며 모듈 간 결합도가 낮게 개발할 수 있다.

![flow2](/assets/img/2026-04-19-[ReactorKit]-ReactorKit1/flow2.webp)
- View: Reactor로 받는 State를 통해 UI를 보여주는 역할과 사용자 인터렉션을 추상화하여 Reactor로 전달하는 역할을 수행한다.
- Reactor: View로부터 Action Stream을 전달 받아 내부에서 mutate()와 reduce() 과정을 거쳐서 State Stream으로 바꾸어 다시 View로 전달해주는 역할을 한다. 이를 적용하기 위해 Reactor 프로토콜을 적용해야 하며, 그 내부에는 사용자 인터렉션을 의미하는 Action과 State매개체인 Mutation, View가 가질 상태를 의미하는 State를 반드시 정의해야 한다. 또한 State의 초기값을 설정하기 위해 inititlState가 필요하다.
  - mutate(action:) -> Observable<Mutation>: Action 스트림을 Mutation 스트림으로 변환, 변환된 Mutation스트림을 reduce함수로 전달한다.
  - reduce(state:mutation:) -> State: 이전 State와 Mutation을 활용하여 새로운 State를 반환한다. 이 State를 View에서 구독하고 있었다면 State 변경됨에 따라 UI가 업데이트 된다.

## Reference
- https://ios-development.tistory.com/782
- https://oliveyoung.tech/2023-05-20/OliveYoung-iOS-ReactorKit/