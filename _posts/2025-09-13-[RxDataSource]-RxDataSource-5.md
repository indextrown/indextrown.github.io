---
title: "[RxDataSource] 5. 버튼 액션을 클로저 이벤트로 전달하기"
tags: 
- ReactiveX
- RxDataSource
header: 
  teaser: 
typora-root-url: ../

---

# 기존 코드 개선
```swift
// MARK: - 한번 그려지고 끝나기 때문에 추가/삭제같은 이벤트를 반영할 수 없다.
let data = Observable<[RxTodo]>.just(RxTodo.getDumies())
data.bind(to: myTableView.rx.items(cellIdentifier: "RxTodoCell", cellType: RxTodoCell.self)) {
    index, model, cell in
    cell.configure(with: model)
}

// => BehaviorRelay를 사용하여 단발성이 아닌 변화가능한 상태를 가진 스트림을 만들어서 사용하자.
// MARK: - Relay는 Subject계열인데 끊어지지 않는다(.value로 접근시 마지막 데이터 확인가능 = stateful)
var rxTodosRelay: BehaviorRelay<[RxTodo]> = BehaviorRelay(value: RxTodo.getDumies())
rxTodosRelay
    .bind(to: myTableView.rx.items) { (tableView, row, element) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RxTodoCell.reuseIdentifier) as? RxTodoCell else { return UITableViewCell()}
        cell.configure(with: element)
        return cell
    }
    .disposed(by: disposeBag)
```
이전 포스팅에서 아래와 같이 더미 데이터를 한 번만 방출하도록 설정하였다.  
이 코드는 초기 데이터만 표시하고 변화가 될 수 없기 때문에 한계가 있다.
<br/><br/><br/><br/>

```swift
// MARK: - 3초뒤 갱신
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    self.rxTodosRelay.accept(RxTodo.getDumies(count: 3))
}

// MARK: - Rx스러운 3초뒤 갱신
Observable.just(())
    .delay(.seconds(3), scheduler: MainScheduler.instance) // Observable<Void>
    .map { RxTodo.getDumies(count: 5) }                    // Observable<[RxTodo]>
    .bind(onNext: self.rxTodosRelay.accept(_:))            // 같은 자료형이면 클로저가 들어갈 수 있다
    .disposed(by: disposeBag)
```
기존 딜레이 코드를 Rx스럽게 변경도 된다 동일한 로직이다.
<br/><br/><br/><br/>

# RxDataSource
RxDataSource는 Relay 같은 Observable이 갱신되면 렌더링이 된다.
지금 코드에서 todosRelay를 BehaviorRelay로 사용한 이유는 마지막 데이터를 알아야 CRUD를 진행할 수 있기 때문이다.
<br/><br/><br/><br/>




```swift
// MARK: - 버튼 연결
addButton.rx.tap
    .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        var currentTodos = self.rxTodosRelay.value // .value 하면 마지막에 보낸 데이터 할 수 있음
        currentTodos.insert(RxTodo(), at: 0)       // 첫번째 열에 넣겠다
        self.rxTodosRelay.accept(currentTodos)
    })
    .disposed(by: disposeBag)
```
crud 기능을 위해 추가 버튼을 만들었다.   
맨위에서부터 데이터를 들어가게 하기위해 insert를 사용했으나 아래에 넣고싶으면 append를 사용하면된다.
<br/><br/><br/><br/>



