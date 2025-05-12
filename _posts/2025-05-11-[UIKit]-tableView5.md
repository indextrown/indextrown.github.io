---

title: "[TableView] 5. 코드기반 커스텀 테이블뷰 구현하기"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="커스텀셀" width="30%"> -->

## 코드기반 커스텀 테이블뷰 구현하기

<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509020704480.png' | relative_url }}" alt="커스텀셀1" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView4/image-20250511173004744.png' | relative_url }}" alt="커스텀셀" width="85%"></td>
      <td><img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView5/image-20250511181826302.png' | relative_url }}" alt="커스텀셀" width="85%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">Storyboard 커스텀 셀</td>
    <td style="text-align:center;">Nib 커스텀 셀</td>
      <td style="text-align:center;">Code 커스텀 셀</td>
  </tr>
</table>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView5/image-20250511174809378.png' | relative_url }}" alt="커스텀셀" width="30%"> 
CodeList.xiv파일로 와서 테이블뷰를 드래그해서 추가 후 제약조건을 상하좌우 전부 0으로 해준다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView5/image-20250511175003817.png' | relative_url }}" alt="커스텀셀" width="70%"> 
myTableView를 ViewController로 드래그해서 IBOutlet 추가한다. 이떄 추가가안되면 xib파일의 viewController가 연결되있는지 확인한다.
<br/>

### CodeCell.swift

```swift
//
//  CodeCell.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/11/25.
//

import UIKit

class CodeCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "타이틀 라벨타이틀 라벨타이틀 라벨타이틀 라벨타이틀 라벨"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨바디 라벨"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    fileprivate func configureUI() {
        self.backgroundColor = .systemYellow
        
        // 타이틀 라벨 설정
        self.contentView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
        ])
        
        // 바디 라벨 설정
        self.contentView.addSubview(self.bodyLabel)
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            bodyLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            bodyLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // 원래는 awakefromnib을 타지만 코드로 UI를 진행한다면 awakefromnib을 타지 않는다.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier) /// 부모의 로직을 싱행시키는 의미
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}



#if DEBUG
import SwiftUI

extension UIView {
    private struct ViewRepresentable: UIViewRepresentable {
        let uiView: UIView
        func updateUIView(_ uiView: UIViewType, context: Context) {
        }
        func makeUIView(context: Context) -> some UIView {
            uiView
        }
    }
    
    func getPreview() -> some View {
        ViewRepresentable(uiView: self)
    }
}
#endif

#if DEBUG
import SwiftUI

struct CodeCell_PreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        CodeCell().getPreview()
            .previewLayout(.fixed(width: 200, height: 100))
    }
}
#endif

```



### CodeListViewController

```swift
//
//  CodeListViewController.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/8/25.
//

import UIKit

class CodeListViewController: UIViewController {

    
    @IBOutlet weak var myTableView: UITableView!
    var dummySections: [DummySection] = DummySection.getDumies(10)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        
        // CodeCell에서는 이 줄만 필요
        self.myTableView.register(CodeCell.self, forCellReuseIdentifier: "CodeCell")
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
    }
}


/// UITableView의 데이터 관리 역할을 담당
extension CodeListViewController: UITableViewDataSource {
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CodeCell", for: indexPath) as? CodeCell else {
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
extension CodeListViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

```



### 참고: 테이블뷰도 완전 코드베이스로 하는법

```swift
//
//  MainViewController.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/8/25.
//

import UIKit

class MainViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController loaded")
    }
    
    @IBAction func codeButtonTapped(_ sender: UIButton) {
        print("눌림")
        let vc = OnlyCodeBaseViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

```



```swift
//
//  OnlyCodeBaseViewController.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/11/25.
//

import UIKit

class OnlyCodeBaseViewController: UIViewController {
    
    private let myTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func setupTableView() {
        view.addSubview(myTableView)
        NSLayoutConstraint.activate([
            myTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            myTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            myTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            myTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        myTableView.register(CodeCell.self, forCellReuseIdentifier: "CodeCell")
        myTableView.dataSource = self
        myTableView.delegate = self
    }
    
    var dummySections: [DummySection] = DummySection.getDumies(10)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        configureTableView()
    }
}

/// UITableView의 데이터 관리 역할을 담당
extension OnlyCodeBaseViewController: UITableViewDataSource {
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CodeCell", for: indexPath) as? CodeCell else {
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
extension OnlyCodeBaseViewController: UITableViewDelegate {
    /// 사용자가 특정 셀을 선택했을 때 호출되는 메서드
    /// - Parameters:
    ///   - tableView: 이벤트가 발생한 테이블 뷰
    ///   - indexPath: 선택된 셀의 위치
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

```

