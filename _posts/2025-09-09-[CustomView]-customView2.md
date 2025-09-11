---
title: "[CustomView] 2. 컨테이너뷰 & 스토리보드로 만들어보기"
tags:
- "CustomView"
header:
  teaser:
typora-root-url: ../
---
<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

# ContainerView

<img src="{{ 'https://docs-assets.developer.apple.com/published/31b57b164fcd77f6c82549528d86339e/media-3375406%402x.png' | relative_url }}" alt="이미지" width="60%">
[공식문서](https://developer.apple.com/documentation/uikit/creating-a-custom-container-view-controller)
UIView안에 ViewController가 들어간 것을 컨테이너뷰라고한다. 대표적인 예시가 NavigationController, TabBarController, PageViewController이다.   
컨테이너뷰는 다른 컨트롤러를 담아서 사용할 수 있다.
<br/><br/><br/><br/>

<img src="{{ 'https://docs-assets.developer.apple.com/published/e1ea2e4e04857d762d37bd948d9fb131/media-3376047%402x.png' | relative_url }}" alt="이미지" width="60%">
초록색 View에 ViewController가 들어있는 것이다. 문서에서 컨테이너 뷰 자체에 하위 뷰를 추가하지 말고 뷰 컨트롤러의 뷰에 추가하라고 한다. 세그웨이 방식으로 연결되어있기 때문에 prepare같은 델리게이트 함수도 사용할 수 있다.
<br/><br/><br/><br/>



# 스토리보드로 개발하기
```swift
final class ParentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

final class ChildViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
```
우선 스토리보드로 컨테이너뷰 만들기를 진행해보자. Container.storyboard, ParentVC, ChildVC 각각 만들어주자.
<br/><br/><br/><br/>




<img src="{{ '/assets/img/2025-09-09-[CustomView]-customView2/image-20250910232505762.png' | relative_url }}" alt="이미지" width="60%"> 
container.stoayboard에서 cmd + shift + l에서 container 검색해서 나오는 것을 화면에 두고, 오토레이아웃(leading, top, center horizontal, height) 설정을 해준다. 그러면 사진과 같은 화면이 생긴다. 화면의 일부분을 viewController로 사용하고 싶을 때 주로 사용한다.
<br/><br/><br/><br/>



<img src="{{ '/assets/img/2025-09-09-[CustomView]-customView2/image-20250910233556584.png' | relative_url }}" alt="이미지" width="60%"> 
기존 만들어둔 노란색 뷰를 작은 VireController로 드래그하여 가져오고, 상하좌우 공백 없이 레이아웃을 지정해준다.  Stack의 Distribution을 Fill Equally로 해주었다. 그리고 view, stackView 둘다 size inspector에서 Safe Area Relative Margins를 체크 해제하였다. 그리고 스택뷰의 size inspector에서 Layout Margins를 Language Directional을 클릭하여 마진을 각각 10씩 전부 지정하였다. 실행을 위해 큰화면은 ParentVC, 작은화면은 ChildVC를 연결하고, Container.storyboard에서는 Identifier를 ParentVC로 설정해준다. 
<br/><br/><br/><br/>




<img src="{{ '/assets/img/2025-09-09-[CustomView]-customView2/image-20250911000548093.png' | relative_url }}" alt="이미지" width="100%"> 
이제 버튼 이벤트 관련 로직을 추가해보자. Container 스토리보드에서 label, textField, 버튼을 드래그해서 ChildVC로 드래그하여 변수로 연결해준다. 버튼은 그냥 액션으로 하나의 액션으로 받되 태그로 구분하도록 하자. 클로저로 이벤트를 전달하는 방식의 장점은 VC에서는 버튼이 눌렸다는 사실만 알리고 어떤 동작을 할지는 외부에서 결정할 수 있다. 즉 뷰 컨트롤러 자체가 다른 계층(VM, ParentVC)에 덜 의존적으로 됨으로 재사용성이 증가하게 된다. 또한 Delegate 패턴처럼 프로토콜 정의, 채택, 함수 구현과정이 필요 없고 단순히 클로저 하나로 콜백을 전달할 수 있어서 코드가 간결하다. 또한 상황에 따라 다른 행동을 쉽게 지정할 수 있다. 마지막으로 클로저는 캡처방식을 잘쓰면 delegate보다 가볍게 관리되고 불필요한 Retain Cycle도 직접 관리할 수 있다. 하지만 이벤트가 많아지면 코드가 복잡해질 수 있어서 단순 이벤트는 클로저, 다수 이벤트나 복잡한 상호작용은 Delegate 패턴을 사용하는 것이 좋다. 
현재 코드에서 @IBInspectable을 사용했기 때문에 Interface Builder에서 title, placeholder를 변경할 수 있다.
<br/><br/><br/><br/>



```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let childVC = segue.destination as? ChildViewController {
        childVC.onUserInputChanged = { [weak self] input in
            guard let self = self else { return }
            print("입력을 할때 이벤트 발생: -\(input)")
        }
        
        childVC.onBtnAClicked = { [weak self] in
            guard let self = self else { return }
            print("버튼 A 이벤트 발생:")
        }
        
        childVC.onBtnBClicked = { [weak self] input in
            guard let self = self else { return }
            print("버튼 B 이벤트 발생: -\(input)")
        }
    }
}
```
이것도 Embed Segue라서 prepare함수가 동일하게 타는것을 알 수 있다. 도착하는 뷰컨트롤러가 ChildVC이므로 분기처리가 가능하다.


# 전체코드
<img src="{{ '/assets/img/2025-09-09-[CustomView]-customView2/image-20250911003024668.png' | relative_url }}" alt="이미지" width="50%"> 
```swift
import UIKit

final class ParentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let childVC = segue.destination as? ChildViewController {
            
            childVC.bgColor = .systemMint
            childVC.onUserInputChanged = { [weak self] input in
                guard let self = self else { return }
                print("입력을 할때 이벤트 발생: - \(input)")
            }
            
            childVC.onBtnAClicked = { [weak self] in
                guard let self = self else { return }
                print("버튼 A 이벤트 발생:")
            }
            
            childVC.onBtnBClicked = { [weak self] input in
                guard let self = self else { return }
                print("버튼 B 이벤트 발생: -\(input)")
            }
        }
    }
}
```
```swift
import UIKit

final class ChildViewController: UIViewController {
    
    // MARK: - 스토리보드 연결
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    // MARK: - 버튼 이벤트 클로저로 구현
    var onBtnAClicked: (() -> Void)? = nil              /// A 버튼 이벤트
    var onBtnBClicked: ((String) -> Void)? = nil        /// A 버튼 이벤트
    var onUserInputChanged: ((String) -> Void)? = nil   /// 입력 이벤트
    
    @IBInspectable
    var titleText: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.titleText
            }
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요!" : self.placeHolder
            }
        }
    }
    
    var bgColor: UIColor = .systemYellow {
        didSet {
            DispatchQueue.main.async {
                self.view.backgroundColor = self.bgColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // MARK: - AddTarget
        inputTextField.addTarget(self, action: #selector(onUserInputChanged(_:)), for: .editingChanged)
    }
     
    @IBAction func onBtnClicked(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("버튼 A 클릭")
            onBtnAClicked?()
        case 2:
            print("버튼 B 클릭")
            guard let input = inputTextField.text else { return }
            onBtnBClicked?(input)
        default: break
        }
    }
}

extension ChildViewController {
    @objc private func onUserInputChanged(_ sender: UITextField) {
        print(#fileID, #function, #line, "- \(sender.text ?? "")")
        guard let input = inputTextField.text else { return }
        onUserInputChanged?(input)
    }
} 
```

# Reference
- [공식문서](https://developer.apple.com/documentation/uikit/creating-a-custom-container-view-controller)