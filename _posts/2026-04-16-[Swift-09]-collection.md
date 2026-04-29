---
title: "[Swift] 9. 컬렉션"
tags:
  - Swift
  - Grammer
header:
  teaser:
typora-root-url: ../
---

## 컬렉션
```swift
protocol Collection<Element> : Sequence
```
- 데이터를 여러 번 비파괴적으로 순회할 수 있고, 인덱스 첨자를 통해 접근할 수 있는 시퀀스
- 컬렉션이 변경될 필요가 없는 경우에는 immutable 으로 생성해 컴파일러가 컬렉션 성능을 최적화할 수 있다.

## 추후 배열, 딕셔너리, 집합 정리 예정

## Reference
- https://docs.swift.org/swift-book/documentation/the-swift-programming-language/collectiontypes/
- https://developer.apple.com/documentation/Swift/Collection