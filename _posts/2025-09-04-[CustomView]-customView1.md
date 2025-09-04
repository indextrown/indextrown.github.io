---
title: "[CustomView] 1. 커스텀뷰 만들기"
tags:
- 
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

## 커스텀뷰 만들기
<img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904153909426.png' | relative_url }}" alt="이미지" width="30%">
우선 Storyboard에서 사진 처럼 UI를 만든다. Button을 hstack으로 묶고, label, textfield, hstack을 vstack으로 묶는다. 그리고 view를 embed하고 색성을 주고, vstack을 view로 드래그하여 상하좌우 전부 10씩 공간을 주고, 이 view를 safearea top: 10, leading: 10, horizontal center 설정을 해주었다.

그리고 이 화면을 복사하고 empty라는 파일을 만들어서 파일이름을 InputView로 하고 여기에 붙여넣는다 이 파일을 nib 파일(인터페이스 빌더)이라고 부른다.

<img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904154758361.png' | relative_url }}" alt="이미지" width="30%">

<img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904155040418.png' | relative_url }}" alt="이미지" width="30%">

그럼 InputView에서 이렇게 깨지는데 사이즈 인스펙터(삼각형) 부분에서 Layout Guides에서 Safe area 제거한다. 그리고 View를 누르고 attribute(삼각형 바로 왼쪽) 눌러서 Size를 Inferred에서 Freform으로 바꾼다. 그러면 사이즈를 편하게 조절할 수 있다.

<img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904155715893.png' | relative_url }}" alt="이미지" width="70%">
file owner에서 코드 클래스를 연결한다.

```swift
// 코드 클래스
import UIKit

class InputView: UIView {
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
}
```


<img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904160046690.png' | relative_url }}" alt="이미지" width="30%">
View를 생성후 노란색 View에 드래그해서 Vertical Spacing, Leading, Trailing, Equal Height 설정을 해준다.  

<img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904160335271.png' | relative_url }}" alt="이미지" width="30%">
새로 만든 뷰를 SecondInputView로 하고 option + cmd + 4하고 class를 InputView로 해준다.
그리고 실행해보면 아래 awakefromnib은 탔다고 로그가 뜨지만 우리가 원하는 Nib파일과의 연결이 안되서 여전히 민트색으로 나온다. 
이를 해결해보자.



<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904161610102.png' | relative_url }}" alt="Before" width="90%"></td>
    <td><img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904162604822.png' | relative_url }}" alt="After" width="80%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">Before</td>
    <td style="text-align:center;">After(applyNib 생성/호출)</td>
  </tr>
</table>
```swift
// 로그
SwiftUILab/InputView.swift init(coder:) 26 - 
SwiftUILab/InputView.swift awakeFromNib() 15 - 
```

```swift
import UIKit
 
class InputView: UIView {
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
        applyNib()
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        print(#fileID, #function, #line, "- ")
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
    
    fileprivate func applyNib() {
        print(#fileID, #function, #line, "- ")
        let nibName = String(describing: Self.self)     // 나의 타입을 가져온다 "InputView"
        let nib = Bundle.main.loadNibNamed(nibName, owner: self)  // Bundle에서 Nib파일을 불러오겠다, 주인은 self
        
        // nib의 첫 요소를 UIView 형태로 가져오겠다
        guard let view = nib?.first as? UIView else { return }
        
        // autoLauout
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}

```







## 추가: 라벨, 버튼, 텍스트필드 각각 커스텀하고싶다면
각각 Nib에서 InputView 코드로 드래그해주고 커스텀을 하면되는데, 코드로 해도 되지만 
@IBInspactable를 활용하면 Interface Builder에서 편하게 수정할 수 있다.
수정은 Main 즉 호출쪽에서 UserDefined Runtime Attributes에서 넣어주면 된다.


<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904164204030.png' | relative_url }}" alt="Before" width="80%"></td>
    <td><img src="{{ '/assets/img/2025-09-04-[CustomView]-customView1/image-20250904164312431.png' | relative_url }}" alt="After" width="80%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">파란칸 작성</td>
    <td style="text-align:center;">실행 화면</td>
  </tr>
</table>

```swift
import UIKit
 
class InputView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var buttonA: UIButton!
    
    @IBOutlet weak var buttonB: UIButton!
    
    // @IBInspectable: Interface Builder에서 속성을 넣어주는 역할
    // 프로퍼티 옵저버
    @IBInspectable
    var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요" : self.placeHolder
            }
        }
    }
    
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
        applyNib()
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        print(#fileID, #function, #line, "- ")
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
    
    fileprivate func applyNib() {
        print(#fileID, #function, #line, "- ")
        let nibName = String(describing: Self.self)     // 나의 타입을 가져온다 "InputView"
        let nib = Bundle.main.loadNibNamed(nibName, owner: self)  // Bundle에서 Nib파일을 불러오겠다, 주인은 self
        
        // nib의 첫 요소를 UIView 형태로 가져오겠다
        guard let view = nib?.first as? UIView else { return }
        
        // autoLauout
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
```


