---
title: "[Swift] 8. 옵셔널"
tags:
  - Swift
  - Grammer
header:
  teaser:
typora-root-url: ../
---

## 옵셔널
```swift
@frozen
enum Optional<Wrapped> where Wrapped : ~Copyable, Wrapped : ~Escapable
```
- 래핑된 값 또는 값이 없는 경우를 나타내는 타입입니다.

## 옵셔널 구현
```swift
enum Optional<Wrapped> {
    case some<Wrapped> // 연관값
    case none          // 값이 없음, none는 nil과 완전 동일
}
```

## 옵셔널은 두 가지 경우를 가진 열거형이다
```swift
let number: Int? = Optional.some(42)
let noNumber: Int? = Optional.none
print(noNumber == nil)
// Prints "true"
```

## 옵셔널 값 추출 4가지
```swift
// 1) 강제 추출
num!

// 2) nil이 아닌지 확인후 강제추출
if num != nil { print(num!) }

// 3) 바인딩(상수나 변수에 대입)이 되는 경우만 특정 작업을 진행
if let name = optionalName {
    print(name)
}

// 4) Nil-Coalescing: 옵셔널 표션식 뒤에 기본값을 제시해서 옵셔널 가능성을 없앤다.
optionalName ?? "인덱스"
```

## 접근연산자 사용법
```swift
// 옵셔널 체이닝
// - 표현식이 옵셔널의 가능성이 있다는 것을 표현, 체이닝 결과는 항상 옵셔널
human?.choco?.name // 언래핑 필수
```

## Reference
- https://developer.apple.com/documentation/swift/optional