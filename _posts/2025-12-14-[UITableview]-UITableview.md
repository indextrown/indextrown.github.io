---
title: "[UIKit] UITableview 개념 정리"
tags: 
- UIKit
- UITableview
header: 
  teaser: 
typora-root-url: ../

---

> ## UITableview
사용자 지정 가능한 행으로 구성된 단일 열에 데이터를 표시합니다.
```swift
@MainActor
class UITableView
```

## 개념
테이블 뷰는 행과 섹션으로 나뉜, 세로로 스크롤되는 콘텐츠를 한 열료 표시한다.   
각 행에는 하나의 정보를 기본으로 표시한다. 섹션을 사용하면 관련된 행들을 그룹화할 수 있다.

## 협업되는 객체
1. `Cell`: 셀은 콘텐츠를 시각적으로 표현하는 요소이다.
2. `Tableview` 컨트롤러: 테이블뷰를 관리하는 데 객체를 사용한다. 테이블 관련 기능을 위해 사용한다.
3. `Datasource`: 프로토콜을 채택하고 테이블에 필요한 데이터를 제공한다,
4. `Delegate`: 프로토콜을 채택하고 테이블 내용과 사용자의 상호작용을 관리한다.


## Reference
- [UITableview Document](https://developer.apple.com/documentation/uikit/table-views)