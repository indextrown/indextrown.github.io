---
title: "[Combine] 예제 1 & MVVM[SwiftUI/UIKit]"
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

#### 1. SwiftUI MVVM + Combine
#### NumbersView.swift
```swift
import SwiftUI

/*
 @StateObject
 - 객체를 직접 생성 및 소유한다
 - 뷰가 다시 그려져도 객체는 재생성되지않는다
 - 해당 뷰에서 객체롤 초기화 및 관리를 위해 사용
 - 상태 유지에 효율적
 - 루트뷰에서 주로 사용
 - 객체를 초기화하고 SwiftUI 뷰 상태에 저장하는데 사용하는 속성 래퍼
 - 뷰가 존재하는 한 객체가 저장되고 뷰와 함께 삭제됨을 의미한다
 - 일반적으로 @StateObject를 사용하는 것은 하나의 뷰가 아닌 여러 뷰에 필요한 클래스 객체에 실용적이다
 
 @ObservedObject
 - 상태 변경시 뷰를 다시 생성
 - 객체를 외부에서 주입받음
 - 뷰가 다시 그려지면 객체도 다시 주입됨
 - 상위 뷰에서 객체를 전달받아 사용시
 - 객체가 자주 재생성됨
 - 서브뷰 또는 전달받는뷰
 
 공통점
 - observable 객체를 구독하는 property wrapper
 - 구독중인 observable 객체가 변경되면 뷰에 업데이트 시켜주는 기능
 
 차이점
 - 둘다 observableObject를 구독하여 값이 변경되면 뷰에 반영하는 property wrapper
 - 상태 변경시 @ObservedObject는 뷰를 다시 생성하지만 @StateObject는 다시 생성하지않고 동일 뷰가 사용(효율)
 - 기본적으로 @StateObject를 사용하되, 해당 프로퍼티를 subView에 주입해야 한다면 @ObservedObject로 선언하여 사용할 것
 - subView에 @StateObject를 주입하면 해당 @StateObject의 수명 주기가 두 곳에서 관리가 되므로 의존성을 줄이기 위해 @ObservedObject를 사용
 
 - https://hackernoon.com/lang/ko/Swiftuis-5-주요-속성-래퍼-및-이를-효과적으로-사용하는-방법
 - https://ios-development.tistory.com/1160
 */

struct NumbersView: View {
    
    @StateObject private var viewModel = NumbersVM()
    var body: some View {
        VStack(alignment: .trailing) {
            TextField("", text: $viewModel.number1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $viewModel.number2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $viewModel.number3)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("", text: $viewModel.number4)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Divider()
            Text(viewModel.resultValue)
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

#### NumbersViewModel.swift
```swift
import Combine
import UIKit

/*
 
 비즈니스 로직
 - 데이터 상태를 VM이 가지고 있다
 - 즉 완성된 데이터를 VM이 가지고 있다
 
 2가지 상태의 데이터
 - 뷰모델로 들어오는 Input
 - 뷰모델로 나가는 Output == 비즈니스 로직을 타서 완성된 데이터가 뷰모델에서 나가는 것
 
 https://hackernoon.com/lang/ko/Swiftuis-5-주요-속성-래퍼-및-이를-효과적으로-사용하는-방법
 
 */
final class NumbersVM: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Input: 뷰모델로 들어오는 데이터
    @Published var number1: String = ""
    @Published var number2: String = ""
    @Published var number3: String = ""
    @Published var number4: String = ""
    
    // MARK: - Output: 뷰모델로 나가는 데이터
    @Published var resultValue: String = ""
    
    init() {
        print(#fileID, #function, #line, "- ")
        
        Publishers
            .CombineLatest4($number1,
                            $number2,
                            $number3,
                            $number4)
            .map { testValue1, testValue2, testValue3, testValue4 -> Int in
                return  testValue1.getNumber() +
                        testValue2.getNumber() +
                        testValue3.getNumber() +
                        testValue4.getNumber()
            }

            .map { String($0) }
            // resultValue에 직접 꽂을건데 객체이므로 자기자신의 속성으로
            .assign(to: \.resultValue, on: self)
            /*
             assign대신 이렇게 해도됨
            .sink { value in
                self.resultValue = value
            }
             */
            .store(in: &subscriptions)
    }
}
```

--- 

#### 2. NumbersViewModel 리팩토링
- 로직을 따로 뺴자
- 1번과 2번방식을 추천

```swift
//
//  NumbersVM.swift
//  CombineTutorial-example
//
//  Created by 김동현 on 7/18/25.
//