## 코드로 UI 만드는법
```swift
import UIKit

class CustomStoryboardViewController: UIViewController {
    
    @IBOutlet weak var secondInputView: InputView!
    
    override func loadView() {
        super.loadView()
        print(#fileID, #function, #line, "- ")
        let thirdInputView = InputView(title: "편의생성자 타이틀", placeHolder: "편의생성자 홀더")
        thirdInputView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(thirdInputView)
        NSLayoutConstraint.activate([
            thirdInputView.topAnchor.constraint(equalTo: secondInputView.bottomAnchor, constant: 10),
            thirdInputView.leadingAnchor.constraint(equalTo: secondInputView.leadingAnchor),
            thirdInputView.trailingAnchor.constraint(equalTo: secondInputView.trailingAnchor),
            thirdInputView.heightAnchor.constraint(equalTo: secondInputView.heightAnchor)
        ])
    }
    
    override func viewDidLoad() {
        
    }
}

```

```swift 
// override init(frame: CGRect)에 applyNib 호출 추가, 편의생성자 추가하여 뷰 생성시 title, placeHolder 파라미터 받기
import UIKit
 
class InputView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var buttonA: UIButton!
    
    @IBOutlet weak var buttonB: UIButton!
    
    // @IBInspectable: Interface Builder에서 속성을 넣어주는 역할
    // 프로퍼티 옵저버
    @IBInspectable
    var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요" : self.placeHolder
            }
        }
    }
    
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
        applyNib()
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
        applyNib() // MARK: - 이거 추가
    }
    
    // MARK: - 편의생성자 추가
    convenience init(title: String = "", placeHolder: String) {
        self.init(frame: .zero)
        self.titleLabel.text = title
        self.inputTextField.placeholder = placeHolder
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        print(#fileID, #function, #line, "- ")
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
    
    fileprivate func applyNib() {
        print(#fileID, #function, #line, "- ")
        let nibName = String(describing: Self.self)     // 나의 타입을 가져온다 "InputView"
        let nib = Bundle.main.loadNibNamed(nibName, owner: self)  // Bundle에서 Nib파일을 불러오겠다, 주인은 self
        
        // nib의 첫 요소를 UIView 형태로 가져오겠다
        guard let view = nib?.first as? UIView else { return }
        
        // autoLauout
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
```

## 버튼 연결 추가법
applyNib 메서드를 추가하면된다.
```swift
import UIKit
 
class InputView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var buttonA: UIButton!
    
    @IBOutlet weak var buttonB: UIButton!
    
    // @IBInspectable: Interface Builder에서 속성을 넣어주는 역할
    // 프로퍼티 옵저버
    @IBInspectable
    var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요" : self.placeHolder
            }
        }
    }
    
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
        applyNib()
        applyAction()
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
        applyNib() // MARK: - 이거 추가
        applyAction()
    }
    
    // MARK: - 편의생성자 추가
    convenience init(title: String = "", placeHolder: String) {
        self.init(frame: .zero)
        self.titleLabel.text = title
        self.inputTextField.placeholder = placeHolder
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        print(#fileID, #function, #line, "- ")
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
    
    fileprivate func applyNib() {
        print(#fileID, #function, #line, "- ")
        let nibName = String(describing: Self.self)     // 나의 타입을 가져온다 "InputView"
        let nib = Bundle.main.loadNibNamed(nibName, owner: self)  // Bundle에서 Nib파일을 불러오겠다, 주인은 self
        
        // nib의 첫 요소를 UIView 형태로 가져오겠다
        guard let view = nib?.first as? UIView else { return }
        
        // autoLauout
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    fileprivate func applyAction() {
        print(#fileID, #function, #line, "- ")
        self.buttonA.addTarget(self, action: #selector(onBtnAClicked(selder:)), for: .touchUpInside)
        self.buttonB.addTarget(self, action: #selector(onBtnBClicked(selder:)), for: .touchUpInside)
    }
}

extension InputView {
    @objc func onBtnAClicked(selder: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    @objc func onBtnBClicked(selder: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
}
```

