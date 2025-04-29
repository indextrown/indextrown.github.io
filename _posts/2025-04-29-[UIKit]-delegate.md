---
title: "[UIKit]-Delegate Paggern란?"
tags: 
- UIKit
header: 
  teaser: 
typora-root-url: ../
---

## 1. Delegate 조건
UIKit 클론코딩을 하다 보면 여러가지 상황에서 Delegate Protocol을 채택하고 Protocol 내부에서 제공하는 method를 사용하게 된다. UITextField, UITableView에서도 기능을 구현할 때 흔하게 사용되는 방식이다. Apple에서 우리가 유용하게 사용할 만한 기능들을 함수에 담아 미리 구현해두고 우리가 추가적인 코드를 작성함으로서 우리가 원하는 방식대로 앱이 동작하게 할 수 있다.

### Delegate Pattern 은 아래의 조건을 총족함으로서 사용할 수 있다.
### Delegate를 생성하는 뷰
1. Protocol을 생성하고, 구현하고 싶은 기능을 해당 Protocol의 메서드로 생성
2. Protocol을 Type으로 갖는 Delegate 인스턴스 생성
3. 생성한 method가 동작해야하는 상황에 코드 작성

### Delegate를 위임받는 뷰
1. ViewController에 Delegate Protocol을 채택
2. Protocol 필수 method 구현
3. Delegate 위임

## 2. 준비
### FirstViewController는 결과값을 표시할 Label, 두번째 Controller를 뛰울 Button
### SecondViewController는 결과값을 입력받을 TextField와 첫번째 Controller로 돌아갈 수 있는 Button을 배치

### FirstViewController
```swift
class FirstViewController: UIViewController {

    let label = UILabel()
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - UI
    private func configureUI() {
        view.backgroundColor = .white
        setAttributes()
        setContraints()
    }

    private func setAttributes() {
        label.text = "Sample Text"

        button.setTitle("Present", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }

    private func setContraints() {
        [label, button].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -30)
        ])
    }

    // MARK: - Selectors
    @objc
    private func handleButton(_ sender: UIButton) {
        let nextVC = SecondViewController()
        self.present(nextVC, animated: true, completion: nil)
    }
}
```

### SecondViewController
```swift
class SecondViewController: UIViewController {

    let textField = UITextField()
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - UI
    private func configureUI() {
        view.backgroundColor = .white
        setAttributes()
        setContraints()
    }

    private func setAttributes() {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5

        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }

    private func setContraints() {
        [textField, button].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 350),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -30)
        ])
    }

    // MARK: - Selectors
    @objc
    private func handleButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
```

## 3. Delegate Pattern 연습
### Protocol 구현하기
구현하고자 하는 method를 Protocol을 생성하고 그 내부에 만들어 주어야 한다. Protocol은 class을 Type으로 가진다. class Type을 가지게 되면 이후 생성할 delegate 인스턴스를 weak 형태로 생성할 수 있다.
```swift
// 1. 프로토콜 정의 (class 전용)
protocol ChatDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

// 2. 메시지를 받는 쪽 (delegate를 호출하는 쪽)
class ChatRoom {
    // 2.1 순환 참조 방지를 위해 반드시 weak 사용
    // 프로토콜에 AnyObject 또는 class 제약을 반드시 붙여야 함
    weak var delegate: ChatDelegate?

    func receiveNewMessage() {
        let message = "안녕하세요!"
        delegate?.didReceiveMessage(message)
    }
}

// 3. 메시지를 표시할 화면 (delegate를 구현하는 쪽)
class ChatViewController: UIViewController, ChatDelegate {
    let chatRoom = ChatRoom()

    override func viewDidLoad() {
        super.viewDidLoad()
        chatRoom.delegate = self // 위임 설정
    }

    func didReceiveMessage(_ message: String) {
        print("받은 메시지: \(message)")
    }
}
```

이 실습에서는 SecondViewController 의 UITextField 에 입력받은 내용을 FirstViewController 의 UILabel 에 전달해야하므로 우리가 구현할 method 는 String 을 Parameter 로 전달 받는다.
```swift
protocol CustomTextFieldDelegate: class {
    func textDidInput(didInput text: String)
}
```

