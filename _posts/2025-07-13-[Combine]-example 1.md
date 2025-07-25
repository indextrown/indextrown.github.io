---
title: "[Combine] 예제 1 & 제네릭으로 UIKit에서 SwiftUI 불러오기"
tags: 
- Combine
header: 
  teaser: 
typora-root-url: ../
---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## Combine 예제

<img src="{{ '/assets/img/2025-06-18-[Combine]-/image-20250714015117890.png' | relative_url }}" alt="이미지" width="70%">
#### 1. scrollView 추가 및 상하좌우 제약 0 설정
<br/><br/>

---

<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250714020253349.png' | relative_url }}" alt="이미지" width="70%">
#### 2. UIView 추가 및 추가한 UIView를 Content Layout Guide에 드래그하여 상하좌우 제약 0 설정
- UIView를 Frame Layout Guide로 드래그해서 Equal Width 해주자
- size inspactor에서 width(가로막대) 더블 클릭 -> Proportional Widt~ 클릭 -> Multiplier를 1로 설정
- 이상태에서 빨간 오류 뜨는 이유는 View에 대한 내용물이 없어서 즉 크기가 없어서 그렇다
<br/><br/>

---

<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250714020847129.png' | relative_url }}" alt="이미지" width="70%">

#### 3. View에 Vertical Stack View 생성
- Stack View를 View로 드래그하여 상하좌우 제약 0으로 설정
- vertical stack에서 가로 크기를 꽉 채우기 위해 alighment는 fill 설정
- vertical stack에서 내용물을 동일하게 분배시키기 위해 fill equally 설정
- spacing 20 설정
- 이제 크기가 있는 애를 스택뷰에 넣으면 오토레이아웃이 잡힌다
- 추가적으로 size inspactor에서 simulated size를 Fixed -> Freeform으로 변경한다, 높이를 1000으로 설정한다.
<br/><br/>

---

#### 4. 결과
<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250714021514646.png' | relative_url }}" alt="이미지" width="70%">

---

#### 5. 화면이동을 위해 네비게이션 컨투롤러로 감싸기

<img src="{{ '/assets/img/2025-07-13-[Combine]-example 1/image-20250717165409170.png' | relative_url }}" alt="이미지" width="70%">

---

### 6. 화면이동 코드
```swift
//
//  ViewController.swift
//  CombineTutorial-example
//
//  Created by 김동현 on 7/14/25.
//

import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {

    // Combine의 구독을 저장하는 Set
    // VC가 해제되면 subscriptions 프로퍼티도 함께 메모리에서 해제되고, 그 안에 저장된 구독들도 함께 해제되어 메모리 누수를 방지한다
    // 구독 찌꺼기 담는 통: VC가 메모리에서 해제되면 VC에서 사용된 구독 찌꺼기가 담긴다
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var navToNumbersBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navToNumbersBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")
                #warning("TODO: - numbers로 화면이동")
                let numbersStoryboard = UIStoryboard(name: "Numbers", bundle: Bundle.main)
                
                // vc의 storyboardId
                let numbersVC = numbersStoryboard.instantiateViewController(withIdentifier: "NumbersViewController")
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
    }
}
```

---

#### 7. 화면이동 코드 리팩토링 꿀팁
- name과 withIdentifier를 하드코딩하지 않는 간단한 방법으로 수정 가능하다.
- 프로토콜을 활용하면 된다.

