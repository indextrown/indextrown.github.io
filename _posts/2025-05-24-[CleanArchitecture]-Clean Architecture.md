---
title: "[CleanArchitecture] SOLID, MVVM, CleanArchitecture"
tags: 
- CleanArchitecture
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <table>
  <tr>
    <td><img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean1.png' | relative_url }}" alt="커스텀셀1" width="50%"></td>
    <td><img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean3.png' | relative_url }}" alt="커스텀셀" width="50%"></td>
  </tr>
</table>

<div style="display: flex; justify-content: space-between;">
  <img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean1.png' | relative_url }}" alt="커스텀셀1" width="50%">
  <img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean3.png' | relative_url }}" alt="커스텀셀" width="50%">
</div> -->




<!-- <div style="display: flex; justify-content: space-between;">
  <img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean1.png' | relative_url }}" alt="커스텀셀1" width="50%">
  <img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean3.png' | relative_url }}" alt="커스텀셀" width="50%">
</div> -->

# SOLOD, MVVM, CleanArchitecture

클린 아키텍처를 알기 위해서는 MVVM을 알아야 하고 MVVM을 알기 위해서는 SOLID 원칙을 알아야 한다.  SOLID 원칙 -> MVVM -> Interface -> Clean Architecture 순서로 정리하였다.


## 원칙이란?

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/img.jpg' | relative_url }}" alt="이미지" width="70%">

- 원칙을 지키면 시간이 흐른 뒤에는 큰 영향을 가져온다.  
- 원칙을 지키지 않는다면 어디서부터 어떻게 고쳐야 할 지 어렵고, 한 부분을 해결하면 다른 부분에서 문제가 발생할 수도 있다. 
- SOLID 프로그램의 원칙을 지키면 프로젝트 규모가 커질수록 큰 영향을 가져온다.
- SOLID 원칙을 지키면 얻을 수 있는 효과가 유지보수성이다.
- 유지보수가 쉬운 코드 = 어떤 상황에서도 잘 동작하고 변경에 용이

---

## SOLID 원칙

- SOLID원칙은 5가지 원칙을 의미한다.
  

### 1. 단일 책임 원칙

- 클래스는 하나의 책임만을 가져야 한다. 
- (책임 = 변경이 일어날 때 영향을 받는다라고 가정)

ex) ViewConntroller의 책임
- UI 그리기   (<- 책임)
- UI 로직 구현
- API 호출
- 내부 데이터 저장, 불러오기

=> 이 4개중에 하나의 책임만 가져야 한다. 여기서는 UI 그리기가 책임이 된다.
<br/><br/>

### 2. 개팡 폐쇄 원칙

- 클래스는 기능의 확장에 있어서 열려 있어야 하고 수정에는 닫혀 있어야 한다. 

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524154310671.png' | relative_url }}" alt="이미지" width="50%">
ViewModel에서 User 데이터에 대한 타입이 변경되면 ViewModel에 의존하는 ViewController가 영향을 받는다.  하지만 ViewController에서 UI에 대한 코드가 변경되면 안된다.

<details> 
    <summary>예제코드</summary>
	<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524202259228.png' | relative_url }}" alt="이미지" width="100%">
</details>



<br/><br/>

### 3. 인터페이스 분리 원칙

- 사용하지 않는 인터페이스는 쓰지 않아야 한다.

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524160614297.png' | relative_url }}" alt="이미지" width="50%">
사진과 같이 ViewController가 property1과 func3만 사용한다면  ViewController입장에서 나머지 property2, func1, func2는 필요 없다. 이럴때는 인터페이스를 분리해야 한다.
<br/><br/>

### 4. 의존성 역전 원칙

- 고수준 모듈은 저수준 모듈에 의존해서는 안된다. 둘다 추상화에 의존해야 한다.

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524161541708.png' | relative_url }}" alt="이미지" width="50%">
저수준은 UI와 같이 잘 바뀌는 코드를 의미하고 고수준은 앱에서 핵심 기능인 잘 안바뀌는 기능을 의미한다.(쇼핑앱에서는 결제 기능과 유사)
즉 쉽게 바뀌는 코드가 쉽게 바뀌지 않는 코드를 의존해야 한다.
참고로 추상화(인터페이스)에 의존해야한다. 

<details> 
    <summary>예제코드</summary>
	<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524202525835.png' | relative_url }}" alt="이미지" width="100%">
</details>

<br/><br/>

### 5. 리스코프 치환원칙

- 자식 클래스는 언제나 자신의 부모 클래스로 교체할 수 있어야 한다. 즉 부모 타입을 사용하는 곳에 자식 타입을 넣어도 정상적으로 작동해야 한다.

<details> 
    <summary>리스코프 치환 위반 예시</summary>
	<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524202625296.png' | relative_url }}" alt="이미지" width="100%">
</details>

