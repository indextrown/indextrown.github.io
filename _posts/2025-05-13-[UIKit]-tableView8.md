---
title: "[TableView] 8. 데이터 소스 이해, 따로써보기"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="커스텀셀" width="30%"> -->

## 8. 데이터 소스 이해, 따로써보기

## 테이블 뷰 만들기(List)

- 테이블뷰 컨트롤러로 만들기(기능이 한정적) vs 일반 뷰 컨트롤러로 만들기
- 우리는 일반 뷰 컨트롤러를 주로 쓰자
- 구성
    - 데이터 소스 - 데이터와 연관, 셀의 종류를 정하기, 보여줄 셀의 개수가 몇개인지 정하기

        ```swift
        class viewController: UIViewController {}
        
        extension viewController: UITableViewDataSource {
            /// 섹션 내의 셀 개수를 반환하는 메서드
            /// - Parameters:
            ///   - tableView: 데이터를 표시할 테이블 뷰
            ///   - section: 현재 섹션 인덱스
            /// - Returns: 해당 섹션에 표시할 행(row)의 개수
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                // 예: return items.count
            }
            
            /// 각 행에 표시될 셀을 반환하는 메서드
            /// - Parameters:
            ///   - tableView: 셀을 표시할 테이블 뷰
            ///   - indexPath: 현재 행의 위치 정보 (섹션, row)
            /// - Returns: 구성된 UITableViewCell 객체
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                // 예:
                // let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
                // cell.textLabel?.text = items[indexPath.row]
                // return cell
            }
        }
        ```
    
    - 델리겟 - 이벤트 처리(특정 셀 선택) = 테이블뷰에 대한 액션
    - 셀 - 테이블뷰에 들어가는 알맹이







## DataSource를 따로 빼보기

### 기존 코드

Cell 파일은 수정 x

```swift
protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

protocol ReuseIdentifiable {
    // 프로토콜에서 로직을 정의할 수 없어서 가져올 수 있도록 설정
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    // 로직에 대한 정의는 Extension에서 간능
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: Nibbed {}
extension UITableViewCell : ReuseIdentifiable { }
extension UITableViewHeaderFooterView : ReuseIdentifiable {}

class StoryboardCell: UITableViewCell {
    
    // 변수로
    //static let reuseIdentifier: String = "StoryboardCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    /// 1. 셀을 스토리보드에 추가하거나 Nib파일에 추가하게 되면 이 자체의 라이프사이클이 생긴다. awakeFromNib
    override func awakeFromNib() {
        /// 2. 상속을 한것이기 때문에 부모에 있는 awakeFromNib 로직을 터트려줘야한다
        super.awakeFromNib()
        print(#fileID, #function, #line, "- awakeFromNib()")
        self.backgroundColor = .systemYellow
    }
}
```



```swift
import UIKit

class StoryboardListViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var dummySections: [DummySection] = DummySection.getDummies(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
    }
}

/// UITableView의 데이터 관리 역할을 담당
extension StoryboardListViewController: UITableViewDataSource {
    
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
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        // [guard let] 방식
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardCell.reuseIdentifier, for: indexPath) as? StoryboardCell else {
            return UITableViewCell()
        }
        
        let sectionData: DummySection = dummySections[indexPath.section]
        
        let cellData: DummyData = sectionData.rows[indexPath.row]
        
        /// 셀의 주 텍스트를 더미 데이터에서 가져오기
        cell.titleLabel.text = cellData.title
        
        /// 셀의 서브 타이틀 설정
        cell.bodyLabel.text = cellData.body
        
        //cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}

/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension StoryboardListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```



## 수정된 코드

```swift
import UIKit

class MyDataSource: NSObject, UITableViewDataSource {
    
    var dummySections: [DummySection] = DummySection.getDummies()
    
    override init() {
        super.init()
    }
    
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
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        // [guard let] 방식
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardCell.reuseIdentifier, for: indexPath) as? StoryboardCell else {
            return UITableViewCell()
        }
        
        let sectionData: DummySection = dummySections[indexPath.section]
        
        let cellData: DummyData = sectionData.rows[indexPath.row]
        
        /// 셀의 주 텍스트를 더미 데이터에서 가져오기
        cell.titleLabel.text = cellData.title
        
        /// 셀의 서브 타이틀 설정
        cell.bodyLabel.text = cellData.body
        
        //cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}

```



```swift
import UIKit

class StoryboardListViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var dataSource: MyDataSource = MyDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.dataSource = dataSource
        self.myTableView.delegate = self
    }
}


/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension StoryboardListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```





## NibListViewController도 MyDataSource로수정 가능

### 기존 코드

