---
title: "[RxDataSource] 5. 버튼 액션을 Rx로 연결하기"
tags: 
- ReactiveX
- RxDataSource
header: 
  teaser: 
typora-root-url: ../

---

# 기존 코드 개선
```swift
override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    makeUI()
    constraints()
    
    // MARK: - 버튼 연결
    // isDoneSwitch.addTarget(self, action: #selector(handleIsDone), for: .valueChanged)
    // deleteButton.addTarget(self, action: #selector(handleDeleteButton), for: .touchUpInside)
}

// MARK: - Rx로 버튼 연결
func setRx() {
    
    // MARK: - 초기 이벤트를 버리고 이후부터 모두 전달받겠다
    /*
    isDoneSwitch.rx.isOn
        .skip(1) // 처음 방출값 무시(초기값 세팅 이벤트 무시)
        .debug("isDoneSwitch 디버그")
        .bind(onNext: { [weak self] isOn in
            guard let self = self, let id = self.cellData?.id else { return }
            self.isDoneChange?(id, isOn)
        })
        .disposed(by: disposeBag)
        */
    
    // MARK: - 스위치가 valueChanged이벤트를 낼 때만 트리거 하겠다 & 해당시점은 isOn 값을 가져오겠다
    isDoneSwitch.rx.controlEvent(.valueChanged)
        .withLatestFrom(isDoneSwitch.rx.isOn) // 토글 후 최신값 가져오기
        .bind(onNext: { [weak self] isOn in
            guard let self = self, let id = self.cellData?.id else { return }
            self.isDoneChange?(id, isOn)
        })
        .disposed(by: disposeBag)
    
    deleteButton.rx.tap
        .debug("deleteButton 디버그")
        .bind(onNext: { [weak self] _ in
            guard let self = self, let id = self.cellData?.id else { return }
            self.deleteAction?(id)
        })
        .disposed(by: disposeBag)
}
```
기존 커스텀 셀의 버튼 연결 방식은 addTarget인데 Rx스럽게 하기 위해 주석처리 및 setRx()함수를 만들었다.   
setRx()은 configure 함수에서 호출하도록 하였다.
지금은 이벤트 처리 자체를 클로저로 주고 있는데 이렇게 말고 deleteButton.rx.tap 자체를 외부에서 넘겨줄 수 있다. deleteActionObservable을 만들어서 외부에서 주입하도록 해보자.

# RxTodoCell 수정
```swift
var deleteActionObservalble: Observable<UUID> = Observable.empty()

    // MARK: - Rx로 버튼 연결
    func setRx() {
        
        // MARK: - 초기 이벤트를 버리고 이후부터 모두 전달받겠다
        /*
        isDoneSwitch.rx.isOn
            .skip(1) // 처음 방출값 무시(초기값 세팅 이벤트 무시)
            .debug("isDoneSwitch 디버그")
            .bind(onNext: { [weak self] isOn in
                guard let self = self, let id = self.cellData?.id else { return }
                self.isDoneChange?(id, isOn)
            })
            .disposed(by: disposeBag)
         */
        
        // MARK: - 스위치가 valueChanged이벤트를 낼 때만 트리거 하겠다 & 해당시점은 isOn 값을 가져오겠다
        isDoneSwitch.rx.controlEvent(.valueChanged)
            .withLatestFrom(isDoneSwitch.rx.isOn) // 토글 후 최신값 가져오기
            .bind(onNext: { [weak self] isOn in
                guard let self = self, let id = self.cellData?.id else { return }
                self.isDoneChange?(id, isOn)
            })
            .disposed(by: disposeBag)
        
        // MARK: - 기존 방식
        /*
        deleteButton.rx.tap
            .debug("deleteButton 디버그")
            .bind(onNext: { [weak self] _ in
                guard let self = self, let id = self.cellData?.id else { return }
                self.deleteAction?(id)
            })
            .disposed(by: disposeBag)
         */
        
        // MARK: - 개선된 방식(클로저를 전달안하고싶고 옵저버블로 하고싶다면)
        deleteActionObservalble = deleteButton.rx.tap
            .debug("deleteButton 디버그")
            .compactMap({ [weak self] _ in
                self?.cellData?.id
            })
    }
```
deleteActionObservalble을 선언해주고 기존 방식을 주석처리하고 deleteActionObservalble을 연결해주었다. 나머지는 viewController에서 진행하면 된다.
<br/><br/><br/><br/>




