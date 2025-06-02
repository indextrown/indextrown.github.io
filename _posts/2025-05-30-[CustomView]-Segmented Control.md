---
title: "[CustomView] Segmented Control"
tags: 
- CustomView
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# UIKit 세그먼 컨트롤 커스텀 사용법



<div style="display: flex; justify-content: center; gap: 20px;">
  <img src="{{ '/assets/img/2025-05-30-[CustomView]-Segmented Control/image-20250602141034002.png' | relative_url }}" alt="셀1" width="50%">
  <img src="{{ '/assets/img/2025-05-30-[CustomView]-Segmented Control/image-20250602141057458.png' | relative_url }}" alt="셀2" width="50%">
</div>

```swift
import UIKit

final class SegmentControlVC: UIViewController {
    
    // MARK: - UI Component
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "피드", at: 0, animated: true)
        segment.insertSegment(withTitle: "캘린더", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        
        /// 탭의 글자 색상 및 폰트 커스텀 (일반/선택 상태별로 다르게)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.systemGray2,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)
        ], for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)
        ], for: .selected)
        
        /// Segment 선택되었을 때 변하는 tintColor 제거
        segment.selectedSegmentTintColor = .clear
        
        /// divider 제거
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        /// 값이 변경될 때 underline 애니메이션을 위한 타겟 액션 등록
        segment.addTarget(self, action: #selector(changeUnderLinePosition), for: .valueChanged)
        return segment
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        constraints()
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        
        [segmentControl, underLineView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 세그먼트 회색 이미지를 흰색으로 설정
        segmentControl.setBackgroundImage(imageWithColor(.white), for: .normal, barMetrics: .default)
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            /// segmentControl: 화면 중앙, 가로 폭은 safeArea의 40%, 높이 20
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            segmentControl.heightAnchor.constraint(equalToConstant: 20),
            
            /// underLineView: 세그먼트 하단에 배치, 가로폭은 세그먼트의 50% (즉, 한 탭과 크기 동일), 높이 2
            underLineView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10),
            underLineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor),
            underLineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 0.5),
            underLineView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    @objc
    private func changeUnderLinePosition(_ segment: UISegmentedControl) {
        let halfWidth = segmentControl.frame.width / 2
        let xPosition = segmentControl.frame.origin.x + (halfWidth * CGFloat(segmentControl.selectedSegmentIndex))
                
        UIView.animate(withDuration: 0.2) {
            self.underLineView.frame.origin.x = xPosition
        }
    }
}

extension SegmentControlVC {
    // 흰색 배경 이미지를 만들어주는 함수
    /// 원하는 색의 1x32 사이즈 이미지를 만드는 함수 (세그먼트 배경 이미지용)
    private func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 32)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

#Preview  {
    SegmentControlVC()
}
```

