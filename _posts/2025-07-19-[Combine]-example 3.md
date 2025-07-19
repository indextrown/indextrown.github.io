---
title: "[Combine] 예제 3 & UIKit Validation"
tags: 
- Combine
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-07-19-[Combine]-example 3/image-20250719142349430.png' | relative_url }}" alt="커스텀셀1" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-07-19-[Combine]-example 3/image-20250719142401972.png' | relative_url }}" alt="커스텀셀" width="100%"></td>
      <!-- <td><img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView5/image-20250511181826302.png' | relative_url }}" alt="커스텀셀" width="100%"></td> -->
  </tr>
  <tr>
    <td style="text-align:center;">Main.storyboard</td>
    <td style="text-align:center;">ValidationViewController.swift/storyboard</td>
    <!-- <td style="text-align:center;">Code 커스텀 셀</td> -->
  </tr>
</table>


#### 1. Main.storyboard에 연결된 ViewController.swift
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
    @IBOutlet weak var navToValidationUIKitBtn: UIButton!
    
    
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
        
        navToValidationUIKitBtn
            .tapPublisher
            .sink(receiveValue: {
                let vc = ValidationExampleViewController(nibName: "ValidationExampleViewController", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            // 구독에 대한 찌꺼기가 담긴다
            .store(in: &subscriptions)
    }
}
```

#### 2. ValidationViewController.storyboard에 연결된 ValidationViewController.swift
```swift
import UIKit

class ValidationExampleViewController: UIViewController {

    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userNameValidationLabel: UILabel!
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
     
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```

#### 3. ValidationVC를 편하게 만드는 헬퍼메스드 구현

#### ValidationExampleViewController.swift
```swift
import UIKit

class ValidationExampleViewController: UIViewController {

    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userNameValidationLabel: UILabel!
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
     
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Helper Method
    // validationExampleVC를 생성하지 않고 만들어주는 역할 - 타입메서드
    class func getInstance() -> ValidationExampleViewController { // MARK: - 상속을 고료하지 않는 경우면 static func
        ValidationExampleViewController(nibName: "ValidationExampleViewController", bundle: nil)
    }
}

// MARK: - 조금 더 제네릭하게 한다면
extension UIViewController {/// nib 파일 이름이 클래스명과 동일할 때 해당 ViewController 인스턴스를 생성합니다.
    ///
    /// - Returns: nibName과 동일한 이름의 UIViewController 인스턴스
    /// - Example:
    /// ```swift
    /// let vc = MyViewController.instantiateFromNib()
    /// ```
    ///Self: 호출하는 타입 자신 (예: MyViewController)
    /// String(describing: Self.self): "MyViewController" → nib 파일 이름과 일치
    static func instantiateFromNib() -> Self {
        return Self(nibName: String(describing: Self.self), bundle: nil)
    }
}
```

#### ViewController
```swift
navToValidationUIKitBtn
    .tapPublisher
    .sink(receiveValue: {
        
        // 원래 방식
        // let vc = ValidationExampleViewController(nibName: "ValidationExampleViewController", bundle: nil)
        
        // Helper Method 방식
        // let vc = ValidationExampleViewController.getInstance()
        
        // Helper Method2 방식
        let vc = ValidationExampleViewController.instantiateFromNib()
        self.navigationController?.pushViewController(vc, animated: true)
    })
    // 구독에 대한 찌꺼기가 담긴다
    .store(in: &subscriptions)
```

#### 3. ViewController.swift에서 버튼 추가시마다 Outlet 연결을 해야하는데 불편하다
- 매번 Outlet 연결 및 tapPublisher연결을 편리하게 만드는법으로 수정해보자

1. 기존 Main.storyboard에서 Stack내부의 버튼을 지운다
2. 크기아 없어도 상관없다. 아이템을 넣어서 크기를 만들거다
3. stackView를 View로 감쌌는데 스택뷰를 밖으로 빼고 view를 지운다
4. StackView를 Frame Layout에 드래그하고 exuql width 설정해준다
5. Inspector에서 multiplier를 1로 해준다
6. stackView를 ViewController로 가져온다



<img src="{{ '/assets/img/2025-07-19-[Combine]-example 3/image-20250719153121655.png' | relative_url }}" alt="이미지" width="100%">

```swift
import UIKit
import Combine
import CombineCocoa

enum ExampleType: Int, CaseIterable {
    case numbersUIKit    // rawValue: 0
    case numbersSwiftUI  // 1
    case validationUIKit // 2
    
    func makeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.setTitle(String(describing: self), for: .normal)
        button.tag = self.rawValue
        return button
    }
    
    func makeVC() -> UIViewController {
        switch self {
        case .numbersUIKit:
            NumbersViewController.instantiate("Numbers")
        case .numbersSwiftUI:
            NumbersView().getContainerVC()
        case .validationUIKit:
            ValidationExampleViewController.instantiateFromNib()
        }
    }
}

class ViewController: UIViewController {

    // Combine의 구독을 저장하는 Set
    // VC가 해제되면 subscriptions 프로퍼티도 함께 메모리에서 해제되고, 그 안에 저장된 구독들도 함께 해제되어 메모리 누수를 방지한다
    // 구독 찌꺼기 담는 통: VC가 메모리에서 해제되면 VC에서 사용된 구독 찌꺼기가 담긴다
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var buttonContainerStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exampleTypes: [ExampleType] = ExampleType.allCases
        
        exampleTypes.forEach { aType in
            let button = aType.makeButton()
            button
                .tapPublisher
                .sink(receiveValue: { [weak self] in // 클로저 내에서 self를 사용하니까 강한참조를 뺴기 위해 캡처리스트로 약하게 해준다
                    // 각 타입마다 뷰컨트롤러 종류가 다르다(storyboard, swiftUI, xib)
                    guard let self = self else { return }
                    let vc = aType.makeVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                .store(in: &subscriptions)
            
            buttonContainerStackView.addArrangedSubview(button)
        }
    }
}
```





<img src="{{ '/assets/img/2025-07-19-[Combine]-example 3/image-20250719153211663.png' | relative_url }}" alt="이미지" width="85%">

