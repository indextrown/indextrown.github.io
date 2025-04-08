---
title: "[하루한컷] 1. iOS 카카오 로그인"
tags: 
- Haruhancut
header: 
  teaser: 
typora-root-url: ../
---

## 1. 카카오 로그인
- https://developers.kakao.com/console/app 링크 접속
- 애플리케이션 추가
- 플랫폼 iOS 등록
- 네이티브 앱키를 Config.config파일에 저장


## 2. 파이어베이스 프로젝트 생성
- Authentication 생성
- Authentication에서 로그인 방법에서 카카오 로그인을 위해 OIDC 추가(이때 업그레이드 해줘야함)

<img src="/assets/img/2025-03-25-[Haruhancut]-Haruhancut-1/1.png" alt="clean1" style="width: 80%;">

<img src="/assets/img/2025-03-25-[Haruhancut]-Haruhancut-1/2.png" alt="clean1" style="width: 80%;">
- 프로젝트 설정에서 Google-Info.plist다운

## 3. 코드 설정
### AppDelegate.swift
```swift
import UIKit

// 파이어베이스
import FirebaseCore
import FirebaseAuth

// 카카오톡
import RxKakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    // 파이어베이스 설정
    FirebaseApp.configure()
    
    // 카카오톡 설정
    if let nativeAppKey: String = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String {
        RxKakaoSDK.initSDK(appKey: nativeAppKey)
    }
    
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // 카카오톡 로그인
    if (AuthApi.isKakaoTalkLoginUrl(url)) {
        return AuthController.rx.handleOpenUrl(url: url)
    }
    
    return false
}
```

### SceenDelegate.swift
```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    // 카카오 로그인
    if let url = URLContexts.first?.url {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            _ = AuthController.rx.handleOpenUrl(url: url)
        }
    }
}
```

### MVC.swift

```swift
import UIKit
import RxSwift

import RxKakaoSDKAuth
import KakaoSDKAuth

import RxKakaoSDKUser
import KakaoSDKUser


final class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private lazy var kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "Logo Kakao")
        config.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        config.imagePlacement = .leading    // 이미지가 텍스트 왼쪽에 위치
        config.imagePadding = 20            // 이미지와 텍스트 사이 간격
        config.title = "카카오로 계속하기"
        config.baseForegroundColor = .black
        // 폰트 설정
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        // 상태에 따라 배경색 바꾸기
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted {
                config?.baseBackgroundColor = UIColor(red: 0.8, green: 0.72, blue: 0.0, alpha: 1.0) // 눌렸을 때 진한 노랑
            } else {
                config?.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0) // 기본 노랑
            }
            button.configuration = config
        }
        button.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "Logo Apple")
        config.baseBackgroundColor = .white
        config.imagePlacement = .leading    // 이미지가 텍스트 왼쪽에 위치
        config.imagePadding = 20            // 이미지와 텍스트 사이 간격
        config.title = "Apple로 계속하기"
        config.baseForegroundColor = .black
        // 폰트 설정
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        // 상태에 따라 배경색 바꾸기
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted {
                config?.baseBackgroundColor = UIColor(white: 0.9, alpha: 1.0) // 눌렀을 때 약간 회색
            } else {
                config?.baseBackgroundColor = .white // 원래 흰색
            }
            button.configuration = config
        }
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
    // 카카오로그인버튼, 애플로그이넙튼 -> 스택뷰에 추가
    private lazy var stackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [
            kakaoLoginButton,
            appleLoginButton
        ])
        st.spacing = 10
        st.axis = .vertical
        st.distribution = .fillEqually
        st.alignment = .fill
        return st
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }
    
    func makeUI() {
        // 배경 색상
        view.backgroundColor = #colorLiteral(red: 0.09411741048, green: 0.09411782771, blue: 0.102702044, alpha: 1)
        
        // 스택뷰 -> 뷰에 추가
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 오토레이아웃 제약 추가
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    @objc private func handleKakaoLogin() {
        print("✅ 카카오 로그인 버튼 눌림")
        startKakaoLogin()

    }
    
    @objc private func handleAppleLogin() {
        print("✅ Apple 로그인 버튼 눌림")
    }
}

// MARK: - Observable
extension LoginViewController {
    
    func startKakaoLogin() {
        fetchKakaoOpenIdToken()
            .subscribe(onNext: { token in
                print("✅ 받은 토큰: \(token)")
            }, onError: { error in
                print("❌ 로그인 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func fetchKakaoOpenIdToken() -> Observable<String> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (앱 로그인)")
                    return idToken
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (웹 로그인)")
                    return idToken
                }
        }
    }
}

#Preview {
    LoginViewController()
}
```