<details> 
    <summary>리스코프 치환 지키는 예시 </summary>
	<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524202753353.png' | relative_url }}" alt="이미지" width="100%">
</details>





---

## MVVM

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524171856966.png' | relative_url }}" alt="이미지" width="70%">

SOLID 원칙을 지키기 위해 MVVM 패턴을 사용한다. MVVM패턴을 지키면 자연스럽게 SOLID 원칙을 지킬 수 있다. MVVM은 Model, View, ViewModel로 3등분으로 구성된다. 

### 그림 상세내용(참고)

- View는 UI를 표현하고 버튼 클릭이나 텍스트 입력과 같은 **이벤트를 ViewModel으로 전달**한다. 
- ViewModel은 View(UI)와 관련한 로직을 모두 처리하거나 상태를 보유한다. 또한 View에서 전달된 이벤트에 따라 바뀐 상태나 바뀐 UI 관련 로직을 처리하고 필요시 ViewController에게 바로 상태를 전달하고, 만약 더 핵심적인 비즈니스 로직(API 호츌)이 필요하면 Model에 전달하여 Model에서 핵심 비즈니스 로직을 처리하고 데이터를 다시 ViewModel로 전달해주고 ViewModel에서 UI적인 로직을 처리하여 ViewController에게 상태나 데이터를 전달한다.

### MVVM 구성

| 구성 요소     | 역할                                                         |
| ------------- | ------------------------------------------------------------ |
| **Model**     | 데이터와 비즈니스 로직 (API 통신, 데이터 가공 등)            |
| **ViewModel** | View에 필요한 상태와 로직을 관리 (UI 상태 결정, 이벤트 처리) |
| **View (UI)** | 사용자 입력, 화면 표시 (이벤트는 ViewModel로 전달)           |



### 🔁 의존성 방향

- **View → ViewModel**: View는 ViewModel에 의존 (버튼 클릭 → 메서드 호출 등)
- **ViewModel → Model**: ViewModel은 데이터가 필요할 때 Model에 요청
- **Model은 아무것도 모름** (하위 계층은 상위 계층을 몰라야 함 = DIP 적용)
- 의존성의 방향은 잘 변경되는 쪽이 잘 변경되지 않는 쪽을 바라본다, 즉 각 구성요소가 단방향적인 의존성을 지키고 있다.

<details> 
    <summary>SOLID 원칙 적용 전 MVVM 코드 (DIP 위반)</summary>
	<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524203055395.png' | relative_url }}" alt="이미지" width="100%">
</details>

<details> 
    <summary>SOLID 원칙 적용 후 MVVM 코드 (DIP, OCP 등 만족)</summary>
	<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524203210106.png' | relative_url }}" alt="이미지" width="100%">
</details>

---

## Interface

클린아키텍처를 이해하기위해 인터페이스 개념을 다시 한번 알고 가자.

### 인터페이스란?

- 우리가 흔이 말하는 앱의 유저 인터페이스(UI)는 사용자가 직접 마주하는 화면을 의미한다.
- 어떻게 구성되고, 어떻게 동작하며, 어떤 방식으로 정의한다.

### ❄️ 냉장고로 예시를 들어본다면

- 유저 인터페이스(UI): 손잡이, 버튼, 디스플레이
- 내부 로직: 온도 조절, 냉각 등 실제 동작
- **중요한 포인트**:  
    사용자는 내부 로직을 몰라도, 버튼 하나로 냉장고를 조작할 수 있다.  
    → 즉, **"인터페이스만 알면 사용 가능"**한 구조다.

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524175041634.png' | relative_url }}" alt="이미지" width="70%">

- 냉장고의 UI는 `ViewController`, 내부 로직은 `ViewModel`로 비유할 수 있다.  
- `ViewController`는 **"냉장고 온도를 내려주세요"**라고 요청만 한다.  
- 실제 로직(냉각, 온도 계산 등)은 `ViewModel`이 처리한다.

## 인터페이스를 정리하자면

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524175910967.png' | relative_url }}" alt="이미지" width="70%">

- `ViewController`가 `ViewModel`을 **직접 구현이 아닌 인터페이스(Protocol)**에 의존하면,
- 내부 로직이 바뀌더라도 ViewController는 수정 없이 그대로 동작할 수 있다.

이렇게 **구현을 감추고 필요한 기능만 정의한 것**을 `**추상화**`라고 한다.
인터페이스를 사용하는이유 = 의존성을 최소화 하기 위해 = 변경을 대응하기 위함.



---

## Clean Architecture

<img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean1.png' | relative_url }}" alt="커스텀셀1" width="50%">
엉글  밥Robert C. Martin)이 제시한 **추상적인 개념**으로서 **관심사를 분리시키고 의존도를 낮추는 것에 목적을 둔 아키텍처**이다. 모바일 뿐만 아니라 웹이나 서버 등 여러 곳에서 많이 사용하는 아키텍처이다. 모바일 기준으로는 조금 단순화한 아래 사진을 참고하면 된다.

