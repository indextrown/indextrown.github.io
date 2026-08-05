---
title: "[PopPang] SwiftUI로 시작해 UICollectionView 기반 라이브러리를 만든 이유"
description: "팝팡 홈 리스트에서 반복되던 UICollectionView 연결 코드를 Component와 AnyComponent로 분리하고, 같은 UIKit 렌더링 경로에서 SwiftUI View까지 지원한 과정을 정리합니다."
tags:
  - PopPang
  - UIKit
  - SwiftUI
  - UICollectionView
header:
  teaser: /assets/img/2026-07-22-PopPangListKit/why-poppang-listkit.svg
typora-root-url: ../
---

팝팡 iOS 앱은 처음부터 SwiftUI로 만들었습니다. 화면을 빠르게 구성하고 상태에 따라 UI를 바꾸는 일은 편했습니다. 간단한 피드는 ScrollView와 LazyVStack만으로 금방 만들 수 있었습니다.

```swift
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(popups) { popup in
            PopupRow(popup: popup)
        }
    }
}
```

셀을 등록하거나 dataSource를 구현할 필요가 없습니다. 배열을 ForEach에 넘기고 View를 선언하면 끝입니다. SwiftUI를 선택한 가장 큰 이유도 이 생산성이었습니다.

<!--break-->

홈 화면이 커지자 상황이 달라졌습니다. 세로 피드 안에 가로 스크롤과 그리드가 섞였고, 동적 높이, 고정 헤더, 이미지 미리 받기, 페이지네이션, 실시간 데이터 갱신을 한 화면에서 다뤄야 했습니다. 어떤 데이터가 바뀌었고 어떤 셀이 다시 그려졌는지 알아야 성능을 조정할 수 있었지만, SwiftUI가 셀을 비교하고 갱신하는 과정은 프레임워크 안에 감춰져 있었습니다.

UICollectionView를 쓰면 갱신과 재사용을 세밀하게 다룰 수 있습니다. 대신 화면마다 delegate, dataSource, 셀 등록과 분기 코드를 다시 써야 합니다. SwiftUI에서 얻었던 생산성을 포기하고 싶지는 않았습니다.

그래서 SwiftUI의 작성 방식 위에 UICollectionView의 렌더링 경로를 연결했습니다. 화면은 List, Section, Cell로 선언하고, 실제 렌더링과 재사용은 UICollectionView가 맡습니다. UIKit으로 만든 UIView와 SwiftUI View도 같은 경로에서 갱신됩니다. 이 구조가 PopPangListKit입니다.

<figure>
  <img src="{{ '/assets/img/2026-07-22-PopPangListKit/why-poppang-listkit.svg' | relative_url }}" alt="SwiftUI List, UICollectionView Core, PopPangListKit의 역할을 비교한 그림" width="100%">
  <figcaption>SwiftUI의 선언 방식은 유지하고, 복잡한 화면의 렌더링 수명주기는 UICollectionView에서 관리합니다.</figcaption>
</figure>

## SwiftUI로 시작한 팝팡이 UICollectionView를 선택한 이유

팝팡 iOS 앱은 iOS 17부터 지원합니다. 구형 OS까지 함께 지원해야 해서 UICollectionView를 선택한 것은 아닙니다. iOS 17의 SwiftUI만으로도 피드를 만들 수 있었지만, 홈 화면에 필요한 스크롤 제어와 셀 갱신 범위를 개발자가 직접 정하기는 어려웠습니다.

SwiftUI로 피드를 만들다 보면 선택 기준은 화면 모양보다 갱신 방식에 가까워집니다. 갱신 범위가 작고 플랫폼 기본 리스트 동작이 중요한 설정 화면이나 정적인 메뉴에는 SwiftUI List가 잘 맞습니다. 디자인 자유도가 필요한 피드도 갱신이 복잡하지 않다면 ScrollView와 LazyVStack으로 만들 수 있습니다.

실시간 데이터가 계속 들어오고, 서로 다른 Section 레이아웃과 스크롤 애니메이션이 겹치면 UICollectionView가 더 잘 맞았습니다. 두 방식 모두 비슷한 화면을 만들 수 있습니다. 차이는 사용자에게 보이는 결과가 아니라 데이터를 비교하고 셀에 반영하는 구조에 있습니다.

### 문제 1: onAppear는 페이지 요청을 한 번만 보장하지 않습니다

SwiftUI에서는 마지막 셀이 나타날 때 다음 페이지를 요청하는 코드를 쉽게 붙일 수 있습니다.

```swift
ForEach(popups) { popup in
    PopupRow(popup: popup)
        .onAppear {
            guard popup.id == popups.last?.id else { return }
            loadNextPage()
        }
}
```

코드는 짧지만 onAppear는 페이지네이션 이벤트가 아니라 View가 화면에 나타났다는 알림입니다. 마지막 셀이 화면에서 사라졌다가 다시 보이면 클로저가 다시 불릴 수 있습니다. 상태가 빠르게 바뀌거나 같은 ID를 유지하지 못하면 호출 시점을 예상하기가 더 어려워집니다.

isLoading으로 중복 요청을 막아도 데이터 요청이 화면 표시 수명주기에 묶여 있다는 점은 같습니다. UICollectionViewDataSourcePrefetching처럼 요청 대상과 취소 시점을 indexPath 단위로 관리하는 방식과는 차이가 있습니다.

#### SwiftUI에서 보완하기