```swift
import UIKit

class NibListViewController: UIViewController {

    
    @IBOutlet weak var myTableView: UITableView!
    var dummySections: [DummySection] = DummySection.getDummies(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        
        // storyboard에서는 테이블뷰에서 셀을 직접 드래그하기때문에 등록이 되지만 Nib 방식에서 등록을 시켜줘야한다.
        // let cellNib = UINib(nibName: "NibCell", bundle: nil)
        
        // self.myTableView.register(cellNib, forCellReuseIdentifier: "NibCell")
        self.myTableView.register(NibCell.uinib, forCellReuseIdentifier: NibCell.reuseIdentifier)
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
    }
}

/// UITableView의 데이터 관리 역할을 담당
extension NibListViewController: UITableViewDataSource {
    
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
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        // [guard let] 방식
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NibCell", for: indexPath) as? NibCell else {
            return UITableViewCell()
        }
        
        let sectionData: DummySection = dummySections[indexPath.section]
        
        let cellData: DummyData = sectionData.rows[indexPath.row]
        
        /// 셀의 주 텍스트를 더미 데이터에서 가져오기
        cell.titleLabel.text = cellData.title
        
        /// 셀의 서브 타이틀 설정
        cell.bodyLabel.text = cellData.body
        
        //cell.detailTextLabel?.numberOfLines = 0
        return cell
        
        /*
        [if let] 방식
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StoryBoardCell", for: indexPath) as? StoryboardCell {
            let sectionData: DummySection = dummySections[indexPath.section]
            
            let cellData: DummyData = sectionData.rows[indexPath.row]
            
            /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.titleLabel.text = cellData.title
            
            /// 셀의 서브 타이틀 설정
            cell.bodyLabel.text = cellData.body
            
            //cell.detailTextLabel?.numberOfLines = 0
            return cell
        } else {
            return UITableViewCell()
        }
        */
    }
}

/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension NibListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

```



### 수정된 코드

```swift
import UIKit

class MyDataSource: NSObject, UITableViewDataSource {
    
    enum ListType {
        case storyboard
        case nib
        case code
        case cellConfig
    }
    
    var listType: ListType = .storyboard
    
    var dummySections: [DummySection] = DummySection.getDummies()
    
    override init() {
        super.init()
    }
    
    convenience init(type: ListType = .storyboard) {
        self.init()
        self.listType = type
    }
    
    // MARK: - 셀을 등록하는 소스 관련
    /// 셀을 등록
    /// 스토리보드에서 셀을 추가하면 Xcode가 내부적으로 셀을 자동 등록한다
    /// 이코드가 자동 등록된다고 생각 tableView.dequeueReusableCell(withIdentifier: "StoryboardCell")
    /// - Parameter tableView: 등록할 테이블뷰
    func registerCells(with tableView: UITableView) {
        tableView.register(NibCell.uinib, forCellReuseIdentifier: NibCell.reuseIdentifier)
    }
    
    // MARK: -  테이블뷰 데이터 소스 관련
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
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        // [guard let] 방식
        
        switch listType {
        case .storyboard:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardCell.reuseIdentifier, for: indexPath) as? StoryboardCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.titleLabel.text = cellData.title /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.bodyLabel.text = cellData.body   /// 셀의 서브 타이틀 설정
            return cell
        case .nib:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NibCell.reuseIdentifier, for: indexPath) as? NibCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.titleLabel.text = cellData.title /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.bodyLabel.text = cellData.body   /// 셀의 서브 타이틀 설정
            return cell
        case .code:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CodeCell.reuseIdentifier, for: indexPath) as? CodeCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.titleLabel.text = cellData.title /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.bodyLabel.text = cellData.body   /// 셀의 서브 타이틀 설정
            return cell
        case .cellConfig:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfigTableViewCell.reuseIdentifier, for: indexPath) as? CellConfigTableViewCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.title = cellData.title
            cell.body = cellData.body
            return cell
        }
    }
}
```

```swift
import UIKit

class NibListViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var dataSource: MyDataSource = MyDataSource(type: .nib)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        // self.myTableView.register(NibCell.uinib, forCellReuseIdentifier: NibCell.reuseIdentifier)
        
        // 셀을 등록
        self.dataSource.registerCells(with: myTableView)
        self.myTableView.dataSource = dataSource
        self.myTableView.delegate = self
    }
}

/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension NibListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```



## CellConfigurationListViewController도 MyDataSource로수정 가능

### 기존 코드

```swift
import UIKit

class CellConfigurationListViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    var dummySections: [DummySection] = DummySection.getDummies(10)
    
    override func viewDidLoad() {
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        
        // CodeCell에서는 이 줄만 필요
        self.myTableView.register(CellConfigTableViewCell.self, forCellReuseIdentifier: "CellConfigTableViewCell")
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
    }
}


/// UITableView의 데이터 관리 역할을 담당
extension CellConfigurationListViewController: UITableViewDataSource {
    
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
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        // [guard let] 방식
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellConfigTableViewCell", for: indexPath) as? CellConfigTableViewCell else {
            return UITableViewCell()
        }
        
        let sectionData: DummySection = dummySections[indexPath.section]
        
        let cellData: DummyData = sectionData.rows[indexPath.row]
        
        /// 셀의 주 텍스트를 더미 데이터에서 가져오기
        // cell.titleLabel.text = cellData.title
        
        /// 셀의 서브 타이틀 설정
        // cell.bodyLabel.text = cellData.body
        
        //cell.detailTextLabel?.numberOfLines = 0
        
        // 여기서는 UI에 접근하는게 아니라 Cell이 가지고 있는 멤버변수 데이터 자체에 접근
        cell.title = cellData.title
        cell.body = cellData.body
        return cell
    }
}

/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension CellConfigurationListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

```



