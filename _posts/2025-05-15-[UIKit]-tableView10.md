---
title: "[TableView] 10. 테이블뷰 Combine CustomDataSource"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## 테이블뷰 콤바인 커스텀 데이터 소스

지난 시간에 Combine을 통해 List를 보여주었는데 이번 포스트에서는 Combine에서 구독을 통해 들어오는 데이터 바로 DataSource로 연결하는 방법을 해보자. 클로저에 대한 개념을 알아야 이해하기 쉽다.

### CustomCombineDataSource.swift

 ```swift
 //
 //  CustomCombineDataSource.swift
 //  UITableViewTutorial
 //
 //  Created by 김동현 on 5/15/25.
 //
 
 import UIKit
 
 class CustomCombineDataSource: NSObject, UITableViewDataSource {
     
     // 멤버 변수
     var dataList: [DummyData] = []
     
     override init() {
         super.init()
     }
     
     // MARK: - Combine 이벤트로 들어온 데이터랑 테이블뷰랑 연결시켜주는 지점
 
     /// 변경된 데이터를 받아서 테이블뷰에 적용한다
     /// - Parameters:
     ///   - updatedDataList: 외부에서 변경된 Combine Publisher로 들어온 데이터를 내 DataSource가 가진 data로 변경하기 위한 매개변수
     ///   - tableView: 리로드 대상 테이블뷰
     func pushDataList(_ updatedDataList: [DummyData], to tableView: UITableView) {
         tableView.dataSource = self
         self.dataList = updatedDataList
         tableView.reloadData()
     }
     
     // MARK: - 테이블뷰 데이터 소스 관련(변경이 된 데이터를 데이터소스로 넘겨받아서 reloadData를 하는 목적 
     
     /// 하나의 섹션에 몇개의 rows가 있냐
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return dataList.count
     }
 
     /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
     /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
     /// - returns: 구성된 UITableViewCell 객체
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
         /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
 
         // [guard let] 방식
         guard let cell = tableView.dequeueReusableCell(withIdentifier: CodeCell.reuseIdentifier, for: indexPath) as? CodeCell else {
             return UITableViewCell()
         }
 
         let cellData: DummyData = dataList[indexPath.row]
 
         /// 셀의 주 텍스트를 더미 데이터에서 가져오기
         cell.titleLabel.text = cellData.title
 
         /// 셀의 서브 타이틀 설정
         cell.bodyLabel.text = cellData.body
 
         cell.detailTextLabel?.numberOfLines = 0
         return cell
     }
 }
 ```

커스텀 데이터소스를 만든다. 멤버변수로 데이터리스트를 보유하도록 하자. 지금은 DummyData이지만 다음 포스팅에서 제네릭으로 변경할 예정이다.  DataSource에서 변경이 된 데이터와 테이블뷰 리로드를 위한 테이블뷰 접근을 관리하기 위해 pushDataList()를 만들어주자. 그리고 기존 ViewController에서 관리하던 UITableViewDataSource 관련 프로토콜 로직을 CustomCombineDataSource로 그대로 옮겨준다.  왜냐하면 원래 dataSource의 주요 역할이 어떤 셀의 종류를 보여줄지, 리스트 개수가 몇개일지를 관여하기 때문이다. 즉 기존 ViewController의 비즈니스 로직을 CustomDataSource로 옮긴 것이다. 이제 CustomDataSource를 만들었으니 적용하기 위해 클로저를 만들어주자.



### UITableView+Combine.swift

```swift
//
//  UITableView+Combine.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/15/25.
//

import UIKit
import Combine

// MARK: - Sink 정의를 보면 매개변수로 (Self.Output) -> Void) 형태의 클로저를 받는다. 이 형태를 만족하는 로직 함수를 만들자.
// public func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable
extension UITableView {
    // 고차함수 - 클로저를 매개변수로 가지거나 반환을 가지는 함수 자체
    // (Self.Output) -> Void)
    // ([DummyData]) -> Void
    // 데이터소스 바인딩
    func customItems() -> ([DummyData]) -> Void {
        let dataSource = CustomCombineDataSource()
        return { (updatedDateLisst: [DummyData]) in
            dataSource.pushDataList(updatedDateLisst, to: self) // 리로드
        }
    }
}
```

기존 ViewController에서 sink로 받는 것을 보면 제네릭 형태인데 Sink로 이벤트(Publisker)가 들어온 데이터를 매개변수로 가지고 반환이 없는 형태의 클로저이다. (Self.Output) -> Void)

이 (Self.Output) -> Void) 형태로 반환을 만족하는 함수를 만들어주자. 지금은 들어오는 형태가 [DummyData] 이므로 func customItems() -> ([DummyData]) -> Void로 해주면 된다.

SInk를 통해 들어오는게 [DummyData]로 들어오게 되고 return { input in } 에 input 부분으로 들어오게 된다.
그럼 pushDataList를 통해 변경이 된 이벤트를 나자신에게 넣어준다.



### CombineListViewController.swift

```swift
//
//  CombineListViewController.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/13/25.
//

import UIKit
import Combine

class CombineListViewController: UIViewController {
    
    // Combine 메모리 처리를 위해 생성
    var subscriptions = Set<AnyCancellable>()
    
    // Published를 하게 되면 dummies 데이터가 추가나 값 변경시 이벤트를 받을 수 있다.
    @Published var dummies: [DummyData] = []
    
    @IBOutlet weak var myTableView: UITableView!

   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        
        /*
        - sink는 @Published가 수정된 스레드에서 실행된다
        - 그래서 Published변수 수정시 메인 스레드에서 수정해주자
        - @Published 값을 메인 스레드에서 수정하든, 백그라운드에서 수정하든, .receive(on: .main)만 붙이면 sink는 메인에서 실행되고reloadData()도 안전하게 실행된다
         */
        
        // MARK: - 기존의 데이터를 받는 거를 CombineListViewController에서 다했더라면 이제는 customDataSource으로 따로 뺴두고, 로직은 extension으로 빼서 처리를 한 것이다.
        // $ 붙이면 데이터 이벤트를 받을 수 있는 상태가 됨
        // sink는 구독하는 것이다.
        // AnyCancellable 구독한다고 한다.
        // store: 구독했던거에 대한 메모리 참조가 들어오게 되는데 이를 관리하기 위해 subscriptions에 넣어준다.
        $dummies
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.myTableView.customItems())
            .store(in: &subscriptions)
        
        /*
         기존 방식
         $dummies
             .receive(on: DispatchQueue.main)
             // 데이터 변경시마다 동작
             .sink(receiveValue: { (changedDummies: [DummyData]) in
                 print("changedDummies: \(changedDummies.count)")
                 
                 // sink는 메인스레드에서 동작해서 Dispatch안해도된다
                 self.myTableView.reloadData()
             })
             .store(in: &subscriptions)
         */
        
        // 2초 뒤에 더미데이터 10개 추가
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            self.dummies += DummyData.getDumies(10)
        })
    }
    
    fileprivate func configureTableView() {
        
        // CodeCell에서는 이 줄만 필요
        self.myTableView.register(CodeCell.self, forCellReuseIdentifier: CodeCell.reuseIdentifier)
        // self.myTableView.delegate = self
    }
}
```
결국 Combine 데이터 변경되었을 때 즉 Publisher가 들어올 때 바로 tableview의 dataSource도 설정하고, 바로 데이터를 꽂아줄 수 있다. 하지만 지금 customItems() 형태가 DummyData로 고정되어있기 때문에 서버에서 받을 수 있는 여러 타입을 모두 반영하기 위해 제네릭으로 변환하는 포스팅을 작성할 예정이다.