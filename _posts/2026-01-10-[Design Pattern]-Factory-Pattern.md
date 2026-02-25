---
title: "[Design Pattern] Factory Method Pattern"
tags:
- Design Pattern
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

# 한문장 정리
> 팩토리 메서드 패턴(Factory Method Pattern)은 단일 객체 생성만을 담당하는 추상화된 프로토콜을 생성한 후, 객체 생성은 프로토콜의 구체화 클래스에서 담당하게 하는 패턴이다.
> 객체를 직접 만들지 않고 "만드는 책임"을 다른 객체(공장)에게 위임한다.

# 키워드 정리
- `Product`: 가능을 가진 물건이라는 약속(인터페이스)
- `Concreate Product`: 실제로 만들어지는 구현체
- `Creator`: 이런 제품을 만들 수 있다 라는 약속
- `Concreate Creator`: 어떤 제품을 만들지 결정하는 곳
- `Factory Method`: 공장에서 실제로 객체를 생성하는 메서드

# 팩토리 패턴(Factory Pattern)
객체의 생성을 "팩토리"라는 별도의 클래스로 분리하여 추상화된 부분에 의존하다록 만드는 패턴이다.  
근본적으로는 팩토리 패턴으로 객체 생성 과정의 책임을 분리할 수 있으며 더 나아가 복잡한 객체를 생성하는 과정을 숨길 수 있고 객체(UI Component) 생성 과정에서 변경 사항이 생겼을 때 수정이나 확장이 용이하다는 장점이 있다.  
  
# 팩토리 패턴 종류
팩토리 패턴은 팩토리 메서드 패턴(Factory Method Pattern)과 추상 팩토리 패턴(Abstract Factory Pattern)으로 나눌 수 있다.    
- `Factory Method`: 단일 객체 생성만을 담당하는 추상화된 프로토콜 생성, 객체 생성은 프로토콜의 구체화 클래스에서 담당  
- `Abstract Factory`: 관련된 객체를 묶어서 생성할 수 있는 추상화된 프로토콜 생성, 객체 생성은 마찬가지 구체화 클래스에서 담당    

# 팩토리 패턴 용어
- `Abstract Product`: 생성하고자 하는 객체를 추상화한 Protocol -> "뷰 공장에서 "뷰" 라고 가정
- `Concreate Product`: Abstruct Product를 구체적으로 구현한 Class -> 다양한 뷰(버튼, 라벨, 텍스트 피드 등) 가정  

```swift
// Abstruct Product
// - 객체를 생성할 수 있는 별도의 추상화된 프로토콜
protocol View {}

// Concrete Product
// - 객체를 실제로 공장처럼 만들어내는 메서드
class iOSCustomButton: View {}
class AndroidCustomButton: View {}
```

# 이해하기
팩토리 메서드 패턴에는 객체를 생성할 수 있는 별도의 추상화된 프로토콜(= Abstract Creator)을 만들어준다.  
이 프로토콜 안에는 실제로 공장처럼 만들어내는 메서드(= Factory Method)가 존재한다.

## 예시 1
```swift
// Abstruct Creator
protocol ViewFactory {
    // Factory Method
    func makeCustomView(with: Platform) -> View
}

// Concreate Creator
class CustomButtonFactory: ViewFactory {
    func makeCustomView(with: Platform) -> View {
        switch (with) {
            case .iOS:
                return IOSCustomButton()
            case .android:
                return AndroidCustomButton()
        }
    }
}

class CustomLabelFactory: ViewFactory {
    func makeCustomView(with: Platform) -> View {
        switch (with) {
            case .iOS:
                return IOSCustomLabel()
            case .android:
                return AndroidCustomLabel()
        }
    }
}

let customButtonFactory = CustomButtonFactory()
let iOSButton = customButtonFactory.makeCustomView(with: .iOS)
let androidButton = customButtonFactory.makeCustomView(with: .android)
```

## 예시 2
- Product
- 생성 대상의 공통 인터페이스

```swift
protocol Animal {
    var name: String { get set }
    func sound()
}
```

- Concrete Product
- 실제로 생성되는 객체(생성자는 외부에 있지만 직접 호출하지 않음

```swift
class Dog: Animal {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func sound() {
        print("\(name) Bark! 🐶")
    }
}

class Cat: Animal {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func sound() {
        print("\(name) Meow! 🐱")
    }
}
```

- Creator(=Factory 인터페이스)
- 객체 생성 책임의 추상화

```swift
// Factory 인터페이스
protocol AnimalFactory {
    // Factory Method
    func make(with name: String) -> Animal
}
```

- ConcreteCreator

```swift
// 랜덤 동물이 나오도록
class RandomAnimalFactory: AnimalFactory {
    func make(with name: String) -> Animal {
        return Int.random(in: 0...1) == 0 ? Dog(name: name) : Cat(name: name)
    }
}

// 이전에 생성한 타입을 기억해서 다른 동물이 나오도록
class EvenAnimalFactory: AnimalFactory {
    var previousState: Animal.Type?
    func make(with name: String) -> any Animal {
        if previousState == Cat.self {
            self.previousState = Dog.self
            return Dog(name: name)
        } else {
            self.previousState = Cat.self
            return Cat(name: name)
        }
    }
}
```

- 사용 예제

```swift
class AnimalCafe {
    private var animals: [Animal] = []
    private var factory: AnimalFactory
    
    init(factory: AnimalFactory) {
        self.factory = factory
    }
    
    func addAnimal(with name: String) {
        let animal = factory.make(with: name)
        animals.append(animal)
    }
    
    func change(factory: AnimalFactory) {
        self.factory = factory
    }
    
    func printAnimals() {
        self.animals.forEach { animal in
            animal.sound()
        }
    }
    
    func clear() {
        self.animals = []
    }
}

let animalCafe = AnimalCafe(factory: EvenAnimalFactory())
animalCafe.addAnimal(with: "A")
animalCafe.addAnimal(with: "B")
animalCafe.addAnimal(with: "C")
animalCafe.addAnimal(with: "D")
animalCafe.printAnimals()

animalCafe.clear()
print("\n## Change Factory ##\n")
animalCafe.change(factory: RandomAnimalFactory())

animalCafe.addAnimal(with: "A")
animalCafe.addAnimal(with: "B")
animalCafe.addAnimal(with: "C")
animalCafe.addAnimal(with: "D")
animalCafe.printAnimals()

// 출력
A Meow! 🐱
B Bark! 🐶
C Meow! 🐱
D Bark! 🐶

## Change Factory ##

A Bark! 🐶
B Meow! 🐱
C Bark! 🐶
D Bark! 🐶
```

## Reference
- [https://mini-min-dev.tistory.com/257](https://mini-min-dev.tistory.com/257)
- [https://icksw.tistory.com/237](https://icksw.tistory.com/237)
- [https://velog.io/@ryan-son/디자인-패턴-Factory-pattern-in-Swift](https://velog.io/@ryan-son/디자인-패턴-Factory-pattern-in-Swift)
- [https://jeonyeohun.tistory.com/385](https://jeonyeohun.tistory.com/385)