---
title: "[RxDataSource] 2. CustomDatasource 만들어보기"
tags: 
- ReactiveX
- RxDataSource
header: 
  teaser: 
typora-root-url: ../

---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->



## 커스텀 데이터소스 만들어보기

### Model
```swift
struct Todo {
    let id: Int
    let title: String
    let isDone: Bool
}
```

### Cell
```swift
import UIKit

// MARK: - Cell
final class RxCell: UITableViewCell {
    
    // 디버깅용
    var cellData: Todo? = nil
    
    private lazy var isDoneSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [titleLabel, idLabel])
        st.axis = .vertical
        return st
    }()
    
    private lazy var hStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [vStack, isDoneSwitch])
        st.axis = .horizontal
        return st
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print(#fileID, #function, #line, "prepareForReuse() - cellData.id: \(cellData?.id ?? 0)")
    }
    
    // 원래는 awakefromnib을 타지만 코드로 UI를 진행한다면 awakefromnib을 타지 않는다.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        /// 부모의 로직을 싱행시키는 의미
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        [hStack].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
}

extension RxCell {
    func configure(with todo: Todo) {
        self.cellData = todo
        titleLabel.text = todo.title
        idLabel.text = "ID: \(todo.id)"
        isDoneSwitch.isOn = todo.isDone
    }
}
```

### CustomDataSource
```swift
final class CustomDataSource: NSObject, UITableViewDataSource {
    
    var todoList: [Todo] = []
    var tableView: UITableView? = nil
    
    init(todoList: [Todo], tableView: UITableView) {
        self.todoList = todoList
        self.tableView = tableView
    }
    
    func register<T: UITableViewCell>(cellType: T.Type) {
        tableView?.register(cellType, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    // MARK: - UITableView Datasource Methods
    /// 하나의 섹션에 몇개의 rows가 있냐
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    
    // 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
    /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - returns: 구성된 UITableViewCell 객체
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RxCell.reuseIdentifier, for: indexPath) as? RxCell else {
            return UITableViewCell()
        }
        
        let cellData: Todo = todoList[indexPath.row]
        cell.configure(with: cellData)
        
        return cell
    }
}
```

### ViewController 
```swift
final class CustomDataSourceVC: UIViewController {
    
    private let todoList: [Todo] = [
        Todo(id: 0, title: "RxSwift 공부하기", isDone: false),
        Todo(id: 1, title: "UI 구성하기", isDone: false),
        Todo(id: 2, title: "코드 리뷰", isDone: false)
    ]
    private var customDataSource: CustomDataSource? = nil
    
    private let myTableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        constraints()
        setCustomDataSource()
    }
    
    private func setCustomDataSource() {
        // 1️⃣ dataSource 생성
        let dataSource = CustomDataSource(todoList: todoList, tableView: myTableView)
        
        // 2️⃣ register 호출 (이 시점에 tableView는 이미 존재함)
        dataSource.register(cellType: RxCell.self)
        
        // 3️⃣ 연결
        self.customDataSource = dataSource
        myTableView.dataSource = dataSource
    }
    
    private func makeUI() {
        [myTableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            myTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            myTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}
```
현재 CustomDataSource단점이 Todos에만 연결되어 있고, 어떤 셀을 보여줄것인지에 대한 것이 제한적이다. 매개변수를 활용하여 유연하게 만들어보자. 즉 로직을 밖으로 빼자