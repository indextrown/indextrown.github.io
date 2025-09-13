---
title: "[RxDataSource] 3. Rx로 테이블 사용해보기"
tags: 
- ReactiveX
- RxDataSource
header: 
  teaser: 
typora-root-url: ../

---

# 정리
기본적인 Rx테이블 사용방법에 대해 코드로 작성하였다.  
셀을 Nib파일로 사용하거나 코드기반으로 사용함에 따라서 register 사용방식이 다르다는 것만 이해하면 된다. 다음 포스팅에서 RxDatasource로 CRUD로 진행해볼 예정이다.
```swift
// MARK: - Nib파일 사용한다면
let cellNib = UINib(nibName: "RxTodoCell", bundle: nil)
myTableView.register(cellNib, forCellReuseIdentifier: "RxTodoCell")

// MARK: - 코드기반 사용한다면
myTableView.register(RxTodoCell.self, forCellReuseIdentifier: "RxTodoCell")
```


# 전체코드
```swift
// Model
import Fakery
import UIKit

// MARK: - Model
struct RxTodo {
    let id: UUID = UUID()
    let title: String
    var isDone: Bool

    init(title: String,
         isDone: Bool = false
    ) {
        self.title = title
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
    var deleteActionObservable: Observable<UUID> = Observable.empty()
    var updateActionObservable: Observable<(id: UUID, newValue: Bool)> = Observable.empty()


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
        // setRx()
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

    private func setRx() {
        print(#fileID, #function, #line, "- ")
        updateActionObservable = isDoneSwitch
            .rx.isOn
            .skip(1)                 // 초기값 무시
            .debug("isDoneSwitch")
            /// nul을 제거하고 유효한 값만 방출하는 오퍼레이터
            /// self 또는 cellData 존재하지 않을 수 있어서 compactMap 사용
            .compactMap { [weak self] isOn -> (id: UUID, newValue: Bool)? in
                guard let self = self,
                      let inWrappedId = self.cellData?.id else {
                    return nil
                }
                // return (id: inWrappedId, newValue: self.isDoneSwitch.isOn)
                return (id: inWrappedId, newValue: isOn)
            }
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

final class RxTodoViewController: UIViewController {

    // MARK: - 구독에 대한 찌꺼기 처리
    var disposeBag =  DisposeBag()

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
        
        let data = Observable<[RxTodo]>.just(RxTodo.getDumies())
        
        // MARK: - Nib파일 사용한다면
        // let cellNib = UINib(nibName: "RxTodoCell", bundle: nil)
        // myTableView.register(cellNib, forCellReuseIdentifier: "RxTodoCell")
        
        // MARK: - 코드기반 사용한다면
        myTableView.register(RxTodoCell.self, forCellReuseIdentifier: "RxTodoCell")

        
        data.bind(to: myTableView.rx.items(cellIdentifier: "RxTodoCell", cellType: RxTodoCell.self)) {
            index, model, cell in
            cell.configure(with: model)
            
        }
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