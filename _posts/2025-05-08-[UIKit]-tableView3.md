---

title: "[TableView] 3. 스토리보드로 커스텀 테이블뷰 구현하기"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="커스텀셀" width="30%"> -->

## 스토리보드로 커스텀 테이블뷰 구현하기

<table>
  <tr>
    <td><img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509003319693.png' | relative_url }}" alt="커스텀셀1" width="100%"></td>
    <td><img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509020704480.png' | relative_url }}" alt="커스텀셀2" width="100%"></td>
  </tr>
  <tr>
    <td style="text-align:center;">기존 셀</td>
    <td style="text-align:center;">구현할 커스텀 셀</td>
  </tr>
</table>
위 왼쪽 사진은 **1. 테이블뷰 예제**에서 구현한 방식이다. 사진처럼 셀 스타일이 기본 셀이라서 커스텀을 할 수 없다. 그래서 보통 UITableViewCell을 상속받아 커스텀 Cell Class를 만들어 입맛대로 만든다. 커스텀 Cell 적용 방식이 **1. 스토리보드, 2. Nib파일, 3. 코드 방식** 총 3가지가 있는데 이번 포스팅에서는 스토리보드 방식으로 커스템 셀 구현을 진행한다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 12.38.22(2).png' | relative_url }}" alt="커스텀셀" width="100%"> 
Shift + Command + L을 눌러서 TableView를 추가하고 상하좌우 제약을 0을 주도록 설정한다. 삼각형 모양이 Size Inspector이다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 12.49.28(2).png' | relative_url }}" alt="커스텀셀" width="100%"> 
Shift + Command + L을 눌러서 Table View Cell을 드래그해준다 이를 등록 과정(register)이라고 한다. ContentView가 핵심이다. 여기에 요소들 집어넣는다. 우측상단의 Raw Height로 셀 높이를 지정할 수 있다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 12.59.22(2).png' | relative_url }}" alt="커스텀셀" width="100%"> 
상단 Label은 Leading과 Top 걸어주고 하단 Label은 상단의 Leading, Vertical Spacing 설정, Bottom도 설정해준다. 이후 상단의 leading제약을 10으로 해준다. 그리고 상단 Label의 Top 제약을 10으로 걸면 빨간 에러가 뜬다. 
Label 자체는 크기를 가지고 있지 않기 때문에 상단 Label을 늘릴지 하단 Label이 늘릴지 정해줘야한다. 
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509010236155.png' | relative_url }}" alt="커스텀셀" width="100%">
상단Label의 크기는 유지하고 하단 Label의 크기를 늘려서 하단 Label의 Content Hugging Priority의 Vertical을 줄이면 된다. 
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509010642611.png' | relative_url }}" alt="커스텀셀" width="100%">
마무리로 모든 제약을 10으로 해준다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 1.08.47(2).png' | relative_url }}" alt="커스텀셀" width="100%">
긴 문장이 들어오면 number of lines가 1이라서 뒷부분이 잘린다. 해결하기 위해 상단 label의 trailing도 10 제약을 준다. 
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 1.12.45(2).png' | relative_url }}" alt="커스텀셀" width="100%">
<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509012025690.png' | relative_url }}" alt="커스텀셀" width="100%">
두번째 Label에도 긴문장을 넣으면 뒷부분이 잘린다. 해결을 위해 number of lines를 0으로 하고 trailing도 10 잡아준다. 이때 빨간색 줄이 생기는데 이유는 number of lines가 0이라서 계속 늘어나기 때문이다. 늘어났을 때 ContentView 사이즈공간이 모자라서 상단 Label을 밀어내려고 하기 떄문에 발생한다. 이를 해결하기 위해 Compression Resistance를 설정해야한다. 만약 하단 Label의 vertical을 751로 올리면 상단 Label이 없어진다. 그래서 상단Label을 누르고 Compression Resistance를 751로올려야한다.
<br/>

