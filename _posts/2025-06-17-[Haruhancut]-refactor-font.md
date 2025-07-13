---
title: "[Haruhancut] 1. 하루한컷 리팩토링 - 폰트, 색상 세팅"
tags: 
- Haruhancut
header: 
  teaser: 
typora-root-url: ../


---

<!-- https://www.youtube.com/watch?v=sBybUm8yVbI&list=PLgOlaPUIbynpuq9GKCwAedgWkkPm2Wo8v&index=18 -->

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->



<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## Font 세팅

<img src="{{ '/assets/img/2025-06-17-[Haruhancut]-refactor-font/image-20250617133256915.png' | relative_url }}" alt="이미지" width="30%">
- Fonts 폴더에 다운받은 폰트를 저장한다.
<br/><br/>

```swift
<key>UIAppFonts</key>
<array>
    <string>NanumMyeongjo-Regular.ttf</string>
    <string>RacingSansOne-Regular.ttf</string>
    <string>Pretendard-Black.otf</string>
    <string>Pretendard-Bold.otf</string>
    <string>Pretendard-ExtraBold.otf</string>
    <string>Pretendard-ExtraLight.otf</string>
    <string>Pretendard-Light.otf</string>
    <string>Pretendard-Medium.otf</string>
    <string>Pretendard-Regular.otf</string>
    <string>Pretendard-SemiBold.otf</string>
    <string>Pretendard-Thin.otf</string>
</array>
```
- Info파일에 아래 내용 추가한다.
<br/><br/>

```swift
import UIKit

extension UIFont {
    enum HCFont: String {
        case black = "Pretendard-Black"
        case bold = "Pretendard-Bold"
        case extraBold = "Pretendard-ExtraBold"
        case extraLight = "Pretendard-ExtraLight"
        case light = "Pretendard-Light"
        case medium = "Pretendard-Medium"
        case regular = "Pretendard-Regular"
        case semiBold = "Pretendard-SemiBold"
        case thin = "Pretendard-Thin"
    }
}

// 커스텀 폰트
extension UIFont {
    static func hcFont(font: HCFont, size: CGFloat) -> UIFont {
        return UIFont(name: font.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

// 하루한컷 프리셋 폰트
extension UIFont {
    static var titleFont: UIFont {
        hcFont(font: .bold, size: 24)
    }

    static var bodyFont: UIFont {
        hcFont(font: .regular, size: 16)
    }

    static var captionFont: UIFont {
        hcFont(font: .medium, size: 12)
    }
}


// ----------------------------------------------------------------- //
// SwiftUI 대응

import SwiftUI

extension Font {
    static var hcTitle: Font {
        Font.custom("Pretendard-Bold", size: 24)
    }

    static var hcBody: Font {
        Font.custom("Pretendard-Regular", size: 16)
    }

    static var hcCaption: Font {
        Font.custom("Pretendard-Medium", size: 12)
    }
}


final class FontView: UIView {
    
    // MARK: - UI Component
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .hcFont(font: .bold, size: 24)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "title size 24"
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .hcFont(font: .regular, size: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "body size 16"
        return label
    }()
    
    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = .hcFont(font: .medium, size: 12)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "caption size 12"
        return label
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, captionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(hStackView)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

#Preview {
    FontView()
}
```
- FontSystem 코드 작성한다
<br/><br/>

```swift
import UIKit

// MARK: - Hex -> UIColor
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIColor {
    
    // MARK: - Login
    static let kakao = UIColor(hex: "#FEE500")
    static let apple = UIColor(hex: "#FFFFFF")
    static let kakaoTapped = UIColor(hex: "#CCC200")
    static let appleTapped = UIColor(hex: "#E5E5E5")
    
    // MARK: - Main
    static let background = UIColor(hex: "#1A1A1A")
    static let mainBlack = UIColor(hex: "#161717")
    static let mainWhite = UIColor(hex: "#f1f1f1")
    static let buttonTapped = UIColor(hex: "#131315")
    static let hcColor = UIColor.init(hex: "AAD1E7")
    
    // MARK: - Gray
    static let Gray000 = UIColor(hex: "#EFEFEF")
    static let Gray100 = UIColor(hex: "#B0AEB3")
    static let Gray200 = UIColor(hex: "#8B888F")
    static let Gray300 = UIColor(hex: "#67646C")
    static let Gray500 = UIColor(hex: "#454348")
    static let Gray700 = UIColor(hex: "#252427")
    static let Gray900 = UIColor(hex: "#111113")
}
```