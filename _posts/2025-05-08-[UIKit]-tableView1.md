---
title: "[TableView] 1. 테이블뷰 예제"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

## 테이블 뷰
테이블뷰는 dataSource와 delegate, Cell로 이루어져있다.

### 구성
- dataSource
  - 데이터와 관련된 부분
  - 셀을 어떻게 보여줄 지
  - 데이터 크기, 종류에 따른 셀의 타입 정하기
  - 리스트 개수가 몇개인지
- delegate 
  - 특정 셀 선택시 엑션과 같은 이벤트 처리 담당
- Cell
  - 테이블뷰에 들어가는 각각의 알맹이
  
    


### 예제 1
```swift
import UIKit

class ViewController: UIViewController {

    /// Interface Builder에 연결된 테이블 뷰 아울렛
    @IBOutlet weak var myTableView: UITableView!
    
    /// 더미 데이터
    var dummyDataList: [String] = [
        "hello world1",
        "hello world2",
        "hello world3",
        "hello world4",
        "hello world5",
        "hello world6",
        "hello world7",
        "hello world8",
        "hello world9",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 테이블 뷰의 데이터 소스, 델리겟을 현재 뷰 컨트롤러로 설정
        myTableView.dataSource = self
        myTableView.delegate = self
    }
}

/// 프로토콜은 약속이다 -> 준수해야한다
/// DateSource - 데이터 관련된 부분
/// 리스트는 섹션과 섹션안에 아이템들이 있다
/// 테이블뷰에서는 섹션과 로우로 부룬다
///
/// UITableView의 데이터 관리 역할을 담당
extension ViewController: UITableViewDataSource {
    
    /// 섹션 내 보여줄 셀의 개수를 반환
    /// - section: 섹션 인덱스 (기본적으로 1개 섹션 사용 중)
    /// - returns: 행(Row)의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyDataList.count
    }
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        /// 셀의 주 텍스트를 더미 데이터에서 가져오기
        cell.textLabel?.text = dummyDataList[indexPath.row]
        
        /// 셀의 서브 타이틀 설정
        cell.detailTextLabel?.text = "테스트"
        return cell
    }
}

/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension ViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```

### 예제 2
- 더미 데이터 활용    

```swift
struct DummyData {
    let uuid: UUID
    let title: String
    let body: String
    
    init() {
        self.uuid = UUID()
        self.title = "타이틀입니다: \(uuid)"
        self.body = "바디입니다: \(uuid)"
    }
    
    static func getDumies(_ count: Int = 100) -> [DummyData] {
        return (1...count).map { _ in DummyData() }
    }
}
```

```swift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var dummyDataList: [DummyData] = DummyData.getDumies()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let cellData: DummyData = dummyDataList[indexPath.row]
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.body
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```

### 예제 3
- 섹션의 header와 footer 활용  

```swift
import Foundation

struct DummySection {
    let uuid: UUID
    let title: String
    let body: String
    let rows: [DummyData]
    
    init() {
        self.uuid = UUID()
        self.title = "섹션 타이틀입니다: \(uuid)"
        self.body = "섹션 바디입니다: \(uuid)"
        self.rows = DummyData.getDumies(10)
    }
    
    static func getDumies(_ count: Int = 100) -> [DummySection] {
        return (1...count).map { _ in DummySection() }
    }
}

struct DummyData {
    let uuid: UUID
    let title: String
    let body: String
    
    init() {
        self.uuid = UUID()
        self.title = "타이틀입니다: \(uuid)"
        self.body = "바디입니다: \(uuid)"
    }
    
    static func getDumies(_ count: Int = 100) -> [DummyData] {
        return (1...count).map { _ in DummyData() }
    }
}
```

```swift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var dummySections: [DummySection] = DummySection.getDumies()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    
    /// 섹션이 여러개일때만 사용
    /// 섹션의 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "헤더: " + dummySections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "푸터: " + dummySections[section].title
    }
    
    /// 섹션이 여러개일때만 사용
    /// 현재 섹션이 몇개인지
    func numberOfSections(in tableView: UITableView) -> Int {
        return dummySections.count
    }
    
    /// 하나의 섹션에 몇개의 rows가 있냐
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummySections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let sectionData: DummySection = dummySections[indexPath.section]
        let cellData: DummyData = sectionData.rows[indexPath.row]
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.body
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```

### 예제 4
- Fakery 라이블러리 활용

```swift
import Foundation
import Fakery

struct DummySection {
    let uuid: UUID
    let title: String
    let body: String
    let rows: [DummyData]
    
    init() {
        self.uuid = UUID()
        self.title = "섹션 타이틀입니다: \(uuid)"
        self.body = "섹션 바디입니다: \(uuid)"
        self.rows = DummyData.getDumies(10)
    }
    
    static func getDumies(_ count: Int = 100) -> [DummySection] {
        return (1...count).map { _ in DummySection() }
    }
}

struct DummyData {
    let uuid: UUID
    let title: String
    let body: String
    
    init() {
        self.uuid = UUID()
        let faker = Faker(locale: "ko")
        let firstName = faker.name.firstName()  //=> "Emilie"
        let lastName = faker.name.lastName()    //=> "Hansen"
        
        let body = faker.lorem.paragraphs(amount: 10)
        
        self.title = "타이틀입니다: \(lastName) \(firstName)"
        self.body = "바디입니다: \(body)"
    }
    
    static func getDumies(_ count: Int = 100) -> [DummyData] {
        return (1...count).map { _ in DummyData() }
    }
}
```

```swift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var dummySections: [DummySection] = DummySection.getDumies()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    
    /// 섹션이 여러개일때만 사용
    /// 섹션의 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "헤더: " + dummySections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "푸터: " + dummySections[section].title
    }
    
    /// 섹션이 여러개일때만 사용
    /// 현재 섹션이 몇개인지
    func numberOfSections(in tableView: UITableView) -> Int {
        return dummySections.count
    }
    
    /// 하나의 섹션에 몇개의 rows가 있냐
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummySections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let sectionData: DummySection = dummySections[indexPath.section]
        let cellData: DummyData = sectionData.rows[indexPath.row]
        cell.textLabel?.text = cellData.title
        cell.detailTextLabel?.text = cellData.body
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```