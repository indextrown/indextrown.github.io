---
title: "[CleanArchitecture]-클린 아키텍처"
tags: 
- CleanArchitecture
header: 
  teaser: 
typora-root-url: ../
---




<div style="display: flex; justify-content: space-between;">
  <img src="/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean1.png" alt="clean1" style="width: 50%;">
  <img src="/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean2.png" alt="clean2" style="width: 50%;">
</div>


## Clean Architecture란? 
- 소프트웨어를 **유지보수**하기 쉽고, **테스트 가능**하며 **확장 가능한 구조**로 만드는 아키텍처 설계 원칙이다.



## 핵심 목표
- 비즈니스 로직과 UI, DB, 네트워크 등을 명확히 분리한다.
- 의존은 **항상 바깥쪽(저수준) 계층에서 안쪽(고수준)계층을 향해** 흐른다. 즉 안쪽 계층은 바깥 계층에 대해 전혀 몰라도 동작할 수 있어야 한다.
- 모바일 기준으로 **Domain**, **Data**, **Presentation** Layer로 나눌 수 있다.
- ViewModel → UseCase → Repository (Protocol) → RepositoryImpl (API/DB)

    

## 계층 구조

| 계층                   | 설명                                                         |
| ---------------------- | ------------------------------------------------------------ |
| **Domain Layer**       | 앱의 핵심 비즈니스 로직이 위치. `Entity`, `UseCase`, `Protocol`, `Repositpry인터페이스` 등이 존재하며, 어떤 프레임워크나 외부에도 의존하지 않음 |
| **Data Layer**         | API, DB 등 실제 데이터 소스와 통신하는 계층. `Repository`의 구체 구현체가 위치 |
| **Presentation Layer** | 화면(View)과 사용자와의 상호작용을 처리. `ViewModel`, `UI`, 입력 처리 등이 포함됨 |



## 의존성이란

```swift
class ViewModel {
    let useCase = UseCase() // ViewModel은 UseCase에 의존
}
```

- 의존성(Dependency) 이란, 어떤 객체가 다른 객체를 사용하거나 필요로 하는 관계를 의미한다.
- ViewModel이 Usecase를 직접 생성하고 사용하고 있기 때문에 UseCase에 의존하고 있다.
- 이러한 관계가 많아질수록 한 객체가 변경되면 다른 객체가 변경되어야 할 가능성이 높아진다.
    - 즉 유지보수가 어려워진다.

## 의존성 역전 원칙(Dependency Inversion Principle)

- 클린 아키텍처의 원칙 중 하나로 **"고수준 모듈이 저수준 모듈에 의존해서는 안된다. 대신 둘 다 추상화(인터페이스)에 의존해야 한다"**



## 용어 정리

| 용어        | 설명                   | 예시                 |
| ----------- | ---------------------- | -------------------- |
| 고수준 모듈 | 핵심 비즈니스 로직     | `UseCase`            |
| 저수준 모듈 | 세부 구현 (DB, API 등) | `Repository`         |
| 추상화      | 중간 다리 역할         | `RepositoryProtocol` |



## DIP를 위반한 구조

```swift
class UseCase {
    let repository = Repository() // 구체적인 구현에 직접 의존
}
```

- 이 구조에서는 Repository가 변경되면 UseCase도 변경될 가능성이 크다.
- 테스트시 Mock 객첼 대체하기 어렵다.

## DIP를 지킨 구조

```swift
protocol RepositoryProtocol {
    func fetchUsers() -> [User]
}

class UseCase {
    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
}
```

- 이제 UseCase는 Repository 구체 구현체를 몰라도 된다.
- 오직 `RepositoryProtocol`이라는 **추상화된 인터페이스**에만 의존한다.



## 의존성 주입(DI: Dependency Injection)

```swift
let repository = MockUserRepository()
let useCase = FetchUsersUseCase(repository: repository) // 의존성 주입
let viewModel = ViewModel(useCase: useCase)

```

- 필요한 객체(의존성)을 외부에서 주입(Inject) 해주는 방식을 말한다.
- 의존성을 직접 생성하지 않고, 외부에서 받아서 사용하는 것이 핵심이다.



##  의존성 주입의 장점

| 장점          | 설명                               |
| ------------- | ---------------------------------- |
| 유연성        | 다양한 구현체를 자유롭게 교체 가능 |
| 테스트 용이성 | 테스트 시 `Mock` 객체를 쉽게 주입  |
| 결합도 감소   | 클래스 간 강한 연결을 피함         |

