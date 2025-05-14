---
title: "[CodeLounge] Admob"
tags: 
- CodeLounge
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## SwiftUI에 Admob 광고 적용하기



## 1. Admob 설정 및 테스트 광고 ID

### https://admob.google.com/v2/home

- Admob 계정 생성(필수)
- 애플 앱스토어 등록(선택)
    - 어플을 앱스토어에 등록 후 Admob 작업을 진행하는 게 훨 씬 수월하다.

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514222826541.png' | relative_url }}" alt="이미지" width="100%">

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223016444.png' | relative_url }}" alt="이미지" width="100%">

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223225011.png' | relative_url }}" alt="이미지" width="100%">

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223435839.png' | relative_url }}" alt="이미지" width="100%">

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223505826.png' | relative_url }}" alt="이미지" width="100%">

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223554014.png' | relative_url }}" alt="이미지" width="100%">

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223724779.png' | relative_url }}" alt="이미지" width="100%">
ca-app-pub-xxxxx와 같은 형태의 App ID가 발급된다.

<img src="{{ '/assets/img/2025-05-14-[CodeLounge]-Admob/image-20250514223858027.png' | relative_url }}" alt="이미지" width="100%">

```swift
// SKAdNetworkItems - IDFA 없이도 광고 성과 추적 (Apple 정책 대응)
// NSUserTrackingUsageDescription - 사용자에게 추적 허용 요청 팝업 표시
// requestTrackingAuthorization() - 실제로 권한 요청하는 코드
// 기타 옵션들 - 광고 관련 기능(예: SKOverlay 등) 자동 지원 목적

<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4fzdc2evr5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4pfyvq9l8r.skadnetwork</string>
  </dict
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>2fnua5tdw4.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ydx93a7ass.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>5a6flpkh64.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>p78axxw29g.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v72qych5uu.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ludvb6z3bs.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cp8zw746q7.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3sh42y64q3.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>c6k4g5qg8m.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>s39g8k73mm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3qy4746246.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>f38h382jlk.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>hs6bdukanm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v4nxqhlyqp.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>wzmmz9fp6w.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>yclnxrl5pm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>t38b2kh725.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>7ug5zh24hu.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>gta9lk7p23.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>vutu7akeur.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>y5ghdn5j9k.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>n6fk4nfna4.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v9wttpbfk9.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>n38lu8286q.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>47vhws6wlr.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>kbd757ywx3.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>9t245vhmpl.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>eh6m2bh4zr.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>a2p9lx4jpn.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>22mmun2rn5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4468km3ulz.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>2u9pt9hc89.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>8s468mfl3y.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>klf5c3l5u5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ppxm28t8ap.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ecpz2srf59.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>uw77j35x4d.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>pwa73g5rt2.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>mlmmfzh3r3.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>578prtvx9j.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4dzt52r2t5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>e5fvkxwrpn.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>8c4e2ghe7u.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>zq492l623r.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3rd42ekr43.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3qcr597p9d.skadnetwork</string>
  </dict>
</array>
```

발급된 App ID를 Info.plist에 추가한다.



## 2. Google Mobile Ads 설치(SPM)

1. Xcode -> File -> Add Package
2. 입력 URL
    ```bash
    https://github.com/googleads/swift-package-manager-google-mobile-ads.git
    ```
3. 버전: 최신 선택
4. 메인 앱 타겟만 체크 -> Extension이 포함된 앱이더라도, 메인 앱에만 적용이 가능하다고 한다.

## 3. AppDelegate설정(광고 초기화)

```swift
// AppDelegate.swift
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		MobileAds.shared.start(completionHandler: nil) // 추가
        return true
    }
}
```



## Reference

- https://royzero.tistory.com/entry/SwiftUI-AdMob-적용하기
- https://velog.io/@heejin62/SwiftUI-앱에-AdMob-적용하기-근데-이제-Trouble-Shooting을-곁들인
- https://developers.google.com/admob/ios/test-ads?hl=ko
- https://actumn.tistory.com/99
- https://developers.google.com/admob/ios/privacy/strategies?hl=ko#skadnetwork
- https://dev-apple.tistory.com/30
- https://developers.google.com/admob/ios/test-ads?hl=ko#swift