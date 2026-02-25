---
title: "[SwiftUI] Macro란?" 
tags:
- 
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

## Macro
> 매크로는 일련의 명령어들을 하나의 statement만을 이용하여 작성할 수 있게 하는데 사용된다.
> 큰 블럭의 코드를 작은 일련의 문자열로 만들어 닐 수 있기 때문에 매크로 라고 불린다

## Swift Macro
```swift
import ExampleMacros

let a = 17
let b = 25

let (result, code) = #stringify(a + b)
(a + b, "a + b")
print("The valye \(result)" was producted by the code \"\(code)\"")
```
- 컴파일 전에 매크로 실행 결과를 미리 볼 수 있고 컴파일 시 만들어진 코드에 에러가 있는 경우 알려준다
- 컴파일 타임에 자동 실행되며 호출자 주변의 코드를 보고 코드를 생성해준다

## Macro 파일 생성법
- Xcode -> File -> New -> Package

## Reference
- [올리브영 기술블로그](https://oliveyoung.tech/2023-11-15/swift-macro-part1/)
- [https://ios-development.tistory.com/1490](https://ios-development.tistory.com/1490)