---
title: "[RxSwift] 3. RX + MVVM + Input/output 패턴"
tags: 
- ReactiveX
- RxSwift
header: 
  teaser: 
typora-root-url: ../
---

# RX - MVVM 예시

### 기존 코드 - view와 viewModel 구분 없이 하나의 코드로 작성
```swift
import UIKit
import FirebaseAuth
import RxSwift

final class SettingViewController: UIViewController {
    
    private let disposeBaag = DisposeBag()
    
    weak var coordinator: HomeCoordinator?

    private let viewModel = SettingViewModel()
    private let homeViewModel: HomeViewModelType
    
    init(homeViewModel: HomeViewModelType) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Component
    private lazy var logoutBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        constraints()
    }
    
    // MARK: - UI Setting
    private func makeUI() {
        view.backgroundColor = .background
        
        [logoutBtn].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            logoutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

       
    @objc func logout() {
        do {
            UserDefaultsManager.shared.removeUser()
            UserDefaultsManager.shared.removeGroup()
            try Auth.auth().signOut()
            print("로그아웃 성공")
            coordinator?.showLogin()
            homeViewModel.stopObservingGroup()
            
            
        } catch let signOutError as NSError {
            print("로그아웃 실패: %@", signOutError)
        }
    }
}

#Preview {
    SettingViewController(homeViewModel: StubHomeViewModel(previewPost: .samplePosts[0]))
}
```

### 개선 코드 - view와 viewModel 구분 
```swift
// View
import UIKit
import FirebaseAuth
import RxSwift

final class SettingViewController: UIViewController {
    
    private let disposeBaag = DisposeBag()
    
    weak var coordinator: HomeCoordinator?

    private let viewModel = SettingViewModel()
    private let homeViewModel: HomeViewModelType
    
    init(homeViewModel: HomeViewModelType) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Component
    private lazy var logoutBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        return button
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        constraints()
        bindViewModdel()
    }
    
    // MARK: - UI Setting
    private func makeUI() {
        view.backgroundColor = .background
        
        [logoutBtn].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            logoutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - Binding
    private func bindViewModdel() {
        
        // [Input] 로그아웃 버튼 탭 이벤트를 ViewModel에 전달
        logoutBtn.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.logout()
            })
            .disposed(by: disposeBaag)
        
        // [Output] 로그아웃 처리 결과에 따라 UI 반응
        viewModel.logoutResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    print("로그아웃 성공")
                    self.coordinator?.showLogin()
                case .failure(let error):
                    print("로그아웃 실패: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBaag)
    }
}


// ViewModel
import FirebaseAuth
import RxSwift
import RxCocoa

protocol SettingViewModelType {
    func logout()
}

final class SettingViewModel: SettingViewModelType {
    
    // 로그아웃 결과 이벤트
    // 로그아웃 결과는 상태가 아닌 한번 일어나는 일회성 이벤트
    let logoutResult = PublishRelay<Result<Void, Error>>()
    
    func logout() {
        do {
            try Auth.auth().signOut()
            logoutResult.accept(.success(()))
            UserDefaultsManager.shared.removeUser()
            UserDefaultsManager.shared.removeGroup()
        } catch {
            logoutResult.accept(.failure(error))
        }
    }
}
```

### 개선 코드 - view와 viewModel 구분 및 Input/Output 패턴 추가
```swift
// View
import UIKit
import FirebaseAuth
import RxSwift

final class SettingViewController: UIViewController {
    
    private let disposeBaag = DisposeBag()
    
    weak var coordinator: HomeCoordinator?

    private let viewModel = SettingViewModel()
    private let homeViewModel: HomeViewModelType
    
    init(homeViewModel: HomeViewModelType) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Component
    private lazy var logoutBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        return button
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        constraints()
        bindViewModel()
    }
    
    // MARK: - UI Setting
    private func makeUI() {
        view.backgroundColor = .background
        
        [logoutBtn].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            logoutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        // Input: 버튼 탭 이벤트를 viewModel로 전달
        let input = SettingViewModel.Input(logoutTapped: logoutBtn.rx.tap.asObservable())
        
        // Output: transform으로부터 결과 스트림 반환
        let output = viewModel.transform(input: input)
            
        // Output에 따라 UI 처리
        output.logoutResult
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    print("로그아웃 성공")
                    self.coordinator?.showLogin()
                case .failure(let error):
                    print("로그아웃 실패: \(error.localizedDescription)")
                }
                
            }).disposed(by: disposeBaag)
    }
}


// ViewModel
import FirebaseAuth
import RxSwift
import RxCocoa

final class SettingViewModel {
    
    // Rx 리소스 해제를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    
    // View로부터 전달받을 사용자 이벤트 정의
    struct Input {
        // 로그아웃 버튼 탭이벤트
        let logoutTapped: Observable<Void>
    }
    
    // View에 전달할 출력 데이터 정의
    struct Output {
        // 로그아웃 성공 또는 실패에 대한 결과 스트림
        // Driver를 사용하여 메인스레드에서 UI 바인딩에 안전하게 처리
        let logoutResult: Driver<Result<Void, LoginError>>
    }
    
    /// Input을 받아 내부 로직을 수행 후 Output을 반환하는 함수
    /// - Parameter input: View에서 발생한 이벤트
    /// - Returns: 로그아웃 결과를 포함하는 Output
    func transform(input: Input) -> Output {
        
        // 로그아웃 버튼 탭시 로직을 수행하고 결과를 result로 반환
        let result = input.logoutTapped
            .map { _ -> Result<Void, LoginError> in
                do {
                    try Auth.auth().signOut()
                    UserDefaultsManager.shared.removeUser()
                    UserDefaultsManager.shared.removeGroup()
                    return .success(())
                } catch {
                    return .failure(.logoutError)
                }
                // 에러가 발생하더라도 UI가 멈추지 않고 기본 오류값으로 처리
            }.asDriver(onErrorJustReturn: .failure(.logoutError))
        
        // View에서 사용할 Output rntjd
        return Output(logoutResult: result)
    }
}
```