### 수정된 코드

```swift
import UIKit

class MyDataSource: NSObject, UITableViewDataSource {
    
    enum ListType {
        case storyboard
        case nib
        case code
        case cellConfig
    }
    
    var listType: ListType = .storyboard
    
    var dummySections: [DummySection] = DummySection.getDummies(10)
    
    override init() {
        super.init()
    }
    
    convenience init(type: ListType = .storyboard) {
        self.init()
        self.listType = type
    }
    
    // MARK: - 셀을 등록하는 소스 관련
    /// 셀을 등록
    /// 스토리보드에서 셀을 추가하면 Xcode가 내부적으로 셀을 자동 등록한다
    /// 이코드가 자동 등록된다고 생각 tableView.dequeueReusableCell(withIdentifier: "StoryboardCell")
    /// - Parameter tableView: 등록할 테이블뷰
    func registerCells(with tableView: UITableView) {
        /// Nib 방식으로 만든 셀(NibCell.xib 파일)을 테이블 뷰에 등록
        /// - NibCell.uinib : UINib(nibName: "NibCell", bundle: nil) 을 반환
        /// - NibCell.reuseIdentifier : "NibCell" 문자열을 반환 (보통 클래스명을 기반으로 자동 생성)
        /// → 이후 dequeue 시 이 identifier로 셀을 재사용할 수 있게 됨
        /// tableView.register(NibCell.uinib, forCellReuseIdentifier: NibCell.reuseIdentifier)
        
        /// 코드로만 구현된 셀 클래스를 테이블 뷰에 등록
        /// - CellConfigTableViewCell.self : 클래스 자체를 등록
        /// - reuseIdentifier : "CellConfigTableViewCell" 문자열
        /// → register(class:) 방식은 .xib 없이 순수 코드로 UI 구성한 셀에 사용
        /// tableView.register(CellConfigTableViewCell.self, forCellReuseIdentifier: CellConfigTableViewCell.reuseIdentifier)
        switch listType {
        case .nib:
            tableView.register(NibCell.uinib, forCellReuseIdentifier: NibCell.reuseIdentifier)
            
        case .code:
            tableView.register(CodeCell.self, forCellReuseIdentifier: CodeCell.reuseIdentifier)
            
        case .cellConfig:
            tableView.register(CellConfigTableViewCell.self, forCellReuseIdentifier: CellConfigTableViewCell.reuseIdentifier)
            
        case .storyboard:
            // ❌ 스토리보드는 register 필요 없음!
            break
        }
    }
    
    // MARK: -  테이블뷰 데이터 소스 관련
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
    
    /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        // [guard let] 방식
        
        switch listType {
        case .storyboard:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardCell.reuseIdentifier, for: indexPath) as? StoryboardCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.titleLabel.text = cellData.title /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.bodyLabel.text = cellData.body   /// 셀의 서브 타이틀 설정
            return cell
        case .nib:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NibCell.reuseIdentifier, for: indexPath) as? NibCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.titleLabel.text = cellData.title /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.bodyLabel.text = cellData.body   /// 셀의 서브 타이틀 설정
            return cell
        case .code:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CodeCell.reuseIdentifier, for: indexPath) as? CodeCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.titleLabel.text = cellData.title /// 셀의 주 텍스트를 더미 데이터에서 가져오기
            cell.bodyLabel.text = cellData.body   /// 셀의 서브 타이틀 설정
            return cell
        case .cellConfig:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfigTableViewCell.reuseIdentifier, for: indexPath) as? CellConfigTableViewCell else {
                return UITableViewCell()
            }
            let sectionData: DummySection = dummySections[indexPath.section]
            let cellData: DummyData = sectionData.rows[indexPath.row]
            cell.title = cellData.title
            cell.body = cellData.body
            return cell
        }
    }
}
```

```swift
import UIKit

class CellConfigurationListViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    var dummySections: [DummySection] = DummySection.getDummies(10)
    var dataSource: MyDataSource = MyDataSource(type: .cellConfig)
    
    override func viewDidLoad() {
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        
        // CodeCell에서는 이 줄만 필요
//        self.myTableView.register(CellConfigTableViewCell.self, forCellReuseIdentifier: "CellConfigTableViewCell")
        
        self.dataSource.registerCells(with: myTableView)
        self.myTableView.dataSource = dataSource
        self.myTableView.delegate = self
    }
}

/// 이벤트 관련 부분 - 셀 선택 등 사용자 인터랙션(이벤트) 관련 처리
extension CellConfigurationListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}
```

