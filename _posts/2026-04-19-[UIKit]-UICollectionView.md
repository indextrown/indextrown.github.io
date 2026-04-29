---
title: "[UIKit] UICollectionView 정복하기"
tags:
  - UIKit
header:
  teaser:
typora-root-url: ../
---

## UICollectionView
```swift
@MainActor
class UICollectionView
```
- 정렬된 데이터 항목 모음을 관리하고 사용자 정의 가능한 레이아웃을 사용하여 표시하는 객체이다.

## DataSource
- 컬렉션뷰는 컬렉션뷰의 속성에 저장된 데이터 소스 객체에서 데이터를 가져온다.
  - 데이터 소스에는 컬렉션뷰의 데이터와 사용자 인터페이스 업데이트를 간단하고 효율적으로 관리하는 데 필요한 동적을 제공한다.
  - 프로토콜을 채택하여 사용자 지정 데이터소스 객체를 만들수도 있다.
- [UICollectionViewDataSource](https://developer.apple.com/documentation/uikit/uicollectionviewdatasource)
- [UICollectionViewDiffableDataSource](https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasource-9tqpa)

## Item
- item은 표시하려는 가장 작은 데이터 단위이다.
- collectionView의 데이터는 개별 item으로 구분되고, 이러한 iteme들은 그룹화하여 표시할 수 있다.
- collectionView는 datasource가 구성하고 제공하는 클래스의 인스턴스인 셀을 사용하여 화면에 item을 표시한다.
- [UICollectionViewCell](https://developer.apple.com/documentation/uikit/uicollectionviewcell)

## Supplementary View
- collectionView는 셀 외에도 다른 유형의 뷰를 사용하여 데이터를 표시할 수 있다. 이러한 보조 뷰는 섹션 헤더 밑 푸터가 될 수 있다.
- Supplementary View는 선택사항이고 collectionView의 layout 객체에서 정으된다.

## UICollectionViewDiffableDataSource
- 컬렉션뷰의 메서드를 사용해 항목의 시각적 표현이 데이터 소스 개체의 순서와 일치하도록 할 수 있다. 
- 컬렉션에서 데이터를 추가, 삭제 또는 재배열할 때마다 컬렉션 뷰의 메서드를 사용하여 해당 셀을 삽입, 삭제, 재배열한다.

## Layout
- Layout객체는 CollectionView에서 콘텐츠의 시각적 배치를 정의한다.
- 클래스의 하위 클래스인 레이아웃 객체는 컬렉션 뷰 내의 모든 셀과 보조 뷰의 구성 위치를 정의한다.
- 레이아웃 객체는 위치를 정의하지만 실제로 해당 정보를 해당 뷰에 적용하지는 않는다.
- [UICollectionViewLayout](https://developer.apple.com/documentation/uikit/uicollectionviewlayout)

## Cell & Supplementary Views
- collectionView의 datasource는 item에 대한 콘텐츠와 해당 콘텐츠를 표시하는 데 사용되는 뷰를 모두 제공한다.
- 컬렉션 뷰가 처음 로드 시 데이터소스에 표시되는 각 항목에 대한 뷰를 제공하도록 요청한다. 컬렉션 뷰는 데이터 소스가 재사용을 위해 표시한 뷰 객체의 큐 또는 목록을 유지한다.
- 코드에서 명시적으로 새 뷰를 가져오는 것이 아니라 항상 큐에서 뷰를 가져온다.