import Combine
import UIKit

/*
 
 비즈니스 로직
 - 데이터 상태를 VM이 가지고 있다
 - 즉 완성된 데이터를 VM이 가지고 있다
 
 2가지 상태의 데이터
 - 뷰모델로 들어오는 Input
 - 뷰모델로 나가는 Output == 비즈니스 로직을 타서 완성된 데이터가 뷰모델에서 나가는 것
 
 https://hackernoon.com/lang/ko/Swiftuis-5-주요-속성-래퍼-및-이를-효과적으로-사용하는-방법
 
 */
final class NumbersVM: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var resultPublisher: AnyPublisher<String, Never> =
        Publishers
            .CombineLatest4($number1,
                            $number2,
                            $number3,
                            $number4)
            .map { testValue1, testValue2, testValue3, testValue4 -> Int in
                return  testValue1.getNumber() +
                        testValue2.getNumber() +
                        testValue3.getNumber() +
                        testValue4.getNumber()
            }
            .map { String($0) }
            .eraseToAnyPublisher()
    
    private var resultPublisher2: AnyPublisher<String, Never> {
        Publishers
            .CombineLatest4($number1,
                           $number2,
                           $number3,
                           $number4)
           .map { testValue1, testValue2, testValue3, testValue4 -> Int in
               return  testValue1.getNumber() +
                       testValue2.getNumber() +
                       testValue3.getNumber() +
                       testValue4.getNumber()
           }
           .map { String($0) }
           .eraseToAnyPublisher()
    }
        
    
    // MARK: - Input: 뷰모델로 들어오는 데이터
    @Published var number1: String = ""
    @Published var number2: String = ""
    @Published var number3: String = ""
    @Published var number4: String = ""
    
    // MARK: - Output: 뷰모델로 나가는 데이터
    @Published var resultValue: String = ""
    
    init() {
        print(#fileID, #function, #line, "- ")
        
        // 1번 방식
        setupBinding()
        
        // 2번 방식
        resultPublisher
            .assign(to: \.resultValue, on: self)
            .store(in: &subscriptions)
        
        // 3번 방식
        resultPublisher2
            .assign(to: \.resultValue, on: self)
            .store(in: &subscriptions)
    }

    private func setupBinding() {
        Publishers
            .CombineLatest4($number1,
                            $number2,
                            $number3,
                            $number4)
            .map { testValue1, testValue2, testValue3, testValue4 -> Int in
                return  testValue1.getNumber() +
                        testValue2.getNumber() +
                        testValue3.getNumber() +
                        testValue4.getNumber()
            }

            .map { String($0) }
            // resultValue에 직접 꽂을건데 객체이므로 자기자신의 속성으로
            .assign(to: \.resultValue, on: self)
            /*
             assign대신 이렇게 해도됨
            .sink { value in
                self.resultValue = value
            }
             */
            .store(in: &subscriptions)
    }
}
```

--- 

#### 2. UIKit MVVM + Combine
#### 기존 NumbersViewController.swift
- 기존 코드는 ViewController에 로직이 들어있으니 mvvm으로 만들어보자.
```swift
import UIKit
import Combine
import CombineCocoa

final class NumbersViewController: UIViewController {
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!
    @IBOutlet weak var result: UILabel!
    var subscriptions = Set<AnyCancellable>()
    private var viewModel: NumbersVM = NumbersVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - ViewModel에 Input 넣어주기
        
        
        Publishers
            .CombineLatest3(number1.textPublisher,
                           number2.textPublisher,
                           number3.textPublisher)
            .map { testValue1, testValue2, testValue3 -> Int in
                return  testValue1.getNumber() +
                        testValue2.getNumber() +
                        testValue3.getNumber()
            }
            /*
            .sink { value in
                print(#fileID, #function, #line, "- value: \(value)")
            }
             */
            .map { String($0) }
            .assign(to: \.text, on: result)
            .store(in: &subscriptions)
    }
}
```

#### NumbersViewController.swift
```swift
import UIKit
import Combine
import CombineCocoa