### VIewController + ViewModel

### ViewController  
``` swift
import UIKit
import RxSwift

import RxKakaoSDKAuth
import KakaoSDKAuth

import RxKakaoSDKUser
import KakaoSDKUser


final class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()
    

    

    private func bindViewModel() {
        viewModel.loginSuccess
            .observe(on: MainScheduler.instance)
            .subscribe { token in
                print("로그인 성공: \(token)")
            }
            .disposed(by: disposeBag)
        
        viewModel.loginFailure
            .observe(on: MainScheduler.instance)
            .subscribe { errorMessage in
                print("로그인 실패: \(errorMessage)")
            }
            .disposed(by: disposeBag)
    }

    
    private lazy var kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "Logo Kakao")
        config.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        config.imagePlacement = .leading    // 이미지가 텍스트 왼쪽에 위치
        config.imagePadding = 20            // 이미지와 텍스트 사이 간격
        config.title = "카카오로 계속하기"
        config.baseForegroundColor = .black
        // 폰트 설정
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        // 상태에 따라 배경색 바꾸기
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted {
                config?.baseBackgroundColor = UIColor(red: 0.8, green: 0.72, blue: 0.0, alpha: 1.0) // 눌렸을 때 진한 노랑
            } else {
                config?.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0) // 기본 노랑
            }
            button.configuration = config
        }
        button.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "Logo Apple")
        config.baseBackgroundColor = .white
        config.imagePlacement = .leading    // 이미지가 텍스트 왼쪽에 위치
        config.imagePadding = 20            // 이미지와 텍스트 사이 간격
        config.title = "Apple로 계속하기"
        config.baseForegroundColor = .black
        // 폰트 설정
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        // 상태에 따라 배경색 바꾸기
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted {
                config?.baseBackgroundColor = UIColor(white: 0.9, alpha: 1.0) // 눌렀을 때 약간 회색
            } else {
                config?.baseBackgroundColor = .white // 원래 흰색
            }
            button.configuration = config
        }
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
    // 카카오로그인버튼, 애플로그이넙튼 -> 스택뷰에 추가
    private lazy var stackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [
            kakaoLoginButton,
            appleLoginButton
        ])
        st.spacing = 10
        st.axis = .vertical
        st.distribution = .fillEqually
        st.alignment = .fill
        return st
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        // 배경 색상
        view.backgroundColor = #colorLiteral(red: 0.09411741048, green: 0.09411782771, blue: 0.102702044, alpha: 1)
        
        // 스택뷰 -> 뷰에 추가
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 오토레이아웃 제약 추가
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    @objc private func handleKakaoLogin() {
        print("✅ 카카오 로그인 버튼 눌림")
        viewModel.loginWithKakao()
    }
    
    @objc private func handleAppleLogin() {
        print("✅ Apple 로그인 버튼 눌림")
    }
}

// MARK: - Observable
extension LoginViewController {
    
    func startKakaoLogin() {
        fetchKakaoOpenIdToken()
            .subscribe(onNext: { token in
                print("✅ 받은 토큰: \(token)")
            }, onError: { error in
                print("❌ 로그인 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func fetchKakaoOpenIdToken() -> Observable<String> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (앱 로그인)")
                    return idToken
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (웹 로그인)")
                    return idToken
                }
        }
    }
}

#Preview {
    LoginViewController()
}
```


### ViewModel
``` swift
import Foundation
import RxSwift
import RxCocoa
import KakaoSDKUser
import RxKakaoSDKUser
import RxKakaoSDKAuth
import KakaoSDKAuth

final class LoginViewModel {
    private let disposeBag = DisposeBag()
    
     // View에서 구독할 수 있도록 공개용 Subject
     let loginSuccess = PublishSubject<String>()
     let loginFailure = PublishSubject<String>()
    
    func loginWithKakao() {
        fetchKakaoOpenIdToken()
            .subscribe { token in
                self.loginSuccess.onNext(token)
            } onError: { error in
                self.loginFailure.onNext(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchKakaoOpenIdToken() -> Observable<String> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (앱 로그인)")
                    return idToken
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (웹 로그인)")
                    return idToken
                }
        }
    }
}
```