```swift
// ✅ 2. (더 유연하지만 수동 캐스팅 필요 – RxCocoa)
rxTodosRelay
    .bind(to: myTableView.rx.items) { (tableView, row, element) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RxTodoCell.reuseIdentifier) as? RxTodoCell else { return UITableViewCell()}
        cell.configure(with: element)
        
        // MARK: - 셀의 delete버튼 선택되었을 때 액션을 여기서 처리
        cell.deleteAction = { id in
            let currentTodos = self.rxTodosRelay.value
            let filteredTodos = currentTodos.filter { $0.id != id }
            self.rxTodosRelay.accept(filteredTodos)
        }
        
        // MARK: - 셀의 토글 클릭시 액션을 여기서 처리
        cell.isDoneChange = { [weak self] id, updatedIsDone in
            guard let self = self else { return }
            var currentTodos = self.rxTodosRelay.value
            // 일치하는것 찾기
            if let foundTodoIndex = currentTodos.firstIndex(where: { $0.id == id }) {
                currentTodos[foundTodoIndex].isDone = updatedIsDone
            }
            self.rxTodosRelay.accept(currentTodos)
        }
        
        return cell
    }
    .disposed(by: disposeBag)
```
커스텀 셀에서 만든 클로저 버튼 액션 내부 로직을 직접 구현해준다.  
이제 두가지 문제가 있는데 다음 포스팅에서 진행하겠다.
- 버튼도 그냥 addTarget말고 Rx로 연결하는게 어떨까?
- 토글시 애니메이션이 전혀 없어서 어색하게 보인다
<br/><br/><br/><br/> 


# 전체 코드
```swift
// Model
import Fakery
import UIKit

// MARK: - Model
struct RxTodo {
    let id: UUID = UUID()
    let title: String
    var isDone: Bool

    init(title: String? = nil,
         isDone: Bool = false
    ) {
        self.title = title ?? "터이틀: \(id.uuidString.prefix(8))"
        self.isDone = isDone
    }

    static func getDumies(count: Int = 10) -> [RxTodo] {
        let faker = Faker(locale: "ko")
        var result: [RxTodo] = []

        for _ in 1...count {
            let firstName = faker.name.firstName()
            let lastName = faker.name.lastName()
            let title = "\(lastName) \(firstName)"
            result.append(RxTodo(title: title, isDone: false))
        }
        return result
    }
}
```

```swift
// Cell
import UIKit
import RxSwift
import RxCocoa

final class RxTodoCell: UITableViewCell {

    var cellData: RxTodo? = nil

    // MARK: - Rx
    var disposeBag = DisposeBag()
    var isDoneChange: ((_ id: UUID, _ newValue: Bool) -> Void)? = nil
    var deleteAction: ((_ id: UUID) -> Void)? = nil

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    private lazy var isDoneSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()

    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete", for: .normal)
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, idLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [vStack, isDoneSwitch, deleteButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
        constraints()
        
        // MARK: - 버튼 연결
        isDoneSwitch.addTarget(self, action: #selector(handleIsDone), for: .valueChanged)
        deleteButton.addTarget(self, action: #selector(handleDeleteButton), for: .touchUpInside)
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
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        print(#fileID, #function, #line, "prepareForReuse() - cellData.id: \(cellData?.id ?? UUID())")
        self.disposeBag = DisposeBag()
    }
}

extension RxTodoCell {
    func configure(with todo: RxTodo) {
        self.cellData = todo
        titleLabel.text = todo.title

        let idString = String(todo.id.uuidString.prefix(10))
        idLabel.text = "ID: \(idString)"
        isDoneSwitch.isOn = todo.isDone
        // setRx()
    }
 
    // MARK: - 디버깅용
    func configure(title: String, id: Int) {
        titleLabel.text = title
        idLabel.text = "ID: \(id)"
        isDoneSwitch.isOn = false

    }
}

extension RxTodoCell {
    @objc func handleIsDone(_ sender: UISwitch) {
        print(#fileID, #function, #line, "- id: \(cellData?.id.uuidString ?? "") sender: \(sender.isOn)")
        guard let id = self.cellData?.id else { return }
        isDoneChange?(id, sender.isOn)
    }
    
    @objc func handleDeleteButton(_ sender: UIButton) {
        guard let id = self.cellData?.id else { return }
        deleteAction?(id)
    }
}

#if DEBUG
import SwiftUI
// TodoCell 미리보기
struct RxTodoCell_Preview: PreviewProvider {
    static var previews: some View {
        let cell = RxTodoCell()
        cell.configure(title: "할 일 예제", id: 42)
        return cell.contentView
            .getPreview()
            .previewLayout(.fixed(width: 350, height: 100))
            .background(Color.white)
    }
}
#endif
```