final class NumbersViewController: UIViewController {
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!
    @IBOutlet weak var result: UILabel!
    var subscriptions = Set<AnyCancellable>()
    private var viewModel: NumbersVM = NumbersVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - ViewModel에 Input 넣어주기
        number1.textPublisher
            .compactMap { $0 }
            .assign(to: \.number1, on: viewModel) // viewModel이 가지고 있는 number1 속성에 꽂는다
            .store(in: &subscriptions)
        
        number2.textPublisher
            .compactMap { $0 }
            .assign(to: \.number2, on: viewModel)
            .store(in: &subscriptions)
        
        number3.textPublisher
            .compactMap { $0 }
            .assign(to: \.number3, on: viewModel)
            .store(in: &subscriptions)
        
        // MARK: - ViewModel에서 나오는 데이터 바인딩하기
        viewModel.$resultValue
            .compactMap { $0 }
            .map { String($0) }
            .assign(to: \.text, on: result) // result.text에 resultValue를 해줘라
            .store(in: &subscriptions)
        
        
//        Publishers
//            .CombineLatest3(number1.textPublisher,
//                           number2.textPublisher,
//                           number3.textPublisher)
//            .map { testValue1, testValue2, testValue3 -> Int in
//                return  testValue1.getNumber() +
//                        testValue2.getNumber() +
//                        testValue3.getNumber()
//            }
//            /*
//            .sink { value in
//                print(#fileID, #function, #line, "- value: \(value)")
//            }
//             */
//            .map { String($0) }
//            .assign(to: \.text, on: result)
//            .store(in: &subscriptions)
    }
}
```

#### NumbersVM.swift
```swift
import Combine
import UIKit

/*
 
 비즈니스 로직
 - 데이터 상태를 VM이 가지고 있다
 - 즉 완성된 데이터를 VM이 가지고 있다
 
 2가지 상태의 데이터
 - 뷰모델로 들어오는 Input
 - 뷰모델로 나가는 Output == 비즈니스 로직을 타서 완성된 데이터가 뷰모델에서 나가는 것
 
 https://hackernoon.com/lang/ko/Swiftuis-5-주요-속성-래퍼-및-이를-효과적으로-사용하는-방법
 
 */
final class NumbersVM: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var resultPublisher: AnyPublisher<String, Never> =
        Publishers
            .CombineLatest4($number1,
                            $number2,
                            $number3,
                            $number4)
            .map { testValue1, testValue2, testValue3, testValue4 -> Int in
                return  testValue1.getNumber() +
                        testValue2.getNumber() +
                        testValue3.getNumber() +
                        testValue4.getNumber()
            }
            .map { String($0) }
            .eraseToAnyPublisher()
    
    private var resultPublisher2: AnyPublisher<String, Never> {
        Publishers
            .CombineLatest4($number1,
                           $number2,
                           $number3,
                           $number4)
           .map { testValue1, testValue2, testValue3, testValue4 -> Int in
               return  testValue1.getNumber() +
                       testValue2.getNumber() +
                       testValue3.getNumber() +
                       testValue4.getNumber()
           }
           .map { String($0) }
           .eraseToAnyPublisher()
    }
        
    
    // MARK: - Input: 뷰모델로 들어오는 데이터
    @Published var number1: String = ""
    @Published var number2: String = ""
    @Published var number3: String = ""
    @Published var number4: String = ""
    
    // MARK: - Output: 뷰모델로 나가는 데이터
    @Published var resultValue: String = ""
    
    init() {
        print(#fileID, #function, #line, "- ")
        
        // 1번 방식
        setupBinding()
        
        // 2번 방식
        /*
        resultPublisher
            .assign(to: \.resultValue, on: self)
            .store(in: &subscriptions)
         */
        
        // 3번 방식
        /*
        resultPublisher2
            .assign(to: \.resultValue, on: self)
            .store(in: &subscriptions)
         */
    }

    private func setupBinding() {
        Publishers
            .CombineLatest4($number1,
                            $number2,
                            $number3,
                            $number4)
            .map { testValue1, testValue2, testValue3, testValue4 -> Int in
                return  testValue1.getNumber() +
                        testValue2.getNumber() +
                        testValue3.getNumber() +
                        testValue4.getNumber()
            }

            .map { String($0) }
            // resultValue에 직접 꽂을건데 객체이므로 자기자신의 속성으로
            .assign(to: \.resultValue, on: self)
            /*
             assign대신 이렇게 해도됨
            .sink { value in
                self.resultValue = value
            }
             */
            .store(in: &subscriptions)
    }
}
```