<img src="{{ '/assets/img/2025-03-25-[CleanArchitecture]-CleanArchitecture/clean3.png' | relative_url }}" alt="커스텀셀" width="50%">
모바일 기준으로는 크게 3개의 계층(Layer)로 분류한다. Domain Layer, Data Layer, Presentation Layer로 분류한다. 

---

### 1. Domain Layer

Domain Layer는 프로젝트의 **가장 핵심적인 영역**이며,  
비즈니스의 규칙과 요구사항을 직접 담고 있는 계층이다.

### 구성 요소

- Entity - 모델 정의
- UseCase - 핵심적인 비즈니스 로직을 담은 역할
    - 유저 리스트 불러오기
    - 유저 상세 데이터 불러오기
    - 유저를 내부 저장소에 저장하기
- Repository Protocol(인터페이스) - UseCase와 Data Layer(서버 API, 로컬 DB)를 연결해주는 중간 다리 역할
    - `UseCase`와 `Data Layer` 사이를 연결하는 **추상화 계층**
    - 데이터의 출처가 무엇이든 (API, DB 등) `UseCase`는 몰라도 된다

---

### 2. Data Layer

 데이터를 가져오는 역할이다.

- DB
- API
- Repository 구현체
    - API를 사용할지 DB를 사용할지를 Repository를 통해서 가져온다. 
    - Repository를 통해 가져오므로 API나 DB를 직접 의존할 필요가 없다.

### 왜 Repository를 사용하는가?

- `UseCase`는 **데이터가 어디서 오는지 알 필요 없다.**
    - API든, CoreData든, Realm이든 전혀 신경 쓰지 않는다.
- `Repository`가 데이터의 출처를 감싸서 대신 처리해준다.
    - 덕분에 `UseCase`는 **오직 기능 수행에만 집중 가능**
- `Repository`는 인터페이스만 존재하며, 실제 구현은 **Data Layer**에서 처리한다.

---

### 3. Presentation Layer

- MVVM에서 ViewController(UI)와 ViewModel(Presentor)을 의미한다.
    - M을 제외한 VVM이 Presentation에 존대한다.
    - M은 Data/Domain Layer둘다 포함한다.
    - MVVM에서 클린 아키텍처 확장함에 있어서 M이 세분화 되었다.

- UI
- Presenters(=ViewModel)

---

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/image-20250524210248333.png' | relative_url }}" alt="커스텀셀" width="50%">
의존성이 바깥에서 안으로 향하고 있다.  고수준(Domain Layer)는 변동이 거의 일어나지 않는다. 저수준(Presentation Layer)는 변동이 자주 발생한다. 의존성의 방향은 자주 변하는 쪽에서 자주 변하지 않는 쪽으로 의존한다.  저수준은 고수준을 의존할 수 있지만. 고수준이 저수준을 의존하면 의존성 역전 원칙 위반이다.

### 의존성 역전 원칙 위반 예시

```swift
// 저수준 Data Layer
class Repository {
    func getUsers() {}
}

// 고수준 Domain Layer
class Usecase {
    private let repository = Repository() // 2. 고수준(Usecase)이 저수준(Repository)을 의존하고있다 -> 의존성 역전 위반
    func getUsers() {
        repository.getUsers()
    }
}

// 저수준 Presentation Layer
class ViewModel {
    private let usecase = Usecase() // 1. 저수준(ViewModel)이 고수준(usecase)을 의존하고 있다 O
}
```

### 의존성 역전 시킨 좋은 예시

```swift
// 의존성 역전을 하려면 -> Protocol(인터페이스)를 사용하면 된다. 
// 인터페이스는 추상화 한 개념이라 변경이 일어나지 않기 때문에 항상 고수준이다.
// ViewModel, Repository는 저수준, Usecase는 고수준

// Domain Layer
protocol RepositoryProtocol {
    func getUsers()
}

// 저수준 Data Layer
class Repository: RepositoryProtocol {
    func getUsers() {}
}

// 고수준 Domain Layer
class Usecase {
    private let repository: RepositoryProtocol // 2. 고수준(Usecase)이 고수준(protocol)을 의존하고있다 -> 의존성 역전 시켜서 클린아키텍처 원칙을 만족 O
    
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    func getUsers() {
        repository.getUsers()
    }
}


// 저수준 Presentation Layer
class ViewModel {
    private let usecase = Usecase(repository: Repository()) // 1. 저수준(ViewModel)이 고수준(usecase)을 의존하고 있다 -> 클린아키텍처 원칙 만족
}
```

<br/><br/>

# 최종 Clean Architecture 구조

<img src="{{ '/assets/img/2025-05-24-[CleanArchitecture]-Clean Architecture/123.drawio.png' | relative_url }}" alt="커스텀셀" width="100%">