```swift
// ViewController
import UIKit
import RxSwift
import RxCocoa
import RxRelay

final class RxTodoViewController2: UIViewController {

    // MARK: - 구독에 대한 찌꺼기 처리
    var disposeBag =  DisposeBag()
    
    // MARK: - Relay는 Subject계열인데 끊어지지 않는다(.value로 접근시 마지막 데이터 확인가능 = stateful)
    var rxTodosRelay: BehaviorRelay<[RxTodo]> = BehaviorRelay(value: RxTodo.getDumies())

    // MARK: - UI
    private lazy var addButton = UIBarButtonItem(title: "추가",
                                                 style: .plain,
                                                 target: nil,
                                                 action: nil)

    private lazy var myTableView: UITableView = {
        let tv = UITableView()
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        makeUI()
        constraints()
        
        // MARK: - 코드기반 사용한다면
        myTableView.register(RxTodoCell.self, forCellReuseIdentifier: "RxTodoCell")
        
        // ✅ 1. RxTodoCell을 타입으로 명시하여 바인딩하는 간결한 방식
        /*
         data.bind(to: myTableView.rx.items(cellIdentifier: RxTodoCell.reuseIdentifier,
                                            cellType: RxTodoCell.self)) { index, model, cell in
             cell.configure(with: model)
         }
        .disposed(by: disposeBag)
         */
        
        
        // ✅ 2. (더 유연하지만 수동 캐스팅 필요 – RxCocoa)
        rxTodosRelay
            .bind(to: myTableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RxTodoCell.reuseIdentifier) as? RxTodoCell else { return UITableViewCell()}
                cell.configure(with: element)
                
                // MARK: - 셀의 delete버튼 선택되었을 때 액션을 여기서 처리
                cell.deleteAction = { id in
                    let currentTodos = self.rxTodosRelay.value
                    let filteredTodos = currentTodos.filter { $0.id != id }
                    self.rxTodosRelay.accept(filteredTodos)
                }
                
                // MARK: - 셀의 토글 클릭시 액션을 여기서 처리
                cell.isDoneChange = { [weak self] id, updatedIsDone in
                    guard let self = self else { return }
                    var currentTodos = self.rxTodosRelay.value
                    // 일치하는것 찾기
                    if let foundTodoIndex = currentTodos.firstIndex(where: { $0.id == id }) {
                        currentTodos[foundTodoIndex].isDone = updatedIsDone
                    }
                    self.rxTodosRelay.accept(currentTodos)
                }
                
                return cell
            }
            .disposed(by: disposeBag)
        
        
        // MARK: - 3초뒤 갱신
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.rxTodosRelay.accept(RxTodo.getDumies(count: 3))
        }
         */
        
        // MARK: - Rx스러운 3초뒤 갱신
        /*
        Observable.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance) // Observable<Void>
            .map { RxTodo.getDumies(count: 5) }                    // Observable<[RxTodo]>
            .bind(onNext: self.rxTodosRelay.accept(_:))            // 같은 자료형이면 클로저가 들어갈 수 있다
            .disposed(by: disposeBag)
        */
        
        // MARK: - 버튼 연결
        addButton.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                var currentTodos = self.rxTodosRelay.value // .value 하면 마지막에 보낸 데이터 할 수 있음
                currentTodos.insert(RxTodo(), at: 0)       // 첫번째 열에 넣겠다
                self.rxTodosRelay.accept(currentTodos)
            })
            .disposed(by: disposeBag)
    }
    
    private func makeUI() {
        [myTableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 네비게이션 버튼
        navigationItem.rightBarButtonItems = [addButton]
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