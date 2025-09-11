---
title: "[CustomView] 3. 컨테이너뷰 & 코드로 만들어보기"
tags:
- "CustomView"
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

# ContainerView
컨테이너뷰는 뷰컨트롤러를 화면에 넣은 것이다.  
이번에는 코드기반으로 구현을 해보자.
[공식문서](https://developer.apple.com/documentation/uikit/creating-a-custom-container-view-controller)
<br/><br/><br/><br/>



# 코드로 구현하기
<img src="{{ '/assets/img/2025-09-11-CustomView]-customView3/image-20250911144836289.png' | relative_url }}" alt="이미지" width="60%"> 
이전 포스팅에서 사용한 스토리보드에 추가적으로 민트색 UIView를 추가하였다.    
민트색을 지정하고, 상단 회색 UIView로 드래그하여 leading, trailing, height,vertical spacing을 설정하였다.

```sswift
import UIKit

final class CodeParentViewController: UIViewController {
    
    @IBOutlet weak var mintChildContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print(#fileID, #function, #line, "- ")
        configureChildContaianerView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
    }
    
    private func configureChildContaianerView() {
        let storyboard = UIStoryboard(name: "CodeContainer", bundle: .main)
        
        // MARK: - ChildVC라는 이름을 가진 녀석의 타입이 ChildVC라면 가져와러
        if let childVC = storyboard.instantiateViewController(identifier: "CodeChildViewController")
            as? CodeChildViewController {
            
            // MARK: - 이벤트 추가 가능(스토리보드 방식과 동일)
            childVC.placeHolder = "테스트"
            childVC.titleText = "코드로 만들었습니다."
            childVC.onBtnAClicked = {
                print(#fileID, #function, #line, "- 버튼 A 클릭")
            }
            
            childVC.onBtnBClicked = { input in
                print(#fileID, #function, #line, "- 버튼 B 클릭: \(input)")
            }
            childVC.onUserInputChanged = { input in
                print(#fileID, #function, #line, "- 입력됨: \(input)")
            }
            
            addChild(childVC)             // 뷰컨 자식으로 넣기
            view.addSubview(childVC.view) // 내가 가진 뷰에 뷰를 추가(뷰끼리 넣어주기)
            
            // MARK: - AutoLayout
            childVC.view.translatesAutoresizingMaskIntoConstraints = false
            let childVCConstraints = [
                childVC.view.topAnchor.constraint(equalTo: self.mintChildContainerView.topAnchor),
                childVC.view.bottomAnchor.constraint(equalTo: self.mintChildContainerView.bottomAnchor),
                childVC.view.leadingAnchor.constraint(equalTo: self.mintChildContainerView.leadingAnchor),
                childVC.view.trailingAnchor.constraint(equalTo: self.mintChildContainerView.trailingAnchor),
            ]
            
                                                                   
            NSLayoutConstraint.activate(childVCConstraints )
            
            // 자식뷰가 들어왔다고 알려주기
            childVC.didMove(toParent: self)
        }
    }
    
    /*
    private func configureChildContaianerViewWidhCreatorBlock() {
        let storyboard = UIStoryboard(name: "CodeContainer", bundle: .main)
        
        // MARK: - ChildVC라는 이름을 가진 녀석의 타입이 ChildVC라면 가져와러
        if let childVC = storyboard.instantiateViewController(identifier: "CodeChildViewController", creator: { coder in
            return CodeChildViewController(coder: coder,
                                           titleText: "테스트",
                                           placeholder: "테스트2",
                                           onBtnAClicked: self.handleAtnAClicked,
                                           onBtnBClicked: self.handleBtnAClicked,
                                           onUserInputChanged: self.handleInputFromChildVC
            )
        }) as? CodeChildViewController {
            
            // MARK: - 이벤트 추가 가능(스토리보드 방식과 동일)
            childVC.placeHolder = "테스트"
            childVC.titleText = "코드로 만들었습니다."
            childVC.onBtnAClicked = {
                print(#fileID, #function, #line, "- 버튼 A 클릭")
            }
            
            childVC.onBtnBClicked = { input in
                print(#fileID, #function, #line, "- 버튼 B 클릭: \(input)")
            }
            childVC.onUserInputChanged = { input in
                print(#fileID, #function, #line, "- 입력됨: \(input)")
            }
            
            addChild(childVC)             // 뷰컨 자식으로 넣기
            view.addSubview(childVC.view) // 내가 가진 뷰에 뷰를 추가(뷰끼리 넣어주기)
            
            // MARK: - AutoLayout
            childVC.view.translatesAutoresizingMaskIntoConstraints = false
            let childVCConstraints = [
                childVC.view.topAnchor.constraint(equalTo: self.mintChildContainerView.topAnchor),
                childVC.view.bottomAnchor.constraint(equalTo: self.mintChildContainerView.bottomAnchor),
                childVC.view.leadingAnchor.constraint(equalTo: self.mintChildContainerView.leadingAnchor),
                childVC.view.trailingAnchor.constraint(equalTo: self.mintChildContainerView.trailingAnchor),
            ]
            
                                                                   
            NSLayoutConstraint.activate(childVCConstraints )
            
            // 자식뷰가 들어왔다고 알려주기
            childVC.didMove(toParent: self)
        }
    }
     */
    
    
    private func handleAtnAClicked() {
        
    }
    
    private func handleBtnAClicked(_ input: String) {
        
    }
    
    private func handleInputFromChildVC(_ input: String) {
        
    }
}
```


```swift
import UIKit

final class CodeChildViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    var onBtnAClicked: (() -> Void)? = nil            // A버튼 클릭 이벤트
    var onBtnBClicked: ((String) -> Void)? = nil      // B버튼 클릭 이벤트
    var onUserInputChanged: ((String) -> Void)? = nil // 글자 입력시 이벤트
    
    // @IBInspectable: Interface Builder에서 속성을 넣어주는 역할
    // 프로퍼티 옵저버
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
                self.inputTextField.placeholder = self.placeHolder.isEmpty ? "글자를 입력해주세요" : self.placeHolder
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
    
    // MARK: - creator를 이용한 생성자 주입방식
//    init?(coder: NSCoder,
//          titleText: String,
//          placeholder: String,
//          onBtnAClicked: (() -> Void)? = nil,
//          onBtnBClicked: ((String) -> Void)? = nil,
//          onUserInputChanged: ((String) -> Void)? = nil
//    ) {
//        self.titleText = titleText
//        self.placeHolder = placeholder
//        self.onBtnAClicked = onBtnAClicked
//        self.onBtnBClicked = onBtnBClicked
//        self.onUserInputChanged = onUserInputChanged
//        super.init(coder: coder)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print(#fileID, #function, #line, "- ")
        
        inputTextField.addTarget(self, action: #selector(onUserInputChanged(_:)), for: .editingChanged)
    }
    
    // MARK: - 버튼 이벤트
    /// 스토리보드에서 태그 설정해두면 이 메서드 하나로 여러 버튼 연결해서 분기 가능
    @IBAction func onBtcClicked(_ sender: UIButton) {
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
    
    // MARK: - 텍스트필드 입력시 이벤트
    @objc private func onUserInputChanged(_ sender: UITextField) {
        print(#fileID, #function, #line, "- sender.text: \(sender.text!)")
        self.onUserInputChanged?(sender.text ?? "")
    }
    
}
```

# Reference
- [공식문서](https://developer.apple.com/documentation/uikit/creating-a-custom-container-view-controller)