#### UIViewController+.swift
```swift
import UIKit

/*
 static 변수
 - 인스턴스를 생성하지 않아도 접근할 수 있다
 - 타입에 속한 변수이며, 모든 인스턴스가 이 값을 공유한다
 
 static 함수는
 - 인스턴스를 만들지 않고도 호출할 수 있다
 - 보통 공통 정보 제공이나 객체 생성 팩토리 용도로 사용한다
 
 */

protocol Storyboarded {
    // static함수는 해당하는 객체를 메모리에 만들지 않아도 만들 수 있다
    static func instantiate(_ storyboardName: String) -> Self
}

// 프로토콜 정의
// Storyboarded를 준수하면서 본인이 UIViewController이라면
extension Storyboarded where Self: UIViewController {
    
    /// 객체를 메모리에 생성하지 않고도 호출 가능한 타입 메서드입니다.
    ///
    /// 주어진 스토리보드 이름에서 이 타입의 뷰 컨트롤러를 인스턴스화합니다.
    /// - Parameter storyboardName: 뷰 컨트롤러가 위치한 스토리보드 파일의 이름
    /// - Returns: 스토리보드에서 생성된 현재 타입(Self)의 인스턴스
    static func instantiate(_ storyboardName: String) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main) // 내자신의 이름
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
        return vc
    }
}

extension UIViewController: Storyboarded {}
```

#### ViewController.swift
```swift
import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {

    // Combine의 구독을 저장하는 Set
    // VC가 해제되면 subscriptions 프로퍼티도 함께 메모리에서 해제되고, 그 안에 저장된 구독들도 함께 해제되어 메모리 누수를 방지한다
    // 구독 찌꺼기 담는 통: VC가 메모리에서 해제되면 VC에서 사용된 구독 찌꺼기가 담긴다
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var navToNumbersBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navToNumbersBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = NumbersViewController.instantiate("Numbers")
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
    }
}
```

---

#### 8. UIKit에서 SwiftUI 사용
- SwiftUI + Combine을 위해 추가해보자

#### NumbersSwiftUIContainerVC.swift
```swift
import UIKit
import SwiftUI

// MARK: - HostingController
final class NumbersSwiftUIViewContainerVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureHostingVC()
    }
    
    fileprivate func configureHostingVC() {
        let hostingVC = UIHostingController(rootView: NumbersView())
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(hostingVC)
        self.view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

/*
 uikit은 메모리 참조방식
 swiftui는 뷰를 재생성하는 방식(계속 복사생성)
 */
struct NumbersView: View {
    
    @State private var input: String = ""
    var body: some View {
        VStack(alignment: .trailing) {
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Divider()
            Text("합계")
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow)
    }
}

#Preview {
    NumbersView()
}
```

#### ViewController
```swift
import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {

    // Combine의 구독을 저장하는 Set
    // VC가 해제되면 subscriptions 프로퍼티도 함께 메모리에서 해제되고, 그 안에 저장된 구독들도 함께 해제되어 메모리 누수를 방지한다
    // 구독 찌꺼기 담는 통: VC가 메모리에서 해제되면 VC에서 사용된 구독 찌꺼기가 담긴다
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var navToNumbersBtn: UIButton!
    @IBOutlet weak var navToNumberSwiftUIBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navToNumbersBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = NumbersViewController.instantiate("Numbers")
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
        
        navToNumberSwiftUIBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = NumbersSwiftUIViewContainerVC()
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
    }
}
```

---

### 9. 제네릭으로 리팩토링
- 위 코드로 사용을 해도 되지만, 매번 ContainerVC를 만들어야해서 이 불편함을 해결하기 위해   
  제네릭으로 변환해보자

#### NumbersSwiftUIContainerVC -> SwiftUIContainerVC.swift
```swift
import UIKit
import SwiftUI

// MARK: - HostingController
final class SwiftUIViewContainerVC<SwiftUIView: View>: UIViewController {
    
    let swiftUIView: SwiftUIView
    
    init(swiftUIView: SwiftUIView) {
        self.swiftUIView = swiftUIView
        
        // UIViewController를 상속받기 때문에 부모의 viewController생성자를 호출해줘야한다
        super.init(nibName: nil, bundle: nil)
    }
    
    // 코드베이스 구현시 필요
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureHostingVC()
    }
    
    fileprivate func configureHostingVC() {
        let hostingVC = UIHostingController(rootView: swiftUIView)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(hostingVC)
        self.view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

/*
 uikit은 메모리 참조방식
 swiftui는 뷰를 재생성하는 방식(계속 복사생성)
 */
struct NumbersView: View {
    
    @State private var input: String = ""
    var body: some View {
        VStack(alignment: .trailing) {
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Divider()
            Text("합계")
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow)
    }
}

#Preview {
    NumbersView()
}
```