### VIewController + ViewModel + Results

### ViewController
``` swift
import UIKit
import RxSwift

import RxKakaoSDKAuth
import KakaoSDKAuth

import RxKakaoSDKUser
import KakaoSDKUser


final class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()
    
    private func bindViewModel() {
        viewModel.loginResult
            .observe(on: MainScheduler.instance)
            .subscribe { result in
                switch result {
                case .success(let token):
                    print("로그인 성공: \(token)")
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                }
            }.disposed(by: disposeBag)
    }
    
    private lazy var kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "Logo Kakao")
        config.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        config.imagePlacement = .leading    // 이미지가 텍스트 왼쪽에 위치
        config.imagePadding = 20            // 이미지와 텍스트 사이 간격
        config.title = "카카오로 계속하기"
        config.baseForegroundColor = .black
        // 폰트 설정
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        // 상태에 따라 배경색 바꾸기
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted {
                config?.baseBackgroundColor = UIColor(red: 0.8, green: 0.72, blue: 0.0, alpha: 1.0) // 눌렸을 때 진한 노랑
            } else {
                config?.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0) // 기본 노랑
            }
            button.configuration = config
        }
        button.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "Logo Apple")
        config.baseBackgroundColor = .white
        config.imagePlacement = .leading    // 이미지가 텍스트 왼쪽에 위치
        config.imagePadding = 20            // 이미지와 텍스트 사이 간격
        config.title = "Apple로 계속하기"
        config.baseForegroundColor = .black
        // 폰트 설정
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        // 상태에 따라 배경색 바꾸기
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isHighlighted {
                config?.baseBackgroundColor = UIColor(white: 0.9, alpha: 1.0) // 눌렀을 때 약간 회색
            } else {
                config?.baseBackgroundColor = .white // 원래 흰색
            }
            button.configuration = config
        }
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
    // 카카오로그인버튼, 애플로그이넙튼 -> 스택뷰에 추가
    private lazy var stackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [
            kakaoLoginButton,
            appleLoginButton
        ])
        st.spacing = 10
        st.axis = .vertical
        st.distribution = .fillEqually
        st.alignment = .fill
        return st
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        // 배경 색상
        view.backgroundColor = #colorLiteral(red: 0.09411741048, green: 0.09411782771, blue: 0.102702044, alpha: 1)
        
        // 스택뷰 -> 뷰에 추가
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 오토레이아웃 제약 추가
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    @objc private func handleKakaoLogin() {
        print("✅ 카카오 로그인 버튼 눌림")
        viewModel.loginWithKakao()
    }
    
    @objc private func handleAppleLogin() {
        print("✅ Apple 로그인 버튼 눌림")
    }
}

// MARK: - Observable
extension LoginViewController {
    
    func startKakaoLogin() {
        fetchKakaoOpenIdToken()
            .subscribe(onNext: { token in
                print("✅ 받은 토큰: \(token)")
            }, onError: { error in
                print("❌ 로그인 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func fetchKakaoOpenIdToken() -> Observable<String> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (앱 로그인)")
                    return idToken
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (웹 로그인)")
                    return idToken
                }
        }
    }
}

#Preview {
    LoginViewController()
}  
```


### ViewModel
``` swift
import Foundation
import RxSwift
import RxCocoa
import KakaoSDKUser
import RxKakaoSDKUser
import RxKakaoSDKAuth
import KakaoSDKAuth

final class LoginViewModel {
    private let disposeBag = DisposeBag()
    
    let loginResult = PublishSubject<Result<String, Error>>()
    
    func loginWithKakao() {
        fetchKakaoOpenIdToken()
            .subscribe { token in
                self.loginResult.onNext(.success(token))
            } onError: { error in
                self.loginResult.onNext(.failure(error))
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchKakaoOpenIdToken() -> Observable<String> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (앱 로그인)")
                    return idToken
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
                .map { oauthToken in
                    guard let idToken = oauthToken.idToken else {
                        // print("⚠️ idToken이 없습니다")
                        throw NSError(domain: "TokenError", code: -1, userInfo: [NSLocalizedDescriptionKey: "idToken이 없습니다."])
                    }
                    print("✅ idToken 추출 성공 (웹 로그인)")
                    return idToken
                }
        }
    }
}
```
