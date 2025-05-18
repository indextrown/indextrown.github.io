---
title: "[TableView] UITextView vs UITextField"
tags: 
- UIKit
- UIComponent
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## UITextView UITextField  차이
TextField는 placeholder를 사용할 수 있으나 TextView는 안되는것을 알게 되어 두 컴포넌트의 차이에 대해 알아보고자 정리하게 되었다.

# UITextView
[공식문서](https://developer.apple.com/documentation/uikit/uitextview/)를 살펴보면 
```text
A scrollable, multiline text region
```
**1줄 이상으로 이루어진 스크롤 가능한 텍스트 영역**  
placeholder는 제공하지 않기 때문에 직접 구현해야 한다.

## placeholder 구현 방법
UITextView는 UITextViewDeleagate 프로토콜을 채택하고 있다. 
그 중 textViewDidBeginEditing method를 사용해서 구현해보자.

```swift
// init 시 상태를 lazy로 지정
private lazy var textView: UITextView = {
    let tv = UITextView()
    tv.text = "입력하세요.."
    tv.textColor = .secondaryLabel
    tv.delegate = self
    return textView
}()
```
init 시 상태를 lazy로 지정해주면서 layout 세팅을 진행하였다.

## textViewDidBeginEditing
```text
Tells the delegate when editing of the specified text view begins.
```
**Optional 설정으로 textView의 수정이 일어나면 실행되는 메서드**  

```swift
extension UploadViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .secondaryLabel else { return }
        textView.text = nil
        textView.textColor = .label
    }
}
```
textColor가 .secondaryLabel라는 기본값으로 세팅되어 있으면 return 시키고, 아니라면 text를 비우고 Color도 검정색으로 바꾸어준다.

# UITextField