#### ViewController
```swift
import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {

    // Combine의 구독을 저장하는 Set
    // VC가 해제되면 subscriptions 프로퍼티도 함께 메모리에서 해제되고, 그 안에 저장된 구독들도 함께 해제되어 메모리 누수를 방지한다
    // 구독 찌꺼기 담는 통: VC가 메모리에서 해제되면 VC에서 사용된 구독 찌꺼기가 담긴다
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var navToNumbersBtn: UIButton!
    @IBOutlet weak var navToNumberSwiftUIBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navToNumbersBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = NumbersViewController.instantiate("Numbers")
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
        
        navToNumberSwiftUIBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = SwiftUIViewContainerVC(swiftUIView: NumbersView())
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
    }
}
```

--- 


#### 10. 제네릭 코드를 추가 리팩토링
- SwiftUIView를 가지고 있으니 Static 메서드로 뺼 수 있을 것 같다.

#### View+.swift
```swift
import SwiftUI

extension View {
    // self는 View view 프로토콜 타입 자체를 의미한다. 그런데 View는 프로토콜이기 때문에 구체적인 인스턴스를 알 수 없고 self를 View 인스턴스로 사용할 수 없다.
    // 또한 static은 탕비 메서드이기 때문에 타입 자체에서 호출되며 구체적인 인스턴스를 만들지 못한다.
    // 하지만 SwiftUIViewContainerVC는 생성자에서 View 인스턴스를 요구하기 때문에 타입만으로 만들 수 없다.
    // 즉 self가 NumberView인스턴스가 되어야 한다
    // 이미 생성이 됬을테니 static를뺸다
    func getContainerVC() -> UIViewController {
        return SwiftUIViewContainerVC(swiftUIView: self)
    }
}
```

#### SwiftUIContainerVC.swift
```swift
import UIKit
import SwiftUI

// MARK: - HostingController
final class SwiftUIViewContainerVC<SwiftUIView: View>: UIViewController {
    
    let swiftUIView: SwiftUIView
    
    init(swiftUIView: SwiftUIView) {
        self.swiftUIView = swiftUIView
        
        // UIViewController를 상속받기 때문에 부모의 viewController생성자를 호출해줘야한다
        super.init(nibName: nil, bundle: nil)
    }
    
    // 코드베이스 구현시 필요
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureHostingVC()
    }
    
    fileprivate func configureHostingVC() {
        let hostingVC = UIHostingController(rootView: swiftUIView)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(hostingVC)
        self.view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

/*
 uikit은 메모리 참조방식
 swiftui는 뷰를 재생성하는 방식(계속 복사생성)
 */
struct NumbersView: View {
    
    @State private var input: String = ""
    var body: some View {
        VStack(alignment: .trailing) {
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Divider()
            Text("합계")
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow)
    }
}

struct TestView: View {
    var body: some View {
        VStack {

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.purple)
    }
}

#Preview {
    NumbersView()
}
```

#### ViewController.swift
```swift
import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {

    // Combine의 구독을 저장하는 Set
    // VC가 해제되면 subscriptions 프로퍼티도 함께 메모리에서 해제되고, 그 안에 저장된 구독들도 함께 해제되어 메모리 누수를 방지한다
    // 구독 찌꺼기 담는 통: VC가 메모리에서 해제되면 VC에서 사용된 구독 찌꺼기가 담긴다
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var navToNumbersBtn: UIButton!
    @IBOutlet weak var navToNumberSwiftUIBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navToNumbersBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = NumbersViewController.instantiate("Numbers")
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
        
        navToNumberSwiftUIBtn
            .tapPublisher
            .sink(receiveValue: {
                print(#fileID, #function, #line, "- ")

                let numbersVC = NumbersView().getContainerVC()
                self.navigationController?.pushViewController(numbersVC, animated: true)
                
                /*
                let testVC = TestView().getContainerVC()
                self.navigationController?.pushViewController(testVC, animated: true)
                 */
                
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
    }
}
```