```swift
import UIKit

final class SegmentControlVC: UIViewController {
    
    // MARK: - UI Component
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "피드", at: 0, animated: true)
        segment.insertSegment(withTitle: "캘린더", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        
        /// 탭의 글자 색상 및 폰트 커스텀 (일반/선택 상태별로 다르게)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.systemGray2,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)
        ], for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)
        ], for: .selected)
        
        /// Segment 선택되었을 때 변하는 tintColor 제거
        segment.selectedSegmentTintColor = .clear
        
        /// divider 제거
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        /// 값이 변경될 때 underline 애니메이션을 위한 타겟 액션 등록
        segment.addTarget(self, action: #selector(changeUnderLinePosition), for: .valueChanged)
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segment
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let aView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        return view
    }()
    
    private let bView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        return view
    }()
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        constraints()
        updateViewForSelectedSegment()
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        
        [segmentControl, underLineView, aView, bView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 세그먼트 회색 이미지를 흰색으로 설정
        segmentControl.setBackgroundImage(imageWithColor(.white), for: .normal, barMetrics: .default)
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            /// segmentControl: 화면 중앙, 가로 폭은 safeArea의 40%, 높이 20
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            segmentControl.heightAnchor.constraint(equalToConstant: 20),
            
            /// underLineView: 세그먼트 하단에 배치, 가로폭은 세그먼트의 50% (즉, 한 탭과 크기 동일), 높이 2
            underLineView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10),
            underLineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor),
            underLineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 0.5),
            underLineView.heightAnchor.constraint(equalToConstant: 2),
            
            // aView
            aView.topAnchor.constraint(equalTo: underLineView.bottomAnchor, constant: 0),
            aView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            aView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            aView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // bView
            bView.topAnchor.constraint(equalTo: underLineView.bottomAnchor, constant: 0),
            bView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
}

extension SegmentControlVC {
    
    
    /// 세그먼트 값 변경 시 언더라인(Indicator) 이동 애니메이션
    @objc
    private func changeUnderLinePosition(_ segment: UISegmentedControl) {
        let halfWidth = segmentControl.frame.width / 2
        let xPosition = segmentControl.frame.origin.x + (halfWidth * CGFloat(segmentControl.selectedSegmentIndex))
                
        UIView.animate(withDuration: 0.2) {
            self.underLineView.frame.origin.x = xPosition
        }
    }
    
    // 흰색 배경 이미지를 만들어주는 함수
    /// 원하는 색의 1x32 사이즈 이미지를 만드는 함수 (세그먼트 배경 이미지용)
    private func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 32)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    // 세그먼트 탭 전환시 뷰 보이기 /숨기기
    @objc private func segmentChanged(_ segment: UISegmentedControl) {
        updateViewForSelectedSegment()
    }
    
    /// 현재 선택된 인덱스에 따라 aView/bView만 보이도록 처리
    private func updateViewForSelectedSegment() {
        aView.isHidden = segmentControl.selectedSegmentIndex != 0
        bView.isHidden = segmentControl.selectedSegmentIndex != 1
    }
}

#Preview  {
    SegmentControlVC()
}
```

## 커스텀View
```swift
/// 상단 탭바+Indicator 커스텀 UIView (재사용 가능)
final class SegmentedTabBarView: UIView {

    // MARK: - Properties
    private let segmentControl: UISegmentedControl
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainWhite
        return view
    }()
    
    private var underlineLeadingConstraint: NSLayoutConstraint!

    // 선택된 인덱스 콜백
    var onIndexChanged: ((Int) -> Void)?

    // MARK: - Init
    init(items: [String]) {
        self.segmentControl = UISegmentedControl(items: items)
        super.init(frame: .zero)
        makeUI()
        constraints()
        setSelected(index: 0, animated: false)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private func makeUI() {
        // 커스텀 스타일
        segmentControl.selectedSegmentIndex = 0
        
        // 미선택시
        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.systemGray2,
            .font: UIFont.hcFont(.light, size: 20.scaled)
        ], for: .normal)
        
        // 선택시
        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.mainWhite,
            .font: UIFont.hcFont(.bold, size: 20.scaled)
        ], for: .selected)
        
        segmentControl.selectedSegmentTintColor = .clear
        segmentControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segmentControl.setBackgroundImage(imageWithColor(.mainBlack), for: .normal, barMetrics: .default)

        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        addSubview(segmentControl)
        addSubview(underlineView)
    }

    private func constraints() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor),

            underlineView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5),
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            underlineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments))
        ])
        // 밑줄의 leading 제약조건은 따로 저장해 이동시킨다
        underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor)
        underlineLeadingConstraint.isActive = true
    }

    // MARK: - Action
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        setSelected(index: sender.selectedSegmentIndex, animated: true)
        onIndexChanged?(sender.selectedSegmentIndex)
    }

    // 인덱스 바꾸기 + 밑줄 이동
    func setSelected(index: Int, animated: Bool) {
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        underlineLeadingConstraint.constant = segmentWidth * CGFloat(index)
        if animated {
            UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
        } else {
            self.layoutIfNeeded()
        }
        segmentControl.selectedSegmentIndex = index
    }

    // 유틸: 흰색 배경 이미지 만들기
    private func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 32)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

// SegmentedTabBarView.swift
extension SegmentedTabBarView {
    /// 원하는 segment의 title을 동적으로 변경
    func setSegmentTitle(_ title: String, at index: Int) {
        segmentControl.setTitle(title, forSegmentAt: index)
    }
}
```



# Reference
- https://chokotingchock.tistory.com/entry/스위프트-UIKit-custom-segmented-control
- https://velog.io/@panther222128/UISegmentedControl-and-UITableView
- https://ios-development.tistory.com/962