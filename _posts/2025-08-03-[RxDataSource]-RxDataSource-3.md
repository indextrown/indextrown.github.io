---
title: "[RxDataSource] 3. CustomDatasource 개선하기"
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



지난 포스트에서 커스텀 델리게이트를 만들어 보았다. 이번에는 기존 코드를 개선하여 셀 구성 로직을 VC에서 정의할 수 있도록 매개변수로 빼서 위임해보자.

## 지난 코드

```swift
protocol ReuseIdentifiable {
    /// 프로토콜에서 로직을 정의할 수 없어서 가져올 수 있도록 설정
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    /// 로직에 대한 정의는 Extension에서 간능
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable {}

// MARK: - Model
struct Todo {
    let id: Int
    let title: String
    var isDone: Bool
    
    static func getDumies(_ count: Int = 10) -> [Todo] {
        let faker = Faker(locale: "ko")
        return (1...count).map { id in
            let firstName = faker.name.firstName()
            let lastName = faker.name.lastName()
            let title = "\(lastName) \(firstName)"
            return Todo(id: id, title: title, isDone: false)
        }
    }
}

final class TodoCell: UITableViewCell {
    
    // 디버깅용
    var cellData: Todo? = nil
    
    // (uuid, 변경된상태)
    var isDoneChange: ((Int, _ newValue: Bool) -> Void)? = nil
    
    lazy var isDoneSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var idLabel: UILabel = {
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
        
        isDoneSwitch.addTarget(self,
                               action: #selector(handleIsDOne),
                               for: .valueChanged)
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
    
    @objc func handleIsDOne(_ sender: UISwitch) {
        print(#fileID, #function, #line, "- id: \(cellData?.id ?? 0), sendar: \(sender.isOn)")
        guard let id = self.cellData?.id else { return }
        isDoneChange?(id, sender.isOn)
    }
}

extension TodoCell {
    func configure(with todo: Todo) {
        self.cellData = todo
        titleLabel.text = todo.title
        idLabel.text = "ID: \(todo.id)"
        isDoneSwitch.isOn = todo.isDone
    }
}

// MARK: - 구현 목적: VC에 부담을 주지말자
final class TodosDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var todoList: [Todo] = []
    var tableView: UITableView? = nil
    
    init(todoList: [Todo], tableView: UITableView) {
        self.todoList = todoList
        self.tableView = tableView
    }
    
    // MARK: - Register
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
    /// - returns: 구성된 UITableViewCell 객체e
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // MARK: - 로직 -> 함수로 만들어서 매개변수로 활용해보자
        guard let cell: TodoCell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let cellData = todoList[indexPath.row]
        cell.configure(with: cellData)
        return cell
    }
}

final class TodosVC: UIViewController {
    
    private lazy var myTableView: UITableView = {
        let tv = UITableView()
        // MARK: - 이 부분도 TodosDataSource에 위임
        // tv.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        return tv
    }()
    
    var todoList: [Todo] = []
    var todosDataSource: TodosDataSource? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.makeUI()
        self.constraints()
        self.todoList = Todo.getDumies()
        self.setCustomDataSource()
    }
    
    private func setCustomDataSource() {
        // 1️⃣ dataSource 생성
        let dataSource = TodosDataSource(todoList: todoList, tableView: myTableView)
        
        // 2️⃣ register 호출 (이 시점에 tableView는 이미 존재함)
        dataSource.register(cellType: TodoCell.self)
        
        // 3️⃣ 연결
        self.todosDataSource = dataSource
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

## 개선 코드

### Custom Delegate
```swift
import UIKit

// MARK: - 구현 목적: VC에 부담을 주지말자
final class TodosDataSource2: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var todoList: [Todo] = []
    var tableView: UITableView? = nil
    
    // MARK: - 로직을 밖으로 뺄 수 있다 즉 VC에서 클로저로 사용 가능하다.
    // configureCell 클로저: 셀 구성 로직을 VC에서 정의할 수 있게 위임함
    // 매개변수 tableView, indexPath는 외부에서 받아오고
    // cellData(todo)는 내부 todoList에서 가져와 주입
    var configureCell: ((UITableView, IndexPath, Todo) -> UITableViewCell)?
    
    init(todoList: [Todo], tableView: UITableView) {
        self.todoList = todoList
        self.tableView = tableView
    }
    
    // MARK: - Register
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
    /// - returns: 구성된 UITableViewCell 객체e
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellData = todoList[indexPath.row]
        return configureCell?(tableView, indexPath, cellData) ?? UITableViewCell()
        
        // MARK: - 로직 -> 함수로 만들어서 매개변수로 활용해보자
        /*
        guard let cell: TodoCell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: cellData)
        return cell
         */
    }
}

```

### ViewController
```swift
import UIKit

final class TodosVC2: UIViewController {
    
    private lazy var myTableView: UITableView = {
        let tv = UITableView()
        // MARK: - 이 부분도 TodosDataSource에 위임
        // tv.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        return tv
    }()
    
    var todoList: [Todo] = []
    var todosDataSource: TodosDataSource2? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.makeUI()
        self.constraints()
        
        self.todoList = Todo.getDumies()
        self.setCustomDataSource()
    }
    
    private func setCustomDataSource() {
        // 1️⃣ dataSource 생성
        todosDataSource = TodosDataSource2(todoList: todoList, tableView: myTableView)
        
        // MARK: - 여기에 클로저 추가
        self.todosDataSource?.configureCell = { mytableView, indexPath, cellData in
            
            guard let cell: TodoCell = self.myTableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
            
            cell.configure(with: cellData)
            cell.isDoneChange = { [weak self] id, isDone in
                guard let self = self else { return }
                if let foundIndex = self.todoList.firstIndex( where: {$0.id == id} ) {
                    self.todosDataSource?.todoList[foundIndex].isDone = isDone
                    DispatchQueue.main.async {
                        self.myTableView.reloadRows(at: [IndexPath(row: foundIndex, section: 0)], with: .fade)
                    }
                }
            }
            
            return cell
        }
        
        // 2️⃣ register 호출 (이 시점에 tableView는 이미 존재함)
        todosDataSource?.register(cellType: TodoCell.self)
        
        // 3️⃣ 연결
        myTableView.dataSource = todosDataSource
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