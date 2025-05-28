---
title: "[Library] Kingfisher"
tags: 
- Library
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# Kingfisher 기능
- 이미지 로드 기능(url을 넘겨주면 이미지를 로드한다)
- 이미지 캐시 기능
- UIImageView에 편리하게 round 처리 기능
- 이미지 다운로드 기능

## 이미지 로드 기능
```swift
private func loadImage() {
    guard let url = URL(string: "https:\\...")
    myImageView.kf.setImage(with: url)
}
```

## Indicator 기능
```swift
myImageView.kf.indicatorType = .activity
myImageView.kf.setImage(
    with: url,
    placeHolder: nil,
    options: nil.
    completionHandler: nil
)
```

## 예제코드
```swift
import UIKit
import Kingfisher

final class KingfisherViewController: UIViewController {
    
    private lazy var myImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        constraints()
        loadImage()
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(myImageView)
        myImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            myImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            myImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            myImageView.widthAnchor.constraint(equalToConstant: 300),
            myImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func loadImage() {
        guard let url = URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQv8sv01DK7BoJGaJMZ972ig5mQ_JBbqxdINQ&s") else { return }
                
        myImageView.kf.setImage(with: url)
    }
}

#Preview {
    KingfisherViewController()
}

```



<img src="{{ '/assets/img/2025-05-28-[Library]-Kingfisher/image-20250528220449050.png' | relative_url }}" alt="이미지" width="50%">

## Reference

- https://ios-development.tistory.com/793