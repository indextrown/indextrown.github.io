---
title: "[TableView] 9. 테이블뷰 콤바인 적용"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## 테이블뷰 콤바인 적용

## Combine이란?

- iOS 13 이상부터 지원한다.
- 데이터를 리액티브 흐름으로 만들어서 데이터가 변경되면 이벤트 처리를 받을 수 있도록 설정할 수 있는데 보내는쪽을Publisher,  받는쪽을 Subscribe라고 한다.
- 기존 테이블뷰에서는 데이터를 dataSource에서 처리하였는데 ViewController에서 데이터 변경이 일어나면 dataSource와 연결시켜서 바로 테이블뷰에 보여줄 수 있다.

<img src="{{ '/assets/img/2025-05-13-[UIKit]-tableView9/image-20250513181643441.png' | relative_url }}" alt="이미지" width="70%">
우선 CombineList.storyboard라는 이름으로 파일을 생성하고 테이블뷰를 만들어준다.

```swift
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
        
        // $ 붙이면 데이터 이벤트를 받을 수 있는 상태가 됨
        // sink는 구독하는 것이다.
        // AnyCancellable 구독한다고 한다.
        // store: 구독했던거에 대한 메모리 참조가 들어오게 되는데 이를 관리하기 위해 subscriptions에 넣어준다.
        $dummies
            .receive(on: DispatchQueue.main)
            // 데이터 변경시마다 동작
            .sink(receiveValue: { (changedDummies: [DummyData]) in
                print("changedDummies: \(changedDummies.count)")
                
                // sink는 메인스레드에서 동작해서 Dispatch안해도된다
                self.myTableView.reloadData()
            })
            .store(in: &subscriptions)
        
        // 2초 뒤에 더미데이터 10개 추가
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            self.dummies += DummyData.getDumies(10)
        })
    }
    
    fileprivate func configureTableView() {
        
        // CodeCell에서는 이 줄만 필요
        self.myTableView.register(CodeCell.self, forCellReuseIdentifier: CodeCell.reuseIdentifier)
        
        self.myTableView.dataSource = self
//        self.myTableView.delegate = self
    }
}


/// UITableView의 데이터 관리 역할을 담당
extension CombineListViewController: UITableViewDataSource {

    /// 하나의 섹션에 몇개의 rows가 있냐
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummies.count
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

        let cellData: DummyData = dummies[indexPath.row]

        /// 셀의 주 텍스트를 더미 데이터에서 가져오기
        cell.titleLabel.text = cellData.title

        /// 셀의 서브 타이틀 설정
        cell.bodyLabel.text = cellData.body

        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}
```


그리고 연결할 CombineListViewController를 만들어준다.

<img src="{{ '/assets/img/2025-05-13-[UIKit]-tableView9/image-20250513183738608.png' | relative_url }}" alt="이미지" width="70%">
Main.storyboard에서 Combine버튼 생성 후 reference 생성하고 Stoayboard이름과 Referenced ID도 추가해준다.