### Delegate 인스턴스 생성하기
SecondViewController에서 delegate 인스턴스를 생성한다. delegate인스턴스는 CustomTextFieldDelegate를 타입으로 가짐으로서 이 인스턴스에 접근해서 우리가 Protocol 내부에 작성해두었던 함수에 접근할 수 있게 된다.
```swift
// weak 을 사용해 ARC 가 증가하지 않도록 만들어줌으로서 메모리 Leak 이 발생하지 않도록 방지해주는 것이 중요
weak var delegate: CustomTextFieldDelegate?
```

### Protocol 채택 및 필수 method 구현
Protocol을 채택시 우리가 생성한 Protocol을 채택하고 method까지 함께 구현한다.
Protocol을 채택할 때는 반드시 Extension으로 주어야 하는 것은 아니지만 필자는 가독성이 좋다고 판단하여 Extension으로 Delegate를 채택하는 것을 선호한다.
Protocol 이 채택되고 나면 경고창이 뜨면서 필수 함수를 구현하라고 나오는데 이 때 Xcode 가 지원하는 자동에러처리를 사용하면 함수 하나가 생성된다.

```swift
extension FirstViewController: CustomTextFieldDelegate {
    func textDidInput(didInput text: String) {
        label.text = text
    }
}
```

### Delegate 위임하기
delegate 인스턴스를 생성했을 때 Optional 형태로 생성하였다. 이 값에 CustomTextFieldDelegate를 채택한 FirstViewController를 할당해준다.
실제 Input은 SecondViewController에서 이루어지지만 그 값에 대한 처리가 FirstViewController에서 대행하겠다는 일종의 명시이다.
위임 방법은 FirstViewController에서 화면을 present할 때 구현해놓은 nextVC의 delegate에 접근에서 설정할 수 있다
```swift
@objc
private func handleButton(_ sender: UIButton) {
    let nextVC = SecondViewController()
    nextVC.delegate = self
    self.present(nextVC, animated: true, completion: nil)
}
```

## SecondViewController에서 함수가 동작해야하는 시점 설ㅈ정
우리가 원하는 타이밍에 함수가 작동할 수 있도록 코드 구현. 화면을 전달하면서 값을 전달하면된다. delegate의 textDidInput함수를 호출하는 시점이 결정되었고 이제 버튼이 눌리게 되면 View 가 Dismiss 되기 전 이 함수를 호출하며 FirstViewController 가 값을 전달받게 된다. 이게 가능한 이유는 SecondViewController 가 present 되기 전 우리가 FirstViewController 를 delegate 로 설정해주었기 때문이다.
```swift
@objc
private func handleButton(_ sender: UIButton) {
    let text = textField.text ?? ""
    self.delegate?.textDidInput(didInput: text)
    self.dismiss(animated: true, completion: nil)
}
```

### FirstViewController
```swift
class FirstViewController: UIViewController {

    let label = UILabel()
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - UI
    private func configureUI() {
        view.backgroundColor = .white
        setAttributes()
        setContraints()
    }

    private func setAttributes() {
        label.text = "Sample Text"

        button.setTitle("Present", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }

    private func setContraints() {
        [label, button].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -30)
        ])
    }

    // MARK: - Selectors
    @objc
    private func handleButton(_ sender: UIButton) {
        let nextVC = SecondViewController()
        nextVC.delegate = self
        self.present(nextVC, animated: true, completion: nil)
    }
}

extension FirstViewController: CustomTextFieldDelegate {
    func textDidInput(didInput text: String) {
        label.text = text
    }
}
```

### SecondViewController
```swift
class SecondViewController: UIViewController {

    weak var delegate: CustomTextFieldDelegate?

    let textField = UITextField()
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - UI
    private func configureUI() {
        view.backgroundColor = .white
        setAttributes()
        setContraints()
    }

    private func setAttributes() {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5

        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }

    private func setContraints() {
        [textField, button].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 350),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -30)
        ])
    }

    // MARK: - Selectors
    @objc
    private func handleButton(_ sender: UIButton) {
        let text = textField.text ?? ""
        self.delegate?.textDidInput(didInput: text)
        self.dismiss(animated: true, completion: nil)
    }
}
```

## Reference
- https://kasroid.github.io/posts/ios/20201010-uikit-delegate-pattern/