| 항목                              | 설명                                | 효과                            |
| --------------------------------- | ----------------------------------- | ------------------------------- |
| **Content Hugging = 낮음**        | 늘어나도 괜찮음                     | 다른 뷰들이 먼저 자기 크기 유지 |
| **Compression Resistance = 낮음** | 줄어들어도 괜찮음                   | 다른 뷰가 먼저 자기 크기 지킴   |
| **상단 Label Hugging 높음**       | 상단 Label이 더 이상 안 늘어나려 함 | 하단 Label이 늘어남             |
| **상단 Label Resistance 높음**    | 상단 Label이 안 줄어들고 버팀       | 하단 Label이 줄어듦             |

### 🔚 정리

- **Hugging**: "나는 커지기 싫어"(숫자 높을수록 안커짐)
- **Compression Resistance**: "나는 작아지기 싫어"(숫자 높을수록 안작아짐)
- 위 두 값을 적절히 조절해주면, Auto Layout이 충돌 없이 어떤 뷰가 늘어나거나 줄어들지 결정하게 된다.
    <br/>



```swift
import Foundation
import UIKit

class StoryboardCell: UITableViewCell {
    /// 1. 셀을 스토리보드에 추가하거나 Nib파일에 추가하게 되면 이 자체의 라이프사이클이 생긴다. awakeFromNib
    override class func awakeFromNib() {
        /// 2. 상속을 한것이기 때문에 부모에 있는 awakeFromNib 로직을 터트려줘야한다
        super.awakeFromNib()
    }
}
```

이제 커스텀 셀을 만들어야 한다. StoryboardCell.swift파일을 만들어준다.
셀을 스토리보드에 추가하거나 Nib파일에 추가하게 되면 이 자체의 라이프사이클이 생긴다. 이 라이프사이클을 awakeFromNib라고 한다. -> Interface Builder같이 스토리보드로 추가되거나 Nib파일로 되었을 경우에 awakeFromNib()가 호출된다 ViewController의 ViewDidload랑 비슷한 역할이다. 상속을 한것이기 때문에 부모에 있는 awakeFromNib 로직을 터트려줘야한다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 1.34.20(2).png' | relative_url }}" alt="커스텀셀" width="100%">
<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/스크린샷 2025-05-09 오전 1.40.11(2).png' | relative_url }}" alt="커스텀셀" width="100%">
Label이 드래그안될때는 당황하지말고 직접 @IBOutlet weak var로 선언해준다. 그리고 반대로 드래그해서 Label로 연결시켜주면 된다. 알고보니 StoryboardList의 StoryboardCell의 CustomClass설정을 StoryboardCell로 해줘야하는데 안되있어서 연결이 안된 것이었다. 주의하자. 이까지 완료되면 등록 과정(Register) 완료이다.
<br/>

```swift
// 커스텀 셀
import Foundation
import UIKit

class StoryboardCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    /// 1. 셀을 스토리보드에 추가하거나 Nib파일에 추가하게 되면 이 자체의 라이프사이클이 생긴다. awakeFromNib
    override func awakeFromNib() {
        /// 2. 상속을 한것이기 때문에 부모에 있는 awakeFromNib 로직을 터트려줘야한다
        super.awakeFromNib()
        print(#fileID, #function, #line, "- awakeFromNib()")
    }
}
```



```swift
//
//  StoryboardListViewController.swift
//  UITableViewTutorial
//
//  Created by 김동현 on 5/8/25.
//

import UIKit

class StoryboardListViewController: UIViewController {

    @IBOutlet weak var MyTableView: UITableView!
    
    var dummySections: [DummySection] = DummySection.getDumies(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyTableView.dataSource = self
        self.MyTableView.delegate = self
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

이제 StoryboardListViewController로 돌아와서 **func** tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) 여기서 수정한다. 기존의 let cell 부분을 주석처리하고 바로 셀을 생성하는게 아니라 테이블 뷰 자체는 메모리를 재사용한다고 했으니 재사용 셀을 설정하기 위해 dequeueReusableCell를 설정한다.현재 셀을 가져온다.

## Reference

- https://hanipsum.com

    