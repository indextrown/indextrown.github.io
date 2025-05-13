---
title: "[TableView] 7. UITableViewCell 확장을 통해 셀 식별자 코드 재사용"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="커스텀셀" width="30%"> -->

## 코드 재사용

```swift
/// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
/// - indexPath: 셀의 위치를 나타내는 인덱스 경로
/// - returns: 구성된 UITableViewCell 객체
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
    /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")

    // [guard let] 방식
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoryBoardCell", for: indexPath) as? StoryboardCell else {
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
```

지금까지 재사용되는 셀은 고유한 식별자를 상수로 넣어주는데 보통 클래스 명을 써주었다. 
프로그래밍 하면서 상수가 있는 부분은 최대한 피하는게 좋다. 이유는 상수를 재사용할 수도 있고 오타가 발생할 수 있기 때문이다.
<br/>



```swift
class StoryboardCell: UITableViewCell {
    
    // 변수로
    static let reuseIdentifier: String = "StoryboardCell"
    
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
guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardCell.reuseIdentifier, for: indexPath) as? StoryboardCell else {
    return UITableViewCell()
}
```

그래서 셀에서 static으로 상수로 추가해둔다. 이 방법도 충분하지만 조금 더 편하게 할 수 있다.
UITableviewCell 자체가 전부 reuseIdentifier라는 static변수를 가질 수 있게 하면 더 편리해질 수 있다.
<br/>

```swift

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self) // 현재 타입.현재 타입의 타입 그자체, 현재 타입의 타입 객체(메타타입)
    }
}

```

참고로 확장에서는 저장 속성을 정의할 수 없음으로 계산 속성으로 변경해준다.
<br/>



```swift

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self) // 현재 타입.현재 타입의 타입 그자체, 현재 타입의 타입 객체(메타타입)
    }
}

extension UICollectionView {
    static var reuseIdentifier: String {
        return String(describing: Self.self) // 현재 타입.현재 타입의 타입 그자체, 현재 타입의 타입 객체(메타타입)
    }
}
```

하지만 이 방식도 UItableView, UICollectionVIew각각마다 만들어줘야하는 불편함이 있다.  반복을 더 줄일 수 있다.
<br/>



```swift
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

// ReuseIdentifiable 채택
class StoryboardCell: UITableViewCell, ReuseIdentifiable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- awakeFromNib()")
        self.backgroundColor = .systemYellow
    }
}
```

프로토콜을 활용해서 해결하자. 프로토콜 이름은 아래 컨벤션을 따르면 좋다.
https://www.swift.org/documentation/api-design-guidelines/
<br/>



```swift
class NibListViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    var dummySections: [DummySection] = DummySection.getDumies(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        
        // storyboard에서는 테이블뷰에서 셀을 직접 드래그하기때문에 등록이 되지만 Nib 방식에서 등록을 시켜줘야한다.
        let cellNib = UINib(nibName: "NibCell", bundle: nil)
        self.myTableView.register(cellNib, forCellReuseIdentifier: "NibCell")
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
    }
}
```

이를 활용하면 Nib파일을 등록할때도 적용할 수 있다. NibCell을 상수로 사용하지 않고 프로토로 해결해보자.
<br/>

## 최종 코드

```swift
import UIKit

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

extension UITableViewCell: Nibbed, ReuseIdentifiable {}

class NibListViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    var dummySections: [DummySection] = DummySection.getDumies(10)
    
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
```

