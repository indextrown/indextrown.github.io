---
title: "📌 [SwiftUI] List + 기본 TextField 문제점"
tags: 
- SwiftUI
use_math: true
header: 
  teaser: /assets/img/Swift/SwiftWhite.png
---

# 📌 1. 기존 문제 원인 분석 (SwiftUI List + 기본 TextField)

### ✅ 원인 1: SwiftUI TextField가 List와 충돌
- List는 UIKit의 UITabView를 래핑한 SwiftUI 컴포넌트이다.
- SwiftUI의 TextField는 입력시 상태 ***@Binding var text***가 변경될 때마다 전체 List를 다시 그릴 수 있다.
- 이 과정에서 SwiftUI가 배경을 다시 렌더링하면서 검은색 잔상이 나타나게 된다.
### ➡ 즉, List가 자동으로 다시 그려지면서 백그라운드 깜빡임이 발생한다

```swift
struct ErrorMainTabView: View {
    @State var searchText: String
    var body: some View {
        
        ZStack {
            Color.mainBlack
                .ignoresSafeArea()
            
            VStack {
                TextField("검색", text: $searchText)
                    .padding()
                    .background(Color.subBlack)
                    .cornerRadius(10)
                    .padding()
                
                List {
                    Section(header:
                        Text("Numbers")
                        .foregroundColor(Color.mainGreen)
                        .font(.system(size: 17, weight: .bold))
                        .padding(.leading, -10)
                    ) {
                        ForEach(0...5, id: \.self) { memo in
                            Button {
                                
                            } label: {
                                Text(String(memo))
                                    .foregroundColor(.white) // ✅ 텍스트 색상
                                    .frame(maxWidth: .infinity, alignment: .leading) // ✅ 왼쪽 정렬
                                
                            }
                            .listRowBackground(Color.subBlack) // ✅ 각 행의 배경색 지정
                            .listRowSeparatorTint(Color.gray.opacity(0.4), edges: .bottom) // ✅ 구분선 색상 지정
                        }
                    }
                }
                .scrollContentBackground(.hidden) // ✅ 리스트 기본 배경 제거
                .background(Color.mainBlack) // ✅ 전체 리스트 배경 변경
            }
        }
    }
}
```

# 📌 2. 커스텀 UITextField를 사용했을 때 해결

### ✅ 해결된 원인 1: UITextField는 List를 리렌더링하지 않음
- UITextField는 UIKit 기반이므로, 입력 시 List를 다시 렌더링하지 않음.
- SwiftUI의 TextField와 달리, @Binding 값이 바뀌어도 SwiftUI 전체 뷰를 다시 그리지 않음.
-  즉, UITextField를 사용하면서 List의 불필요한 리렌더링이 사라짐.
### ➡ 커스텀 UITextField를 사용하면 SwiftUI의 TextField가 가지던 불필요한 리렌더링 문제를 방지할 수 있다.
```swift
struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var horizontalPadding: CGFloat = 15 // ✅ 좌우 패딩 값을 하나의 변수로 추가

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // ✅ 엔터 누르면 키보드 닫기
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor(Color.subBlack)
        textField.layer.cornerRadius = 10
        textField.textColor = .white
        textField.returnKeyType = .done

        // ✅ 좌측 패딩 추가
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalPadding, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always

        // ✅ 우측 패딩 추가
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalPadding, height: textField.frame.height))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always

        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChangeSelection(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
    }
    
    // ✅ 외부 터치 시 키보드를 닫는 메서드 추가
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
```