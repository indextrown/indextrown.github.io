---
title: "[SwiftUI] Demystify SwiftUI"
tags:
  - Swift
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="https://github.com/user-attachments/assets/3938e583-0fc4-4620-99b0-bf761e60a1ba" width="60%" align="left"> -->

#### SwiftUI가 코드를 볼 때 무엇을 보는가?
- Identity(정체성) - SwiftUI가 앱의 여러 업데이트에서 동일 요소로 보거나 별개 요소로 보는 방법
- Lifetime(수명) - SwiftUI가 시간이 지남에 따라 View와 Data 존재를 추적하는 방법
- Dependencies(의존성) - SwiftUI가 인터페이스를 업데이트해야 하는 시기와 이유를 이해하는 방법


#### Identity(정체성) - SwiftUI가 앱의 여러 업데이트에서 동일 요소로 보거나 별개 요소로 보는 방법
![image-20260601150619822](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601150619822.png)
사진에서 두 강아지가 다른 강아지인지 혹은 두 장의 같은 강아지인지 알 수 없다.
정보가 충분하지 않아 사실을 말할 수 없기 때문이다. 이 질문을 SwiftUI는 Identity(정체성) 이라고 부른다.

![image-20260601150933679](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601150933679.png)
다른 예시로, 아이콘이 서로 완전히 독립 객체인지 알 수 없다.
완전히 다른 객체일 수도 있고 단지 위치만 다르고 다른 색을 가진 동일한 객체일수도 있다.
이러한 구분을 "한 상태에서 다른 상태로 전환하는 방식"을 변경하기 때문에 중요한 부분이다.
만약 서로 같은 객체라면 현 위치에서 다른 위치로 이동하는 동일한 뷰이기 때문에 전환 중에 객체가 아래로 내려가야 한다.
따라서 서로 다른 상태에 걸쳐 뷰를 연결하는 것이 중요하다. 이것이 SwiftUI가 뷰 사이를 전달하는 방법을 이해하는 방식이기 때문이다. 이게 View Identity 핵심 가치다.

#### SwiftUI는 두 가지 다른 유형의 Identity에 초점을 두고 있다.
- Explicit of Identity(명시적 정체성): 맞춤형 또는 데이터 기반 식별자를 사용한다.
- Structural Identity(구조적 정체성): 뷰 계층 구조에서의 유형과 위치에 따라 뷰를 구별한다.

![image-20260601151352773](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601151352773.png)
사물을 식별하기 위해 보통 이름을 부여할 수 있다.
하지만 두 사물이 똑같이 생기고 같은 계열일 가능성이 높을 수 있어서 이름으로는 고유성이 부족할 수 있다.
이름이나 식별자를 할당하는 것은 Explicit of Identity(명시적 정체성) 의 한 형태이다.
이는 강력하고 유연하지만 누군가 어딘가에서 이름을 추적해야 한다.

![image-20260601151759888](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601151759888.png)
이미 익숙할 수 있는 Explicit of Identity의 한 형태는 UIKit 및 AppKit 전체에서 사용되는 포인터 Identity다.
SwiftUI에서는 포인터 Identity를 사용하지 않고 UIView와 NSView에서 사용한다.
UIView와 NSView는 클래스이므로 메모리 할당에 필요한 고유한 포인터를 가진다. 포인터는 Explicit of Identity의 자연스러운 원천이라고 한다.
포인터를 사용해 개별 뷰를 참조할 수 있으며 두 뷰가 동일한 포인터를 공유하는 경우 실제로 동일한 뷰임을 보장할 수 있다.

![image-20260601151819505](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601151819505.png)
하지만 SwiftUI View는 일반적으로 클래스 대신 구조체로 표현하는 값 타입이기 때문에 SwiftUI는 포인터를 사용하지 않는다.
가장 중요한 점은 값 타입은 SwiftUI가 해당 View에 대한 지속적인 Identity로 사용할 수 있는 정식 참조가 없다는 것이다.

![image-20260601152414474](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601152414474.png)
여기서 사용된 id는 Explicit of Identity의 한 형태이다.
각 강아지의 인식표 Identity는 View를 명시적으로 식별하는 데 사용된다.
강아지 컬렉션이 변경되면 SwiftUI는 해당 Id를 사용해 무엇이 변경되는지 이해하고 목록 내에서 올바른 애니메이션을 생성할 수 있다.

![image-20260601152720076](/assets/img/2026-06-01-[SwiftUI] diff/image-20260601152720076.png)
또 다른 예제인데 여기서는 ScrollViewReader를 사용해 하단 버튼을 사용하여 뷰 상단으로 이동한다. 
.id() Modifier는 사용자 정의 식별자를 사용해 뷰를 명시적으로 식별하는 방법을 제공한다. 
현재 페이지 상단의 헤더 뷰에 식별자를 추가한 것이다. 

#### 구조적 정체성 등장
추가로 해당 식별자를 뷰 프록시의 scrollTo(_:) 메서드에 전달해 SwiftUI에게 특정 뷰로 이동하도록 지시할 수 있다. 
이 장점은 모든 뷰를 명시적으로 식별할 필요가 없고 헤더와 같이 코드의 다른 곳에서 참조해야 하는 뷰만 식별할 수 있다는 것이다. 
ScrollViewreader, ScrollView, 텍스트 및 버튼에는 명시적인 식별자가 필요하지 않는다.
그러나 정체성이 명시적이지 않다고 해서 이러한 뷰가 전혀 정체성이 없다는 것을 의미하지는 않는다.
명시적이지 않더라도 모든 View는 Identity가 있기 때문이다. → 여기서 구조적 정체성이 등장