## 텍스트필드 연결 추가법
```swift
import UIKit
 
class InputView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var buttonA: UIButton!
    
    @IBOutlet weak var buttonB: UIButton!
    
    // @IBInspectable: Interface Builder에서 속성을 넣어주는 역할
    // 프로퍼티 옵저버
    @IBInspectable
    var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요" : self.placeHolder
            }
        }
    }
    
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
        applyNib()
        applyAction()
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
        applyNib() // MARK: - 이거 추가
        applyAction()
    }
    
    // MARK: - 편의생성자 추가
    convenience init(title: String = "", placeHolder: String) {
        self.init(frame: .zero)
        self.titleLabel.text = title
        self.inputTextField.placeholder = placeHolder
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        print(#fileID, #function, #line, "- ")
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
    
    fileprivate func applyNib() {
        print(#fileID, #function, #line, "- ")
        let nibName = String(describing: Self.self)     // 나의 타입을 가져온다 "InputView"
        let nib = Bundle.main.loadNibNamed(nibName, owner: self)  // Bundle에서 Nib파일을 불러오겠다, 주인은 self
        
        // nib의 첫 요소를 UIView 형태로 가져오겠다
        guard let view = nib?.first as? UIView else { return }
        
        // autoLauout
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    fileprivate func applyAction() {
        print(#fileID, #function, #line, "- ")
        self.buttonA.addTarget(self, action: #selector(onBtnAClicked(selder:)), for: .touchUpInside)
        self.buttonB.addTarget(self, action: #selector(onBtnBClicked(selder:)), for: .touchUpInside)
        self.inputTextField.addTarget(self, action: #selector(onInputChanged(sender: )), for: .editingChanged)
    }
}

extension InputView {
    @objc func onBtnAClicked(selder: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    @objc func onBtnBClicked(selder: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    // MARK: - 텍스트필드 이벤트 받는법 delegate도 되지만 간단하게 selector로도 된다
    @objc func onInputChanged(sender: UITextField) {
        print(#fileID, #function, #line, "- input: \(sender.text!)")
    }
}
```


## 액션을 viewController에서 받고 싶다
- 클로저를 활용하자.
- 클로저는 정의, 할당, 호출 3가지를 기억하면 된다.

```swift
//
//  InputView.swift
//  SwiftUILab
//
//  Created by 김동현 on 9/4/25.
//

import UIKit
 
class InputView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var buttonA: UIButton!
    
    @IBOutlet weak var buttonB: UIButton!
    
    var onBtnAClicked: (() -> Void)? = nil
    var onBtnBClicked: ((String) -> Void)? = nil
    
    // @IBInspectable: Interface Builder에서 속성을 넣어주는 역할
    // 프로퍼티 옵저버
    @IBInspectable
    var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요" : self.placeHolder
            }
        }
    }
    
    /// 인터페이스 빌더로 생성이되는 생성자(nib == interfacebuilder)
    /// 스토리보드나 Nib을 통해 생성되면 이걸 사용한다
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
        applyNib()
        applyAction()
    }
    
    /// 코드로 InputView를 생성한다면 사용하는 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
        applyNib() // MARK: - 이거 추가
        applyAction()
    }
    
    // MARK: - 편의생성자 추가
    convenience init(title: String = "", placeHolder: String) {
        self.init(frame: .zero)
        self.titleLabel.text = title
        self.inputTextField.placeholder = placeHolder
    }
    
    // MARK: - 버튼 세번째 방식
    convenience init(title: String = "",
                     placeHolder: String,
                     onBtnAClicked: (() -> Void)? = nil,
                     onBtnBClicked: ((String) -> Void)? = nil
    ) {
        self.init(frame: .zero)
        self.titleLabel.text = title
        self.inputTextField.placeholder = placeHolder
        
        self.onBtnAClicked = onBtnAClicked
        self.onBtnBClicked = onBtnBClicked
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder) // 스토리보드용
        print(#fileID, #function, #line, "- ")
        /// fatalError("init(coder:) has not been implemented") // 코드용
    }
    
    fileprivate func applyNib() {
        print(#fileID, #function, #line, "- ")
        let nibName = String(describing: Self.self)     // 나의 타입을 가져온다 "InputView"
        let nib = Bundle.main.loadNibNamed(nibName, owner: self)  // Bundle에서 Nib파일을 불러오겠다, 주인은 self
        
        // nib의 첫 요소를 UIView 형태로 가져오겠다
        guard let view = nib?.first as? UIView else { return }
        
        // autoLauout
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    fileprivate func applyAction() {
        print(#fileID, #function, #line, "- ")
        self.buttonA.addTarget(self, action: #selector(onBtnAClicked(sender:)), for: .touchUpInside)
        self.buttonB.addTarget(self, action: #selector(onBtnBClicked(sender:)), for: .touchUpInside)
        self.inputTextField.addTarget(self, action: #selector(onInputChanged(sender: )), for: .editingChanged)
    }
    
   
    func resetAction(target: Any?,
                     aBtnAction: Selector,
                     bBtnAction: Selector,
                     inputChangeAction: Selector
    ) {
        // 이전 걸려있던 액션 지우기
        print(#fileID, #function, #line, "- ")
        self.buttonA.removeTarget(self, action: #selector(onBtnAClicked(sender:)), for: .touchUpInside)
        self.buttonB.removeTarget(self, action: #selector(onBtnBClicked(sender:)), for: .touchUpInside)
        self.inputTextField.removeTarget(self, action: #selector(onInputChanged(sender: )), for: .editingChanged)
        // 새 액션 넣기
        self.buttonA.addTarget(target, action: aBtnAction, for: .touchUpInside)
        self.buttonB.addTarget(target, action: bBtnAction, for: .touchUpInside)
        self.inputTextField.addTarget(target, action: inputChangeAction, for: .editingChanged)
    }
}

extension InputView {
    @objc func onBtnAClicked(sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        onBtnAClicked?()
    }
    
    @objc func onBtnBClicked(sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        guard let userInput = self.inputTextField.text else { return }
        onBtnBClicked?(userInput)
    }
    
    // MARK: - 텍스트필드 이벤트 받는법 delegate도 되지만 간단하게 selector로도 된다
    @objc func onInputChanged(sender: UITextField) {
        print(#fileID, #function, #line, "- input: \(sender.text!)")
    }
}
```