```swift
// ✅ 2. (더 유연하지만 수동 캐스팅 필요 – RxCocoa)
rxTodosRelay
    .bind(to: myTableView.rx.items) { (tableView, row, element) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RxTodoCell.reuseIdentifier) as? RxTodoCell else { return UITableViewCell()}
        cell.configure(with: element)
        
        // MARK: - 셀의 delete버튼 선택되었을 때 액션을 여기서 처리
//                cell.deleteAction = { id in
//                    let currentTodos = self.rxTodosRelay.value
//                    let filteredTodos = currentTodos.filter { $0.id != id }
//                    self.rxTodosRelay.accept(filteredTodos)
//                }
        
        // MARK: - 개선방식(bind대신 map도 가능)
        cell.deleteActionObservalble
            .withUnretained(self)
            .debug("deleteActionObservalble")
            .map { vc, uuid in
                let currentTodos = self.rxTodosRelay.value
                let filteredTodos = currentTodos.filter { $0.id != uuid }
                return filteredTodos
            }
            .bind(to: self.rxTodosRelay)
            .disposed(by: self.disposeBag)

            
        
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
기존 deleteAction을 주석처리후 deleteActionObservalble을 연결해준다 이때 bind대신 map으로 해주어도 된다.
<br/><br/><br/><br/>

# 전체 코드
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
    var deleteActionObservalble: Observable<UUID> = Observable.empty()

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
        // isDoneSwitch.addTarget(self, action: #selector(handleIsDone), for: .valueChanged)
        // deleteButton.addTarget(self, action: #selector(handleDeleteButton), for: .touchUpInside)
    }
    
    // MARK: - Rx로 버튼 연결
    func setRx() {
        
        // MARK: - 초기 이벤트를 버리고 이후부터 모두 전달받겠다
        /*
        isDoneSwitch.rx.isOn
            .skip(1) // 처음 방출값 무시(초기값 세팅 이벤트 무시)
            .debug("isDoneSwitch 디버그")
            .bind(onNext: { [weak self] isOn in
                guard let self = self, let id = self.cellData?.id else { return }
                self.isDoneChange?(id, isOn)
            })
            .disposed(by: disposeBag)
         */
        
        // MARK: - 스위치가 valueChanged이벤트를 낼 때만 트리거 하겠다 & 해당시점은 isOn 값을 가져오겠다
        isDoneSwitch.rx.controlEvent(.valueChanged)
            .withLatestFrom(isDoneSwitch.rx.isOn) // 토글 후 최신값 가져오기
            .bind(onNext: { [weak self] isOn in
                guard let self = self, let id = self.cellData?.id else { return }
                self.isDoneChange?(id, isOn)
            })
            .disposed(by: disposeBag)
        
        // MARK: - 기존 방식
        /*
        deleteButton.rx.tap
            .debug("deleteButton 디버그")
            .bind(onNext: { [weak self] _ in
                guard let self = self, let id = self.cellData?.id else { return }
                self.deleteAction?(id)
            })
            .disposed(by: disposeBag)
         */
        
        // MARK: - 개선된 방식(클로저를 전달안하고싶고 옵저버블로 하고싶다면)
        deleteActionObservalble = deleteButton.rx.tap
            .debug("deleteButton 디버그")
            .compactMap({ [weak self] _ in
                self?.cellData?.id
            })
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
        self.disposeBag = DisposeBag() // MARK: - 이전 구독을 끊어주는 작업
    }
}

extension RxTodoCell {
    func configure(with todo: RxTodo) {
        self.cellData = todo
        titleLabel.text = todo.title

        let idString = String(todo.id.uuidString.prefix(10))
        idLabel.text = "ID: \(idString)"
        isDoneSwitch.isOn = todo.isDone
        setRx()
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

final class RxTodoViewController4: UIViewController {

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

        // ✅ 2. (더 유연하지만 수동 캐스팅 필요 – RxCocoa)
        rxTodosRelay
            .bind(to: myTableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RxTodoCell.reuseIdentifier) as? RxTodoCell else { return UITableViewCell()}
                cell.configure(with: element)
                
                // MARK: - 셀의 delete버튼 선택되었을 때 액션을 여기서 처리
//                cell.deleteAction = { id in
//                    let currentTodos = self.rxTodosRelay.value
//                    let filteredTodos = currentTodos.filter { $0.id != id }
//                    self.rxTodosRelay.accept(filteredTodos)
//                }
                
                // MARK: - 개선방식(bind대신 map도 가능)
                cell.deleteActionObservalble
                    .withUnretained(self)
                    .debug("deleteActionObservalble")
                    .map { vc, uuid in
                        let currentTodos = self.rxTodosRelay.value
                        let filteredTodos = currentTodos.filter { $0.id != uuid }
                        return filteredTodos
                    }
                    .bind(to: self.rxTodosRelay)
                    .disposed(by: self.disposeBag)

                   
                
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

# 성능 이슈 해결법
```swift
// 커스텀 셀
override func prepareForReuse() {
    super.prepareForReuse()
    print(#fileID, #function, #line, "prepareForReuse() - cellData.id: \(cellData?.id ?? UUID())")
    self.disposeBag = DisposeBag() // MARK: - 이전 구독을 끊어주는 작업을 통해 성능 개선
}

// ViewController
// MARK: - 개선방식(bind대신 map도 가능)
cell.deleteActionObservalble
    .withUnretained(self)
    .debug("deleteActionObservalble 디버그")
    .map { vc, uuid in
        let currentTodos = self.rxTodosRelay.value
        let filteredTodos = currentTodos.filter { $0.id != uuid }
        return filteredTodos
    }
    .bind(to: self.rxTodosRelay)
    .disposed(by: cell.disposeBag) // self.disposeBag -> ell.disposeBag
```

---
테이블뷰/컬렉션뷰는 셀을 재사용한다.
따라서 셀이 재사용될 때 기존 구독은 끊어줘야 한다.
그렇지 않으면 같은 셀 인스턴스에 구독이 계속 쌓여서 메모리 증가와 이벤트 중복이 발생한다.
해결법: prepareForReuse()에서 disposeBag = DisposeBag()으로 초기화하고, VC에서는 반드시 cell.disposeBag에 구독을 넣는다.

UITableViewCell은 재사용되므로, 셀이 다시 쓰일 때 이전 구독이 남아있으면 이벤트가 중복으로 전달되고 메모리도 증가한다. 이를 방지하기 위해 prepareForReuse()에서 disposeBag을 새로 생성하여 구독을 초기화하고, ViewController에서는 cell.disposeBag에 바인딩한다.