---
title: "[Swift] 10. 열거형"
tags:
  - Swift
  - Grammer
header:
  teaser:
typora-root-url: ../
---

## 커스텀 타입
- Swift에서는 개발자가 직접 만들 수 있는 `사용자 정의 타입이 있다`
- enum, class, struct로 구현 가능하다.
- class나 struct는 데이터를 묶어서 사용할 목적이다.

## 열거형
```swift
enum Weekday {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

// .monday: 인스턴스를 생성한다 = data를 만들어서 메모리에 저장한다.
var today: Weekday = .monday
```
- 타입 자체를 한정된 사례(case) 안에서 정의할 수 있는 타입이다.
- 미리 정의해둔 타입의 케이스에서 벗어날 수 없으므로 코드 가독성과 안정성이 높아진다.

## 열거형의 원시값(Raw Values)
```swift
// 알아서 case별로 0부터 6까지 매칭됨
enum Weekday: Int {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

// 알아서 case별로 문자열이 매칭됨
enum Weekday: String {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

var today: Weekday? = Weekday(rawValue: 0) // 원시값으로 쉽게 인스턴스 생성 가능
var today: Weekday = Weekday(rawValue: 0)! // monday
var num: Int = Weekday.monday.rawValue     // 0
```

## 열거형의 연관값(Associated Values)
```swift
enum Computer {
    case cpu(core: Int, ght: Double)
    case ram(Int, String)
    case hardDisk(gb: Int)
}

var chip: Computer = Computer.cpu(core: 6, ghz: 1.4)
var chip1: Computer = Computer.ram(16, "DDR4")
```
- 구체적인 정보를 저장하기 위해 사용함(케이스가 카테고리의 역할로 바뀜)

## 연관값 Switch, 조건문
```swift
enum Computer {
    case cpu(core: Int, ght: Double)
    case ram(Int, String)
    case hardDisk(gb: Int)
}

let chip = Computer.cpu(core: 8)
// switch
switch chip {
case .cpu(core: 8):
    print("cpu 8코어")
case .cpu(core: let c):
    print("cpu: \(c)")
case .ram(_):
    print("RAM")
case let .hardDisk(gb: g):
    print("하드: \(g)gb):
}

// 조건문(특정 케이스만 다룰수 있다)
if case let .ram(ram) = chil {
    print("ram: \(ram)")
}

for case .cpu(core: let c) in chiplists {
    print("cpu칩: \(c)코어")
}
```