페이지 요청을 View에서 바로 실행하지 않고 모델이 중복 요청과 cursor를 관리하게 만들 수 있습니다. [task(id:)](https://developer.apple.com/documentation/swiftui/view/task%28id%3Aname%3Apriority%3Afile%3Aline%3A_%3A%29)도 ID가 바뀌면 기존 작업을 취소하고 다시 시작하므로 한 번만 요청한다는 보장은 모델이 맡습니다.

```swift
PopupRow(popup: popup)
    .task(id: popup.id) {
        await model.loadNextPageIfNeeded(currentID: popup.id)
    }
```

```swift
@MainActor
final class FeedModel: ObservableObject {
    @Published private(set) var popups: [Popup] = []

    private var nextCursor: String?
    private var isLoadingNextPage = false

    func loadNextPageIfNeeded(currentID: Popup.ID) async {
        guard currentID == popups.last?.id,
              let nextCursor,
              !isLoadingNextPage else { return }

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        guard let page = try? await api.fetchPopups(cursor: nextCursor) else {
            return
        }

        popups.append(contentsOf: page.items)
        self.nextCursor = page.nextCursor
    }
}
```

이렇게 하면 마지막 셀이 다시 나타나도 이미 진행 중인 요청을 한 번 더 보내지 않습니다. cursor가 같을 때 같은 페이지를 합치지 않는 검사까지 더하면 응답 중복에도 대응할 수 있습니다.

#### 그래도 PopPangListKit이 필요했던 이유

중복 요청을 막는 일은 PopPangListKit을 사용해도 모델이 책임져야 합니다. 라이브러리가 옮긴 것은 끝 도달을 감지하는 위치입니다. 각 셀의 task나 onAppear 대신 CollectionView의 스크롤 상태에서 .onReachEnd(offsetFromEnd:)를 호출하므로 View 수명과 페이지 감지를 분리할 수 있습니다. 화면마다 마지막 셀 판별 코드를 다시 만들 필요도 없습니다.

### 문제 2: LazyVStack에는 셀 단위의 미리 받기와 취소 시점이 없습니다

이미지도 onAppear와 onDisappear에 맞춰 미리 받고 취소할 수 있습니다.

```swift
PopupRow(popup: popup)
    .onAppear {
        imageLoader.prefetch(popup.imageURL)
    }
    .onDisappear {
        imageLoader.cancel(popup.imageURL)
    }
```

이 코드는 View가 나타나고 사라지는 시점에 반응합니다. 곧 화면에 들어올 셀을 미리 알려 주는 API는 아닙니다. 빠르게 위아래로 스크롤하면 같은 View의 호출이 반복될 수 있고, 페이지네이션과 이미지 요청이 같은 표시 이벤트에 묶입니다.

UICollectionView는 표시될 가능성이 높은 셀의 indexPath를 먼저 전달하고, 필요 없어지면 취소할 indexPath도 따로 알려 줍니다.

```swift
func collectionView(
    _ collectionView: UICollectionView,
    prefetchItemsAt indexPaths: [IndexPath]
) {
    imageLoader.prefetch(itemsAt: indexPaths)
}

func collectionView(
    _ collectionView: UICollectionView,
    cancelPrefetchingForItemsAt indexPaths: [IndexPath]
) {
    imageLoader.cancel(itemsAt: indexPaths)
}
```

[Apple의 prefetching 문서](https://developer.apple.com/documentation/uikit/prefetching-collection-view-data)처럼 모든 셀이 반드시 이 콜백을 거치는 것은 아니므로 cellForItemAt에서도 데이터를 준비할 수 있어야 합니다. 그래도 요청을 시작하는 경로와 취소하는 경로가 분리되어 있어 스크롤 속도에 따른 네트워크 작업을 추적하기 쉽습니다.

#### SwiftUI에서 보완하기

현재 보이는 셀의 다음 몇 개를 미리 받도록 범위를 직접 정할 수 있습니다. 아래의 cancelRequests는 이미지 로더가 제공한다고 가정한 메서드입니다.

```swift
ForEach(Array(popups.enumerated()), id: \.element.id) { index, popup in
    PopupRow(popup: popup)
        .onAppear {
            updatePrefetchWindow(around: index)
        }
}

private func updatePrefetchWindow(around index: Int) {
    guard index + 1 < popups.count else { return }

    let upperBound = min(popups.count, index + 7)
    let urls = popups[(index + 1)..<upperBound].map(\.imageURL)

    imageLoader.prefetch(urls)
    imageLoader.cancelRequests(except: Set(urls))
}
```

화면 크기와 이미지 비용에 맞춰 범위를 바꾸고, 빠른 역방향 스크롤에서는 앞쪽 데이터도 포함하도록 확장할 수 있습니다.

#### 그래도 PopPangListKit이 필요했던 이유

이 방식은 동작하지만 기준점이 여전히 onAppear입니다. 아직 생성되지 않은 View의 indexPath 우선순위나 UICollectionView가 보내는 취소 시점을 그대로 받을 수는 없습니다. PopPangListKit은 CollectionViewPrefetchingPlugin으로 요청과 취소를 받아 이미지 로더에 전달합니다. 화면은 미리 받을 범위와 표시 수명주기를 알지 않아도 됩니다.

### 문제 3: ID가 흔들리면 같은 셀도 새로운 View가 됩니다

Identifiable을 채택했더라도 ID가 매번 달라지면 SwiftUI는 이전 셀과 현재 셀을 연결하지 못합니다.

```swift
struct Popup: Identifiable {
    var id: UUID { UUID() } // 접근할 때마다 다른 ID
    let title: String
}
```

이 값으로 ForEach를 만들면 상태가 바뀔 때마다 모든 PopupRow가 새로 들어온 것처럼 보일 수 있습니다. 셀 안의 State가 초기화되고, transition이 다시 실행되며, onAppear도 다시 불릴 수 있습니다. ID는 데이터가 살아 있는 동안 함께 유지해야 합니다.

#### SwiftUI에서 보완하기

서버가 내려 준 식별자처럼 데이터와 수명을 함께하는 값을 저장합니다. 배열 index는 앞에 데이터가 들어오면 뒤의 모든 값이 바뀌므로 ID로 사용하지 않습니다.

```swift
struct Popup: Identifiable {
    let id: UUID             // 서버 ID나 생성 시 정한 값
    let title: String
}
```

#### 그래도 PopPangListKit이 필요했던 이유

PopPangListKit도 잘못 만든 ID를 고쳐 주지는 못합니다. 대신 Cell을 만들 때 ID와 비교할 Item을 따로 받습니다. ID는 같은 셀의 수명을 잇고, Item은 내용이 바뀌었는지 판단합니다. 화면마다 ForEach의 ID 규칙을 다르게 정하는 대신 diff 경계에서 두 역할을 드러낸 이유입니다.

### 문제 4: 조건 분기가 바뀌면 Identity와 애니메이션도 끊깁니다

SwiftUI는 명시적인 ID가 없는 View를 타입과 계층 위치로 구분합니다. 이를 Structural Identity라고 부릅니다.

```swift
if popup.isFeatured {
    FeaturedPopupRow(popup: popup)
} else {
    PopupRow(popup: popup)
}
```

두 분기는 타입이 다르므로 서로 다른 Identity를 가집니다. isFeatured가 바뀌면 기존 View를 수정하는 대신 한 View가 사라지고 다른 View가 생길 수 있습니다. 내부 State와 애니메이션을 이어가야 한다면 같은 View를 유지한 채 modifier나 입력값만 바꾸는 편이 안전합니다.

#### SwiftUI에서 보완하기

View 타입은 유지하고 달라지는 값만 modifier에 전달합니다.

```swift
PopupRow(popup: popup)
    .background(popup.isFeatured ? Color.yellow : Color.clear)
```

여기서 Identity는 diff에 사용하는 ID보다 넓은 개념입니다. 이전 상태의 View와 현재 상태의 View를 같은 대상으로 볼 수 있는지 정하는 기준입니다. [Demystify SwiftUI 정리]({{ '/swiftui-demystify-swiftui/' | relative_url }})에서는 Identity를 두 가지로 나눕니다.

| 구분 | SwiftUI가 View를 구별하는 기준 | 대표 예시 |
| --- | --- | --- |
| Explicit Identity | 개발자가 붙인 데이터 기반 식별자 | Identifiable.id, ForEach의 id, View.id |
| Structural Identity | View 계층 안의 타입과 위치 | if·switch 분기, VStack 안의 배치 순서 |

Identity가 유지되면 SwiftUI는 이전 View에 붙어 있던 State와 수명주기를 현재 View로 이어갈 수 있습니다. Identity가 달라지면 새로운 View로 취급할 수 있으므로 State, transition, onAppear 동작도 함께 달라집니다.

body가 다시 계산됐다고 화면 전체를 다시 그리는 것은 아닙니다. SwiftUI는 새 View 값을 기존 View Graph의 Identity와 의존성에 맞춰 본 뒤 실제로 바꿀 영역을 정합니다. 다만 이 판단 과정은 외부에 공개되지 않아 개발자가 diff 범위와 재사용 방식을 직접 조정하기 어렵습니다.

SwiftUI는 View의 Identity, 수명, 의존성을 바탕으로 변경된 부분을 계산합니다. 개발자는 상태와 View를 선언하고, 실제 비교와 갱신 시점은 프레임워크에 맡깁니다. [Apple의 Demystify SwiftUI 세션](https://developer.apple.com/videos/play/wwdc2021/10022/)도 안정적인 식별자가 View의 수명과 성능을 유지하는 데 중요하다고 설명합니다.

#### 그래도 PopPangListKit이 필요했던 이유

조건을 modifier로 옮기는 방법은 같은 View 타입을 유지할 수 있을 때 효과적입니다. 팝팡 홈처럼 UIKit View와 SwiftUI View, 배너와 카드처럼 실제 타입이 다른 UI가 섞이면 한 타입으로 맞출 수 없습니다. PopPangListKit은 각 UI가 Component에서 생성과 갱신 방법을 설명하게 하고, AnyComponent가 타입 차이를 Adapter에서 감춥니다. SwiftUI View 내부의 Identity는 여전히 올바르게 설계해야 하지만 바깥 셀의 ID와 갱신 경계는 라이브러리가 관리합니다.

팝팡 홈에서는 셀 갱신과 onAppear 기반 페이지 요청이 겹칠 때 프레임이 떨어지는 문제를 확인했습니다. 원인을 찾아도 SwiftUI 내부의 diff 범위나 재사용 전략을 직접 바꿀 수는 없었습니다. 홈처럼 데이터가 자주 바뀌는 화면에서는 어느 셀을 언제 갱신할지 더 명확하게 다룰 방법이 필요했습니다.

### 문제 5: 애니메이션 범위가 Transaction에 따라 달라집니다

SwiftUI 애니메이션은 상태 변화와 View Identity를 바탕으로 동작합니다. withAnimation이나 animation modifier가 현재 update의 Transaction에 애니메이션을 넣으면 그 문맥이 View 계층을 따라 전달됩니다.

```swift
VStack(spacing: 0) {
    CollapsingHeader(isCollapsed: isHeaderCollapsed)

    LazyVStack {
        ForEach(popups) { popup in
            PopupRow(popup: popup)
        }
    }
}
.animation(.easeInOut(duration: 0.25), value: popups.map(\.id))
```

이 코드는 popups의 ID 배열이 바뀌면 상위 VStack에서 애니메이션을 시작합니다. 같은 update에서 isHeaderCollapsed도 바뀌었다면 새 셀의 삽입뿐 아니라 헤더의 크기 변화도 같은 Transaction을 받을 수 있습니다. 셀만 움직이려 했는데 헤더까지 애니메이션되는 식입니다.

Identity가 안정적이지 않으면 결과는 더 달라집니다. 개발자는 기존 셀이 새 위치로 이동한다고 생각했지만 SwiftUI는 이전 View를 제거하고 새 View를 삽입할 수 있습니다. 이때 이동 애니메이션 대신 transition이 다시 실행되고, 셀의 State와 onAppear도 새로 시작합니다. 애니메이션이 끝나기 전에 다음 실시간 데이터가 들어오면 View는 다시 새로운 목표 상태를 향해 갱신됩니다.

[Apple의 SwiftUI animation 세션](https://developer.apple.com/videos/play/wwdc2023/10156/)에서는 Transaction이 현재 update의 애니메이션 문맥을 View 계층에 전달하며, 범위를 넓게 잡으면 우연히 같은 Transaction에 들어온 속성도 애니메이션될 수 있다고 설명합니다. animation modifier를 필요한 하위 View에만 붙이거나 transaction과 withTransaction으로 범위를 조정할 수는 있습니다. 피드가 커질수록 어느 상태가 같은 Transaction을 공유하는지 계속 관리해야 합니다.

#### SwiftUI에서 보완하기

animation modifier를 실제로 움직일 셀 계층에만 붙이면 헤더는 같은 Transaction의 영향을 받지 않습니다.

```swift
VStack(spacing: 0) {
    CollapsingHeader(isCollapsed: isHeaderCollapsed)

    LazyVStack {
        ForEach(popups) { popup in
            PopupRow(popup: popup)
        }
    }
    .animation(.easeInOut(duration: 0.25), value: popups.map(\.id))
}
```

실시간 데이터가 짧은 간격으로 들어오는 구간에서는 Transaction의 animation을 nil로 바꾸거나 disablesAnimations를 사용해 애니메이션을 끌 수도 있습니다. 셀 삽입처럼 필요한 변화에만 애니메이션을 남기는 것이 핵심입니다.

#### 그래도 PopPangListKit이 필요했던 이유

범위를 좁히면 의도하지 않은 애니메이션은 막을 수 있습니다. 다만 SwiftUI가 같은 ID를 이동으로 처리했는지, 삭제와 삽입으로 처리했는지 외부에서 직접 선택할 수는 없습니다. 실시간 update가 이어질 때 다음 상태를 언제 반영할지도 화면마다 따로 조정해야 합니다.

UICollectionView는 diff 결과를 삽입, 삭제, 이동으로 나눈 뒤 한 batch update에 적용할 수 있습니다.

```swift
collectionView.performBatchUpdates {
    currentItems = nextItems
    collectionView.deleteItems(at: deletedIndexPaths)
    collectionView.insertItems(at: insertedIndexPaths)

    moves.forEach { move in
        collectionView.moveItem(at: move.from, to: move.to)
    }
} completion: { finished in
    applyPendingSnapshotIfNeeded()
}
```

어떤 셀이 삽입되고 삭제되며 이동하는지 코드에서 확인할 수 있습니다. 애니메이션을 끄거나, 변경량이 크면 reload로 바꾸거나, 완료된 뒤 다음 스냅샷을 적용하는 기준도 정할 수 있습니다. [performBatchUpdates](https://developer.apple.com/documentation/uikit/uicollectionview/performbatchupdates%28_%3Acompletion%3A%29)는 batch 안의 작업을 함께 애니메이션하고 완료 여부를 전달합니다. Diffable Data Source를 사용한다면 새 스냅샷을 apply할 때 애니메이션 여부와 completion을 지정할 수 있습니다.

PopPangListKit은 Diffable Data Source 대신 List 스냅샷과 DifferenceKit을 사용하지만 흐름은 같습니다. 이전 상태와 새 상태의 차이를 먼저 구한 뒤 batch update를 실행합니다. 실행 중 새 상태가 들어오면 가장 최신 값만 보관했다가 현재 update가 끝난 뒤 적용합니다. 애니메이션 결과를 항상 같게 만든다는 뜻은 아닙니다. 어떤 변경을 애니메이션할지, 언제 다음 변경을 받을지 정할 수 있다는 뜻입니다.

### 문제 6: iOS 17에서도 연속적인 스크롤 위치를 바로 받을 수 없었습니다

iOS 17에는 [scrollPosition(id:anchor:)](https://developer.apple.com/documentation/swiftui/view/scrollposition%28id%3Aanchor%3A%29)과 scrollTargetLayout이 추가됐습니다. 특정 ID로 이동하거나 현재 기준점에 걸린 셀의 ID를 상태로 받는 데 유용합니다. 하지만 홈 헤더를 스크롤한 만큼 접거나, 콘텐츠 끝까지 남은 거리를 계산하려면 셀 ID가 아니라 연속적인 content offset이 필요합니다.

#### SwiftUI에서 보완하기

iOS 17의 ScrollView에는 UIScrollViewDelegate의 scrollViewDidScroll과 같은 콜백이 없습니다. SwiftUI만 사용하면 GeometryReader와 PreferenceKey로 콘텐츠의 위치를 읽는 방식을 주로 사용합니다.

```swift
private struct FeedOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

ScrollView {
    LazyVStack {
        // 셀 구성
    }
    .background {
        GeometryReader { proxy in
            Color.clear.preference(
                key: FeedOffsetKey.self,
                value: proxy.frame(in: .named("feed")).minY
            )
        }
    }
}
.coordinateSpace(name: "feed")
.onPreferenceChange(FeedOffsetKey.self) { offset in
    headerOffset = offset
}
```

측정용 View를 어디에 두는지에 따라 값이 달라지고, 스크롤 중 바뀌는 값을 SwiftUI 상태에 다시 쓰면 그 상태를 읽는 View도 갱신 대상이 됩니다. 헤더 애니메이션 하나를 만들 때도 측정 위치와 상태 의존 범위를 함께 관리해야 합니다.

[onScrollGeometryChange](https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange%28for%3Aof%3Aaction%3A%29)를 쓰면 ScrollGeometry에서 content offset을 바로 읽을 수 있지만 iOS 18부터 사용할 수 있습니다. 팝팡은 iOS 17도 지원하므로 GeometryReader 경로를 함께 유지해야 합니다.

#### 그래도 PopPangListKit이 필요했던 이유

GeometryReader 방식으로도 헤더 애니메이션과 끝 도달 계산을 만들 수 있습니다. 문제는 화면마다 coordinate space, PreferenceKey, 상태 갱신 범위를 다시 정해야 한다는 데 있습니다. offset을 SwiftUI 상태에 그대로 넣으면 스크롤할 때마다 그 상태를 읽는 View가 다시 계산될 수도 있습니다.

UICollectionView에서는 같은 값을 delegate에서 바로 읽을 수 있습니다.

```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    headerOffset = -scrollView.contentOffset.y
}
```

PopPangListKit은 delegate의 context를 .didScroll과 .onReachEnd로 전달합니다. 스크롤에 따라 바뀌는 버튼이나 헤더 상태는 scrollOverlay에 분리해 List 스냅샷 전체를 다시 만들지 않게 했습니다.

### 문제 7: SwiftUI List는 홈 피드의 Section 구조와 맞지 않았습니다

SwiftUI List는 설정이나 메뉴처럼 한 방향의 행을 Section으로 나누는 화면에서 편합니다. 선택, 스와이프 액션, 구분선, 편집 같은 기본 동작도 이미 갖추고 있습니다. 팝팡 홈은 세로 카드 사이에 가로 스크롤과 그리드가 섞이고, Section마다 서로 다른 레이아웃과 미리 받기 동작이 필요했습니다.

#### SwiftUI에서 보완하기

List 안에 가로 ScrollView를 넣어 비슷한 모양을 만들 수는 있습니다.

```swift
List {
    Section {
        ForEach(featuredPopups) { popup in
            PopupRow(popup: popup)
        }
    }

    Section {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(categories) { category in
                    CategoryCard(category: category)
                }
            }
        }
    }
}
```

#### 그래도 PopPangListKit이 필요했던 이유

다만 List에서 보면 가로 영역 전체가 하나의 행입니다. 바깥 List와 안쪽 ScrollView의 표시 수명주기도 따로 움직입니다. UICollectionView Compositional Layout처럼 Section마다 세로, 가로, 그리드 배치를 정하고 모든 셀의 표시·미리 받기 이벤트를 한곳에서 처리하는 구조는 아닙니다.

팝팡 홈에서는 List의 기본 행 동작을 활용하기보다 inset과 구분선을 걷어 내고, 중첩된 ScrollView의 상태를 별도로 관리하는 코드가 더 많이 필요했습니다. 그래서 List를 꾸며 홈에 맞추기보다 UICollectionView의 Section 레이아웃을 선언형 API로 감싸는 쪽을 선택했습니다.

## SwiftUI 보완 코드를 반복하지 않으려고 PopPangListKit을 만들었습니다

앞의 일곱 문제는 SwiftUI에서도 우회하거나 영향 범위를 줄일 수 있습니다. 구조가 단순한 화면이라면 각 해결 코드를 직접 넣는 편이 낫습니다. 팝팡 홈에서는 같은 코드가 여러 피드에 반복되고, 페이지 요청·미리 받기·스크롤·애니메이션이 서로의 상태에 영향을 주기 시작했습니다.

필요했던 것은 SwiftUI를 대체할 UI 프레임워크가 아니었습니다. 화면은 계속 SwiftUI처럼 선언하되 셀 재사용, diff, Section 레이아웃과 스크롤 수명주기를 한곳에서 관리할 경계가 필요했습니다.

| 반복되던 코드 | PopPangListKit으로 옮긴 위치 |
| --- | --- |
| 마지막 셀의 onAppear와 페이지 감지 | List의 .onReachEnd |
| 이미지 요청 범위와 취소 | CollectionViewPrefetchingPlugin |
| 셀 ID와 내용 변경 비교 | Cell의 ID·Item, DifferenceKit diff |
| 삽입·삭제·이동 애니메이션 순서 | Adapter의 batch update와 최신 스냅샷 대기 |
| offset 측정과 헤더 상태 | .didScroll context와 scrollOverlay |
| 세로·가로·그리드 조합 | Section의 Compositional Layout factory |
| UIKit View와 SwiftUI View 분기 | Component와 AnyComponent |

UICollectionView에서는 데이터 상태와 반영 시점을 직접 정할 수 있습니다. 예를 들어 [Diffable Data Source](https://developer.apple.com/documentation/uikit/updating-collection-views-using-diffable-data-sources)는 새 스냅샷을 명시적으로 적용하고, 이전 상태와 비교해 필요한 항목만 갱신합니다. 셀 생성과 재사용은 재사용 큐로 드러나며, 스크롤과 표시 수명주기는 delegate로 관찰할 수 있습니다. 무엇이 언제 실행되는지 추적할 수 있어 병목을 측정하고 갱신 전략을 바꾸기 쉽습니다.

여기서 예측 가능하다는 말은 UICollectionView가 언제나 더 빠르다는 뜻이 아닙니다. 어떤 스냅샷을 언제 적용했는지, diff가 어떤 삽입·삭제·이동을 만들었는지, batch update가 언제 끝났는지를 코드에서 확인할 수 있다는 뜻입니다. 프레임이 떨어졌다면 diff 계산, 셀 갱신, 레이아웃, 이미지 요청 중 어디에서 시간이 걸렸는지 나눠서 측정할 수 있습니다.

두 방식을 팝팡 홈 화면의 요구사항에 맞춰 비교하면 다음과 같습니다.

| 기준 | SwiftUI List · LazyVStack | UICollectionView 기반 구조 |
| --- | --- | --- |
| 데이터 갱신 | Identity와 상태 의존성을 바탕으로 프레임워크가 조정 | 새 데이터 상태를 원하는 시점에 명시적으로 적용 |
| View 수명 | 프레임워크가 Identity를 기준으로 관리 | 셀 생성, 재사용, 표시 종료 흐름이 외부에 드러남 |
| 애니메이션 | 상태 변화, Identity, Transaction에 따라 범위가 결정 | diff 결과를 삽입, 삭제, 이동으로 나눠 batch update에 적용 |
| ID 기준 스크롤 | iOS 17의 scrollPosition과 ScrollViewReader로 이동 | scrollToItem으로 이동 |
| 연속 위치 관찰 | iOS 17에서는 GeometryReader와 PreferenceKey 조합이 필요 | UIScrollViewDelegate에서 contentOffset과 감속 수명주기를 관찰 |
| 미리 받기 | indexPath 단위의 시작·취소 지점을 같은 수준으로 제공하지 않음 | prefetchDataSource에서 요청과 취소를 직접 처리 |
| 페이지네이션 | 마지막 View의 onAppear와 요청 상태를 함께 관리 | 스크롤 위치와 표시 셀을 관찰해 끝 도달 시점을 계산 |
| Section 레이아웃 | 중첩 ScrollView와 Stack을 조합 | Compositional Layout에서 세로, 가로, 그리드를 Section별로 구성 |
| 성능 조정 | 안정적인 ID와 작은 상태 의존성 설계가 중요 | diff, batch update, reload 기준과 레이아웃을 조정 가능 |

iOS 17의 scrollPosition과 [ScrollViewReader](https://developer.apple.com/documentation/swiftui/scrollviewreader)는 ID 기준 위치를 다룹니다. iOS 18의 [ScrollPosition](https://developer.apple.com/documentation/swiftui/scrollposition)과 onScrollGeometryChange는 좌표와 geometry 관찰 범위를 넓혔습니다. [SwiftUI의 스크롤 API](https://developer.apple.com/documentation/swiftui/scroll-views)는 계속 좋아지고 있지만 최소 지원 버전에 따라 쓸 수 있는 제어 수단이 달라집니다. [UICollectionViewDataSourcePrefetching](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching)처럼 indexPath 단위에서 요청과 취소를 직접 다루는 경로와도 성격이 다릅니다.

메신저나 실시간 피드처럼 항목이 계속 바뀌고 스크롤 위치까지 보존해야 하는 화면에서는 이 차이가 크게 느껴집니다. 복잡한 스크롤 상호작용, 헤더 애니메이션, 이미지 미리 받기, 페이지네이션까지 겹치면 UICollectionView 쪽이 문제를 재현하고 조정하기 수월했습니다.

PopPangListKit의 실제 구현에는 UICollectionViewDiffableDataSource가 들어가지 않습니다. 자체 List 값을 스냅샷으로 삼고, DifferenceKit으로 이전 List와 새 List의 차이를 계산한 뒤 batch update로 반영합니다. 데이터 상태를 명시적으로 적용한다는 생각은 같지만 실제 구현 도구는 다릅니다.

## UICollectionView를 직접 연결하면 화면 코드가 무거워집니다

UICollectionView를 선택하면 셀의 수명주기를 직접 다룰 수 있습니다. 동시에 익숙한 반복 코드도 돌아옵니다.

```swift
collectionView.register(PopupCell.self, forCellWithReuseIdentifier: "PopupCell")
collectionView.register(BannerCell.self, forCellWithReuseIdentifier: "BannerCell")

func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
) -> UICollectionViewCell {
    switch sections[indexPath.section].items[indexPath.item] {
    case let .popup(item):
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PopupCell",
            for: indexPath
        ) as! PopupCell
        cell.configure(item)
        return cell

    case let .banner(item):
        // BannerCell을 꺼내고 갱신하는 분기가 이어집니다.
    }
}
```

화면 하나만 보면 이해하기 쉽습니다. 그러나 셀 종류가 늘어날 때마다 등록, dequeue, 캐스팅, 모델 주입, 크기 계산 분기가 같이 늘어납니다. dataSource를 Adapter로 옮겨도 문제는 사라지지 않습니다. 이번에는 Adapter가 모든 구체적인 셀을 알아야 합니다.

팝팡 홈에는 세로 피드, 가로 카드, 그리드, 헤더와 푸터가 함께 들어갑니다. 화면을 추가할 때마다 Adapter의 switch 문까지 고치는 구조라면 공통화한 이점이 작았습니다. 그래서 셀 타입을 Adapter가 고르는 대신, 각 UI가 자신의 생성과 갱신 방법을 설명하도록 방향을 바꿨습니다.

## Component가 UIView의 생성과 갱신을 설명합니다

PopPangListKit의 Component는 UICollectionViewCell이 아닙니다. 화면에 표시할 UIView와 그 View를 갱신할 데이터를 한 단위로 묶은 값입니다. 실제 프로토콜에서 핵심만 남기면 다음과 같습니다.

```swift
public protocol Component {
    associatedtype Item: Equatable
    associatedtype Content: UIView
    associatedtype Coordinator = Void

    var item: Item { get }
    var reuseIdentifier: String { get }
    var layoutMode: ContentLayoutMode { get }

    func renderContent(coordinator: Coordinator) -> Content
    func render(in content: Content, coordinator: Coordinator)
    func layout(content: Content, in container: UIView)
    func makeCoordinator() -> Coordinator
}
```

각 타입의 역할은 분명합니다.

| 구성 | 맡는 일 |
| --- | --- |
| Item | 화면에 그릴 데이터이며, 이전 값과 새 값을 비교하는 기준 |
| Content | 실제로 재사용할 UIView 타입 |
| Coordinator | target-action, delegate, 구독처럼 View와 함께 유지할 연결 상태 |
| renderContent | 처음 필요할 때 Content를 한 번 생성 |
| render | 재사용 중인 Content에 새 Item을 반영 |
| layout | 공통 셀 안에 Content를 배치 |
| layoutMode | 콘텐츠의 높이와 너비를 컬렉션 레이아웃에서 계산하는 규칙 |

예를 들어 팝업 카드는 다음처럼 표현할 수 있습니다.

```swift
struct PopupCardComponent: Component {
    let item: Popup

    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 88)
    }

    func renderContent(coordinator: Void) -> PopupCardView {
        PopupCardView()
    }

    func render(in content: PopupCardView, coordinator: Void) {
        content.configure(with: item)
    }
}
```

생성과 갱신은 서로 다른 메서드가 맡습니다. PopupCardView는 셀이 처음 필요할 때 만들어지고, 같은 셀이 다시 사용될 때는 render만 호출됩니다. View 계층을 매번 새로 만들지 않고 기존 View에 데이터만 바꿀 수 있습니다.

실제 셀은 UICollectionViewComponentCell 하나입니다. 이 공통 셀은 처음 받은 Component로 Content와 Coordinator를 만든 뒤 컨테이너에 배치합니다. 재사용될 때는 이미 들어 있는 Content에 render를 다시 호출합니다. 셀 종류마다 UICollectionViewCell 서브클래스를 만들 필요가 없습니다.

```swift
func render(component: AnyComponent) {
    if let renderedContent {
        component.render(
            in: renderedContent,
            coordinator: coordinator ?? ()
        )
    } else {
        coordinator = component.makeCoordinator()
        let content = component.renderContent(
            coordinator: coordinator ?? ()
        )
        component.layout(content: content, in: contentView)
        renderedContent = content
        component.render(in: content, coordinator: coordinator ?? ())
    }
}
```

공통 셀은 preferredLayoutAttributesFitting에서 Content의 sizeThatFits를 호출하고 측정값을 보관합니다. Component의 layoutMode와 Section의 Compositional Layout은 이 크기를 이용해 동적 높이, 고정 크기, 가로 스크롤 카드 같은 배치를 만듭니다.

## AnyComponent가 서로 다른 Component를 한 배열에 담습니다

Component만으로는 하나의 Section을 구성할 수 없습니다. associatedtype이 있는 프로토콜은 구현마다 구체 타입이 다르기 때문입니다.

```swift
let popup = PopupCardComponent(item: popupItem)    // Content == PopupCardView
let banner = BannerComponent(item: bannerItem)     // Content == BannerView

// 구체 타입이 다른 두 값을 같은 Component 배열에 바로 담을 수 없습니다.
```

List의 한 Section에는 팝업 카드, 배너, 공지처럼 서로 다른 UI가 들어갈 수 있습니다. Adapter가 모든 타입을 알지 않으면서도 각 Component의 renderContent와 render를 호출할 공통 인터페이스가 필요했습니다. AnyComponent가 이 타입 차이를 지웁니다.

구현은 세 겹으로 나뉩니다.

1. AnyComponentBox는 PopupCardComponent 같은 실제 값을 보관합니다.
2. ComponentBox는 각 Box를 같은 방식으로 호출할 내부 약속입니다.
3. AnyComponent는 외부에서 사용하는 최종 타입 소거 래퍼입니다.

```swift
private struct AnyComponentBox<Base: Component>: ComponentBox {
    let baseComponent: Base

    func renderContent(coordinator: Any) -> UIView {
        baseComponent.renderContent(
            coordinator: coordinator as! Base.Coordinator
        )
    }

    func render(in content: UIView, coordinator: Any) {
        guard let content = content as? Base.Content,
              let coordinator = coordinator as? Base.Coordinator else {
            return
        }
        baseComponent.render(in: content, coordinator: coordinator)
    }
}

public struct AnyComponent: Component, Equatable {
    private let box: any ComponentBox

    public init(component: some Component) {
        box = AnyComponentBox(baseComponent: component)
    }
}
```

AnyComponent는 UIView의 구체 타입만 가립니다. diff와 재사용에 필요한 정보는 그대로 남깁니다.

- reuseIdentifier는 어떤 Component 타입의 Content를 재사용할지 정합니다.
- AnyItem은 서로 다른 Item을 Equatable 비교가 가능한 값으로 감쌉니다.
- 두 AnyComponent는 reuseIdentifier와 Item이 모두 같을 때 같은 내용으로 판단됩니다.
- as 메서드는 이미지 미리 받기처럼 특정 기능을 제공하는 Component인지 확인할 때 사용합니다.

```swift
public static func == (lhs: AnyComponent, rhs: AnyComponent) -> Bool {
    lhs.reuseIdentifier == rhs.reuseIdentifier
        && lhs.item == rhs.item
}
```

셀의 ID가 같고 Item이 달라지면 DifferenceKit은 같은 셀의 내용이 바뀌었다고 판단합니다. Component 타입까지 달라지면 reuseIdentifier가 달라지므로 다른 렌더링 경로가 필요하다는 사실도 함께 전달됩니다. 타입은 지웠지만 갱신 판단에 필요한 의미는 남아 있습니다.

<figure>
  <img src="{{ '/assets/img/2026-07-22-PopPangListKit/poppang-listkit-architecture.svg' | relative_url }}" alt="UIKit Component와 SwiftUI View가 AnyComponent, Cell, Section, List를 거쳐 공통 UICollectionViewCell에 렌더링되는 구조" width="100%">
  <figcaption>입력 UI는 달라도 AnyComponent 이후에는 같은 diff, 레이아웃, 재사용 경로를 거칩니다.</figcaption>
</figure>

## List 스냅샷이 diff와 레이아웃의 입력이 됩니다

Component가 하나의 UI를 설명한다면 Cell, Section, List는 화면 전체의 현재 상태를 설명합니다.

```text
List
└── Section
    ├── Header
    ├── Cell
    │   └── AnyComponent
    └── Footer
```

Cell에는 안정적인 ID와 AnyComponent, 선택·표시·하이라이트 이벤트가 들어갑니다. Section은 Cell 배열과 헤더, 푸터, Compositional Layout 규칙을 가집니다. List는 Section 배열과 스크롤, 새로고침, 끝 도달 이벤트를 담습니다.

화면은 현재 상태로 새 List를 만들고 Adapter에 적용합니다.

```swift
let list = List {
    Section(id: "nearby-popups") {
        for popup in popups {
            Cell(
                id: popup.id,
                component: PopupCardComponent(item: popup)
            )
            .didSelect { _ in open(popup) }
        }
    }
    .withSectionLayout(
        VerticalLayout(spacing: 12)
            .insets(.init(top: 16, leading: 20, bottom: 24, trailing: 20))
    )
}
.onReachEnd { _ in loadNextPage() }

adapter.apply(list)
```

Adapter는 이전 List와 새 List로 DifferenceKit의 StagedChangeset을 만듭니다. 계산된 삽입, 삭제, 이동, 내용 변경을 batch update로 적용합니다. 변경량이 설정한 기준을 넘으면 전체 reload로 전환할 수 있습니다.

실시간 데이터가 연달아 들어올 때도 순서를 관리합니다. 컬렉션 뷰가 update 중이면 새 요청을 바로 실행하지 않고 최신 List를 보관합니다. 현재 update가 끝난 뒤 가장 최근 상태를 적용해 중간 스냅샷이 화면을 덮지 않게 합니다.

레이아웃은 Section이 가진 factory에서 만듭니다. 같은 List 안에서도 세로, 가로, 그리드 Section을 섞을 수 있습니다. 스크롤 delegate 이벤트와 prefetchDataSource도 Adapter가 받아 Cell과 List의 이벤트, 미리 받기 플러그인으로 전달합니다. 화면에는 delegate 메서드가 퍼지지 않습니다.

## SwiftUI View도 같은 Component 경로로 보냅니다

PopPangListKit은 SwiftUI용 렌더링 엔진을 따로 만들지 않았습니다. SwiftUI View를 SwiftUIHostingComponent로 감싼 뒤 기존 AnyComponent 경로에 넣습니다.

```swift
struct SwiftUIHostingComponent<Item: Equatable, Content: View>: Component {
    let item: Item
    let layoutMode: ContentLayoutMode
    let content: Content

    func renderContent(coordinator: Void) -> HostingContentView<Content> {
        HostingContentView(rootView: content)
    }

    func render(
        in contentView: HostingContentView<Content>,
        coordinator: Void
    ) {
        contentView.rootView = content
    }
}
```

HostingContentView는 UIHostingController를 보관하는 UIView입니다. 최초 렌더링에서는 hosting controller를 만들고, 재사용 시에는 rootView만 교체합니다. 크기 측정은 UIHostingController의 sizeThatFits 결과를 공통 셀에 돌려줍니다.

전체 화면은 UIViewControllerRepresentable로 연결합니다. PopPangList라는 SwiftUI View 안에서 PopPangListViewController를 만들고, 그 ViewController가 UICollectionView와 Adapter를 소유합니다.

```text
PopPangList
└── UIViewControllerRepresentable
    └── PopPangListViewController
        ├── UICollectionView
        └── CollectionViewAdapter
```

UIKit Component와 SwiftUI View는 한 Section에 함께 들어갈 수 있습니다. 둘 다 마지막에는 AnyComponent가 되고, 같은 Cell ID 비교와 DifferenceKit update를 거쳐 같은 UICollectionViewComponentCell에 표시됩니다.

SwiftUI View를 직접 Cell로 선언하는 초기화 메서드도 이 변환을 감춥니다.

```swift
Cell(
    id: popup.id,
    item: popup,
    layoutMode: .flexibleHeight(estimatedHeight: 96)
) { popup in
    PopupRow(popup: popup)
}
```

For는 이 Cell 생성을 반복해 주는 DSL입니다. 데이터의 ID는 Cell의 ID가 되고, 데이터 자체는 Item 비교에 사용됩니다.

```swift
For(popups, id: \.id) { popup in
    PopupRow(popup: popup)
}
.layoutMode(.flexibleHeight(estimatedHeight: 96))
.didSelect { popup in
    selectedPopup = popup
}
```

SwiftUI 문법으로 View를 작성해도 실제 셀 생성, 재사용, diff, 레이아웃은 UIKit Component와 같은 경로에서 처리됩니다. SwiftUI 지원을 별도 렌더링 엔진으로 만들지 않은 이유가 여기에 있습니다.

## SwiftUI 상태와 List 스냅샷 사이의 문제를 해결했습니다

SwiftUI View를 UICollectionView에 넣는 것만으로는 충분하지 않았습니다. SwiftUI 상태 갱신과 컬렉션 뷰 update의 실행 시점이 다르기 때문에 몇 가지 문제가 생겼습니다.

### Binding Cell로 입력값이 되돌아가는 문제를 막았습니다

처음에는 Toggle에 Item의 복사본을 전달했습니다. 사용자가 값을 바꾸면 부모 상태는 갱신되지만, 새 List가 적용되기 전까지 hosting View의 getter는 이전 값을 읽었습니다. Toggle이 잠깐 원래 상태로 돌아오는 것처럼 보였습니다.

Binding을 받는 Cell 초기화 메서드는 부모 상태를 직접 읽고 씁니다.

```swift
for index in items.indices {
    let item = $items[index]

    Cell(id: item.wrappedValue.id, item: item) { item in
        Toggle(item.wrappedValue.title, isOn: item.isEnabled)
    }
}
```

내부에서는 Binding과 현재 value를 함께 보관합니다. Equatable 비교에는 value만 사용하므로 Item이 바뀌면 diff가 감지하고, 입력 중에는 Binding이 부모 상태와 UI를 바로 연결합니다. iOS 15 이상에서는 같은 ID의 셀을 reconfigure하고, 이전 버전에서는 reloadItems로 대체합니다.

### 최신 SwiftUI 상태만 List에 적용합니다

SwiftUI 상태가 빠르게 바뀌면 updateUIViewController가 연달아 호출됩니다. 각 호출이 독립된 Task로 List를 적용하면 늦게 끝난 이전 Task가 최신 화면을 덮을 수 있습니다.

Representable의 Coordinator는 아직 시작하지 않은 update를 취소하고 가장 최근 List만 남깁니다. Task.yield로 SwiftUI View 갱신이 끝난 뒤 UICollectionView 변경을 시작합니다. 이미 시작된 update는 Adapter가 끝날 때까지 처리하고, 그 사이 들어온 요청 중 가장 최신 List를 다음에 적용합니다.

```swift
pendingUpdate?.cancel()
pendingUpdate = Task { @MainActor [weak viewController] in
    await Task.yield()
    guard !Task.isCancelled, let viewController else { return }
    viewController.apply(list)
}
```

두 계층이 다루는 시점은 다릅니다. Coordinator는 시작 전 SwiftUI update를 정리하고, Adapter는 이미 시작된 collection update 사이의 순서를 지킵니다.

### Item이 없는 View도 새 상태를 반영합니다

SwiftUI View가 외부 상태를 클로저로 캡처하면 Cell ID는 같아도 내용이 달라질 수 있습니다. 하지만 SwiftUI View 자체는 일반적으로 Equatable이 아니어서 DifferenceKit에 변경 사실을 전달할 값이 없습니다.

Item을 생략한 Cell에는 매 List 스냅샷마다 새로 만들어지는 SwiftUIRefreshToken을 넣었습니다. 새 스냅샷에서는 내용이 바뀐 것으로 판단해 rootView를 갱신합니다.

편한 대신 갱신 범위가 넓어질 수 있으므로, 특정 데이터가 바뀔 때만 다시 그려야 하는 셀은 item 초기화 메서드를 사용하는 편이 좋습니다. Item은 단순한 View 입력값이 아니라 diff 범위를 정하는 기준입니다.

## 스크롤과 미리 받기도 List 선언에 붙입니다

리스트 렌더링에 UICollectionView를 사용한 이유는 스크롤 수명주기를 다루기 위해서입니다. SwiftUI 화면에서도 같은 제어 지점을 사용할 수 있어야 했습니다.

List에는 새로고침, 끝 도달, 스크롤, 드래그, 감속 이벤트를 modifier처럼 붙일 수 있습니다. Cell에는 선택, 표시 시작과 종료, 하이라이트 이벤트를 붙입니다. 이미지 미리 받기는 CollectionViewPrefetchingPlugin으로 분리해 indexPath 요청과 취소를 연결합니다.

```swift
PopPangList(prefetchingPlugins: [imagePrefetchingPlugin]) {
    // Sections
}
.onRefresh { _ in reload() }
.onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1)) { _ in
    loadNextPage()
}
.didScroll { context in
    updateHeader(offset: context.collectionView.contentOffset.y)
}
```

프로그램 스크롤은 ListProxy가 현재 ViewController에 약하게 연결되어 처리합니다. 스크롤에 따라 위로 가기 버튼을 표시하는 상태가 List 전체를 다시 만들지 않도록 scrollOverlay는 별도 ObservableObject 상태를 사용합니다. 스크롤 UI의 변화가 데이터 스냅샷 적용까지 건드리지 않도록 경계를 나눴습니다.

## UIKit에서 사용하는 전체 예제

UIKit에서는 Component로 UIView의 생성과 갱신을 정의하고, 화면은 List 스냅샷만 Adapter에 전달합니다.

<details class="notion-toggle-list" markdown="1">
<summary>UIKit 전체 코드 보기</summary>

```swift
import PopPangListKit
import UIKit

struct Popup: Equatable {
    let id: UUID
    let title: String
    let place: String
}

final class PopupCardView: UIView {
    private let titleLabel = UILabel()
    private let placeLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        placeLabel.font = .preferredFont(forTextStyle: .subheadline)
        placeLabel.textColor = .secondaryLabel
        placeLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(placeLabel)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with popup: Popup) {
        titleLabel.text = popup.title
        placeLabel.text = popup.place
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(
            CGSize(
                width: size.width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

struct PopupCardComponent: Component {
    let item: Popup

    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 88)
    }

    func renderContent(coordinator: Void) -> PopupCardView {
        PopupCardView()
    }

    func render(in content: PopupCardView, coordinator: Void) {
        content.configure(with: item)
    }
}

final class PopupListViewController: UIViewController {
    private let layoutAdapter = CollectionViewLayoutAdapter()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(layoutAdapter: layoutAdapter)
        view.backgroundColor = .systemBackground
        view.alwaysBounceVertical = true
        return view
    }()

    private lazy var adapter = CollectionViewAdapter(
        configuration: .init(),
        collectionView: collectionView,
        layoutAdapter: layoutAdapter
    )

    private var popups: [Popup] = [
        .init(id: UUID(), title: "성수 팝업", place: "서울 성동구"),
        .init(id: UUID(), title: "더현대 팝업", place: "서울 영등포구"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        applyPopups()
    }

    private func applyPopups() {
        let list = List {
            Section(id: "popups") {
                for popup in popups {
                    Cell(
                        id: popup.id,
                        component: PopupCardComponent(item: popup)
                    )
                    .didSelect { _ in
                        print("selected:", popup.id)
                    }
                }
            }
            .withSectionLayout(
                VerticalLayout(spacing: 12)
                    .insets(
                        NSDirectionalEdgeInsets(
                            top: 16,
                            leading: 20,
                            bottom: 24,
                            trailing: 20
                        )
                    )
            )
        }
        .onReachEnd { [weak self] _ in
            self?.loadNextPage()
        }

        adapter.apply(list)
    }

    private func loadNextPage() {
        // 다음 페이지를 받은 뒤 popups를 바꾸고 applyPopups()를 호출합니다.
    }
}
```

</details>

## SwiftUI에서 사용하는 전체 예제

SwiftUI에서는 UIView나 UICollectionViewCell을 만들지 않습니다. PopupRow를 선언하면 내부에서 SwiftUIHostingComponent와 AnyComponent로 변환됩니다. 리스트 렌더링의 실제 뼈대는 같은 UICollectionView입니다.

<details class="notion-toggle-list" markdown="1">
<summary>SwiftUI 전체 코드 보기</summary>

```swift
import PopPangListKit
import SwiftUI
import UIKit

struct Popup: Identifiable, Equatable {
    let id: UUID
    let title: String
    let place: String
    var isBookmarked: Bool
}

struct PopupListScreen: View {
    @State private var popups: [Popup] = [
        .init(
            id: UUID(),
            title: "성수 팝업",
            place: "서울 성동구",
            isBookmarked: false
        ),
        .init(
            id: UUID(),
            title: "더현대 팝업",
            place: "서울 영등포구",
            isBookmarked: true
        ),
    ]

    @State private var listProxy = ListProxy()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PopPangList(proxy: listProxy) {
                Section(id: "popups") {
                    For(popups, id: \.id) { popup in
                        PopupRow(popup: popup)
                    }
                    .layoutMode(.flexibleHeight(estimatedHeight: 96))
                    .didSelect { popup in
                        print("selected:", popup.id)
                    }

                    for index in popups.indices {
                        let popup = $popups[index]

                        Cell(
                            id: "bookmark-\(popup.wrappedValue.id)",
                            item: popup,
                            layoutMode: .flexibleHeight(estimatedHeight: 52)
                        ) { popup in
                            Toggle(
                                "\(popup.wrappedValue.title) 저장",
                                isOn: popup.isBookmarked
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .withHeader {
                    Text("지금 인기 있는 팝업")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
                .withSectionLayout(
                    VerticalLayout(spacing: 12)
                        .insets(
                            NSDirectionalEdgeInsets(
                                top: 16,
                                leading: 20,
                                bottom: 24,
                                trailing: 20
                            )
                        )
                )
            }
            .onRefresh { _ in reload() }
            .onReachEnd { _ in loadNextPage() }

            Button {
                listProxy.scrollToTop(animated: true)
            } label: {
                Image(systemName: "arrow.up")
                    .padding(14)
                    .background(.blue, in: Circle())
                    .foregroundStyle(.white)
            }
            .padding(20)
        }
    }

    private func reload() {
        // 데이터를 다시 받은 뒤 popups를 교체합니다.
    }

    private func loadNextPage() {
        // 다음 페이지를 받은 뒤 popups에 추가합니다.
    }
}

private struct PopupRow: View {
    let popup: Popup

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(popup.title)
                .font(.headline)
            Text(popup.place)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.secondary.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}
```

</details>

## PopPangListKit이 잘 맞는 화면

간단한 화면에 UICollectionView Core와 타입 소거, hosting controller까지 넣으면 얻는 것보다 관리할 것이 많아집니다. PopPangListKit은 셀의 수명주기를 직접 조정해야 할 때 선택하는 도구입니다.

다음 조건이 여러 개 겹칠 때 이 구조의 장점이 커집니다.

- 한 화면에 세로, 가로, 그리드 Section이 섞입니다.
- 동적 높이와 고정 헤더를 함께 사용합니다.
- 실시간 데이터가 들어오며 스크롤 위치를 유지해야 합니다.
- 이미지 미리 받기와 취소 시점을 직접 다뤄야 합니다.
- 페이지네이션 기준과 스크롤 수명주기를 조정해야 합니다.
- UIKit UIView와 SwiftUI View를 같은 Section에 함께 표시합니다.

반대로 정적인 설정 화면이나 작은 카드 피드라면 SwiftUI List, ScrollView와 LazyVStack이 더 단순합니다. 도구를 선택하는 기준은 UIKit과 SwiftUI 중 무엇이 더 최신인지가 아니라, 셀 갱신과 스크롤을 어느 정도까지 관찰하고 조정해야 하는지입니다.

PopPangListKit도 비용이 있습니다. 안정적인 Section과 Cell ID를 정해야 하고, Item의 Equatable 비교가 실제 변경 의미와 맞아야 합니다. SwiftUI View를 UIKit에 올릴 때는 hosting controller가 추가됩니다. Item이 없는 편의 API는 새 스냅샷마다 내용을 갱신하므로 셀 수가 많다면 item 기반 API로 범위를 줄여야 합니다.

## 셀 의존성이 이동한 위치

이 설계는 셀을 없애지 않았습니다. 구체적인 셀 의존성이 놓이는 위치를 바꿨습니다.

UICollectionView를 직접 연결하면 화면이나 Adapter가 PopupCell, BannerCell, GridCell을 등록하고 꺼냅니다. PopPangListKit에서는 화면이 List, Section, Cell만 선언합니다. 구체 UIView의 생성과 갱신은 Component가 알고, AnyComponent가 그 차이를 감춘 뒤 공통 UICollectionViewComponentCell 하나가 렌더링합니다.

<figure>
  <img src="{{ '/assets/img/2026-07-22-PopPangListKit/cell-dependency-boundary.svg' | relative_url }}" alt="구체 UICollectionViewCell 의존성이 화면에서 PopPangListKit의 Component Core로 이동하는 그림" width="100%">
  <figcaption>새 UI가 생겨도 ViewController와 Adapter의 셀 분기는 늘어나지 않습니다.</figcaption>
</figure>

SwiftUI 지원도 같은 경계를 지킵니다. 화면은 SwiftUI View를 선언하지만, 내부에서는 SwiftUIHostingComponent가 Component 역할을 맡습니다. UIKit UIView와 SwiftUI View는 AnyComponent 뒤에서 하나의 렌더링 경로로 합쳐집니다.

화면은 어떤 UICollectionViewCell을 등록하고 재사용하는지 알지 못합니다. Adapter도 PopupCardView나 SwiftUI의 PopupRow를 알지 못합니다. 둘은 현재 화면을 나타내는 List 스냅샷만 주고받습니다. 셀 의존성을 라이브러리 경계 안으로 옮긴 덕분에 SwiftUI의 작성 경험과 UICollectionView의 조정 지점을 함께 유지할 수 있었습니다.

## 참고 자료

- [PopPangListKit 저장소와 README](https://github.com/team-PopPang/PopPangListKit)
- [Component 구현](https://github.com/team-PopPang/PopPangListKit/blob/8ce3f4b531b41e73c78d6200a3ea21df1309c47c/Sources/PopPangListKit/Component/2.%20Component.swift)
- [AnyComponent 구현](https://github.com/team-PopPang/PopPangListKit/blob/8ce3f4b531b41e73c78d6200a3ea21df1309c47c/Sources/PopPangListKit/Component/3.%20AnyComponent.swift)
- [CollectionViewAdapter 구현](https://github.com/team-PopPang/PopPangListKit/blob/8ce3f4b531b41e73c78d6200a3ea21df1309c47c/Sources/PopPangListKit/Adapter/52.%20CollectionViewAdapter.swift)
- [SwiftUI Cell 연결 구현](https://github.com/team-PopPang/PopPangListKit/blob/8ce3f4b531b41e73c78d6200a3ea21df1309c47c/Sources/PopPangListKit/SwiftUISupport/55.%20Cell%2BSwiftUI.swift)
- [Apple, Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/)
- [블로그, Demystify SwiftUI 정리]({{ '/swiftui-demystify-swiftui/' | relative_url }})
- [Apple, Updating collection views using diffable data sources](https://developer.apple.com/documentation/uikit/updating-collection-views-using-diffable-data-sources)
- [Apple, Prefetching collection view data](https://developer.apple.com/documentation/uikit/prefetching-collection-view-data)
