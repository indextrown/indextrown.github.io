---
title: "[TableView] 12. 테이블뷰 제네릭 CustomCombineDataSource"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## 테이블뷰 제네릭 CustomCombineDataSource
이전 포스팅에서 tableview데이터소스를 combine과 제네릭으로 연결을 했다. 
데이터소스는 데이터와 연괸되어있고, 셀의 종류를 정하고, 리스트 개수가 몇개인지 정하는 역할이다 즉 데이터와 관련이 있다.

이전 포스팅에서 커스텀 DataSource를 만들어서 처리하였는데 문제가 있었다. 리스트를 보여줄 때 데이터 타입이 변경되면 받을 수 없고 DummyData타입만 받을 수 있었다. 어떠한 데이터가 오더라도 확장성이 있도록 호출하는 쪽에서 셀의 타입을 정하도록 구현해보자.

### CustomCombineDataSource.swift

 ```swift
 //
 //  CustomCombineDataSource.swift
 //  UITableViewTutorial
 //
 //  Created by 김동현 on 5/15/25.
 //
 // https://www.youtube.com/watch?v=vlJ392OMkoI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=16
 
 import UIKit
 
 /*
 class CustomCombineDataSource<T, G>: NSObject, UITableViewDataSource {
     
     // 멤버 변수
     var dataList: [T] = []
     
     var testDataList: [G] = []
 */
 
 class CustomCombineDataSource<Item>: NSObject, UITableViewDataSource {
     
     // 셀을 만드는 클로저
     // 1. let makeCell: (_ tableView: UITableView, _ indexPath: IndexPath, _ cellData: Item) -> UITableViewCell
     // 2. let makeCell: (UITableView, IndexPath, Item) -> UITableViewCell // 위랑 같음
     // 3.
     var makeCell: ((UITableView, IndexPath, Item) -> UITableViewCell)? = nil // 옵셔널로도 가능
     
     var dataList: [Item] = []
     
     // 2. 안쪽에서 터트리기 때문에 escaping 해주자
     /*
     init(makeCell: @escaping (_ tableView: UITableView, _ indexPath: IndexPath, _ cellData: Item) -> UITableViewCell) {
         self.makeCell = makeCell
         super.init()
     }
      */
     
     // 3. 옵셔널로 한다면 escaping 안해도 된다
     init(_ makeCell: ((_ tableView: UITableView, _ indexPath: IndexPath, _ cellData: Item) -> UITableViewCell)? = nil) {
         self.makeCell = makeCell
         super.init()
     }
     
     // MARK: - Combine 이벤트로 들어온 데이터랑 테이블뷰랑 연결시켜주는 지점
 
     /// 변경된 데이터를 받아서 테이블뷰에 적용한다
     /// - Parameters:
     ///   - updatedDataList: 외부에서 변경된 Combine Publisher로 들어온 데이터를 내 DataSource가 가진 data로 변경하기 위한 매개변수
     ///   - tableView: 리로드 대상 테이블뷰
     func pushDataList(_ updatedDataList: [Item], to tableView: UITableView) {
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
     /// 어떤 셀을 보여줄지
     // 1. 테이블뷰
     // 2. indexPath 몇번째인지
     // 3. 셀에 대한 데이터 - 셀에 대한 제네릭 데이터
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         // 비어있으면 기본 UITableViewCell 반환
         makeCell?(tableView, indexPath, dataList[indexPath.row]) ?? UITableViewCell()
         
         //        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
         //        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
         //
         //        // [guard let] 방식
         //        guard let cell = tableView.dequeueReusableCell(withIdentifier: CodeCell.reuseIdentifier, for: indexPath) as? CodeCell else {
         //            return UITableViewCell()
         //        }
         //
         //        if let dataList = dataList as? [DummyData] {
         //            let cellData: DummyData = dataList[indexPath.row]
         //
         //            /// 셀의 주 텍스트를 더미 데이터에서 가져오기
         //            cell.titleLabel.text = cellData.title
         //
         //            /// 셀의 서브 타이틀 설정
         //            cell.bodyLabel.text = cellData.body
         //
         //            cell.detailTextLabel?.numberOfLines = 0
         //        }
         //
         //        if let dataList = dataList as? [IndexData] {
         //            let cellData: IndexData = dataList[indexPath.row]
         //
         //            /// 셀의 주 텍스트를 더미 데이터에서 가져오기
         //            cell.titleLabel.text = cellData.title
         //
         //            /// 셀의 서브 타이틀 설정
         //            cell.bodyLabel.text = cellData.body
         //
         //            cell.detailTextLabel?.numberOfLines = 0
         //        }
         //
         //        return cell
     }
 }
 
 
 
 
 
 ```

tableView()의 각 매개변수 tableView, indexPath, 그리고 셀에 대한 데이터 cellData을 조합을 하여 UITableViewCell 즉 셀을 만들자. 기존 tableView() 내부를 전부 주석처리를 하고 주석부분을 만드는 클로저를 두자. 함수 = 클로저 = 논리이다.  즉 논리 = 로직이다. 다시말해 로직을 클로저로 빼자.



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
    func customItemsWithCell<Item>(
        makeCell: ((UITableView, IndexPath, Item) -> UITableViewCell)? = nil
    ) -> ([Item]) -> Void {
        let dataSource = CustomCombineDataSource<Item>(makeCell)
        return { (updatedDateLisst: [Item]) in
            dataSource.pushDataList(updatedDateLisst, to: self) // 리로드
        }
    }
}

```



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
    @Published var indexDatas: [IndexData] = []
    
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
        
        $dummies.receive(on: DispatchQueue.main)
            .sink(receiveValue: self.myTableView.customItemsWithCell(
                // 셀에 대한 종류를 정해주기 위해 바깥으로 뺀 형태 -> makeCell을 데이터 타입마다 다르게 정의할 수 있다
                makeCell: { myTableView, indexPath, cellData in
                
                // [guard let] 방식
                guard let cell = myTableView.dequeueReusableCell(withIdentifier: CodeCell.reuseIdentifier, for: indexPath) as? CodeCell else {
                    return UITableViewCell()
                }
        
                cell.titleLabel.text = cellData.title  // 셀의 주 텍스트를 더미 데이터에서 가져오기
                cell.bodyLabel.text = cellData.body // 셀의 서브 타이틀 설정
                cell.detailTextLabel?.numberOfLines = 0
                return cell
                
            }))
            .store(in: &subscriptions)
        
        
        // 2초 뒤에 더미데이터 10개 추가
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            self.dummies += DummyData.getDumies(10)
            // self.indexDatas += IndexData.getDumies(10)
        })
    }
    
    fileprivate func configureTableView() {
        
        // CodeCell에서는 이 줄만 필요
        self.myTableView.register(CodeCell.self, forCellReuseIdentifier: CodeCell.reuseIdentifier)
        // self.myTableView.delegate = self
    }
}

```