```swift
import UIKit

class CustomStoryboardViewController: UIViewController {
    
    @IBOutlet weak var secondInputView: InputView!
    
    override func loadView() {
        super.loadView()
        print(#fileID, #function, #line, "- ")
        // let thirdInputView = InputView(title: "편의생성자 타이틀", placeHolder: "편의생성자 홀더")
        
        // MARK: - 4번 방식(생성자로 버튼 등록)
        let thirdInputView = InputView(title: "편의생성자 타이틀",
                                       placeHolder: "편의생성자 홀더",
                                       onBtnAClicked: { self.handleBtnACLicked() },
                                       onBtnBClicked: { self.handleBtnBClicked(userInput: $0) })
        
        
        thirdInputView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(thirdInputView)
        NSLayoutConstraint.activate([
            thirdInputView.topAnchor.constraint(equalTo: secondInputView.bottomAnchor, constant: 10),
            thirdInputView.leadingAnchor.constraint(equalTo: secondInputView.leadingAnchor),
            thirdInputView.trailingAnchor.constraint(equalTo: secondInputView.trailingAnchor),
            thirdInputView.heightAnchor.constraint(equalTo: secondInputView.heightAnchor)
        ])
    }
    
    override func viewDidLoad() {
        
        // MARK: - 1번 방식(클로저로 버튼 등록)
        secondInputView.onBtnAClicked = {
            print("onBtnAClicked 실행됨")
        }
        
        // MARK: - 2번 방식(클로저로 버튼 등록 + 클로저 파라미터 활용)
        secondInputView.onBtnBClicked = {
            print("onBtnBClicked 실행됨 / userInput: \($0)")
        }
        
        // MARK: - 3번 방식(메서드로 버튼 등록)
        // 핸들링을 InputView가 아닌 VC에서 가능해진다
        secondInputView.resetAction(target: self,
                                    aBtnAction: #selector(onBtnAClicked(sender: )),
                                    bBtnAction: #selector(onBtnBClicked(sender: )),
                                    inputChangeAction: #selector(onInputChanged(sender: )))
    }
}


extension CustomStoryboardViewController {
    @objc func onBtnAClicked(sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    @objc func onBtnBClicked(sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    // MARK: - 텍스트필드 이벤트 받는법 delegate도 되지만 간단하게 selector로도 된다
    @objc func onInputChanged(sender: UITextField) {
        print(#fileID, #function, #line, "- input: \(sender.text!)")
    }
}

extension CustomStoryboardViewController {
    private func handleBtnACLicked() {
        print("onBtnAClicked")
    }
    
    private func handleBtnBClicked(userInput: String) {
        print("onBtnBClicked")
        print("onBtnBClicked!!!: \(userInput)")
    }
}
```

## 정리
- UIKit으로 커스텀 뷰 만들 때 컴포넌트 단위로 구현하는게 편하다.
- 코드로만 만드는 방식도 있지만, 특정 부분을 Xib파일로 따로 빼서 구성할 수 있다,
  - 이떄는 연결을 View가 아니라 Files Owner에 원하는 UIView 클래스룰 연결해준다.
  - 해당하는 Nib파일을 가져와서 Nib파일의 첫번째 뷰를 UIView 타입으로 가져오고 오토레이아웃을 한번 잡아준다.

- Main 스토리보드에서 UIView를 클래스 이름 연결하면 awakeFromNib을 탄다.
  - 커스텀으로 속성 변경할거면 @IBInspactable를 사용하면 된다.

- Xib파일을 코드로 생성할때는 init(frame)을 탄다
  - 커스텀 속성을 넣고싶으면 convenience init을 통해 매개변수를 넣어서 해결하면 된다.