---
title: "[CustomView] Segmented Control 커스텀 with PageViewController"
tags: 
- CustomView
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

<div style="display: flex; justify-content: center; gap: 20px;">
  <img src="{{ '/assets/img/2025-05-30-[CustomView]-Segmented Control2/image-20250603015019716.png' | relative_url }}" alt="셀1" width="50%">
  <img src="{{ '/assets/img/2025-05-30-[CustomView]-Segmented Control2/image-20250603015140369.png' | relative_url }}" alt="셀2" width="50%">
</div>

# UIKit 세그먼 컨트롤 커스텀 사용법

```swift
//
//  CustomSegmentControlVC.swift
//  UIComponentTutorial
//
//  Created by 김동현 on 6/2/25.
//

import UIKit

final class CustomSegmentControl: UISegmentedControl {

    // MARK: - UI
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private var underlineLeadingConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!
    private let underlineHeight: CGFloat = 4.0 // 원하는 두께로 변경

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.removeBackgroundAndDivider()

        underlineView.backgroundColor = .black
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.layer.cornerRadius = 0
        addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            
        ])
        

        // 초기 제약조건
        let width = bounds.width > 0 ? bounds.width / CGFloat(numberOfSegments) : 0
        underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(equalToConstant: width)

        NSLayoutConstraint.activate([
            underlineLeadingConstraint,
            underlineWidthConstraint,
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 항상 최신 크기/위치 반영
        updateUnderlinePosition(animated: false)
    }

    func updateUnderlinePosition(animated: Bool = true) {
        let width = bounds.width / CGFloat(numberOfSegments)
        let leading = CGFloat(selectedSegmentIndex) * width

        underlineWidthConstraint.constant = width
        underlineLeadingConstraint.constant = leading

        if animated {
            UIView.animate(withDuration: 0.15) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }

    private func removeBackgroundAndDivider() {
        let image = UIImage()
        setBackgroundImage(image, for: .normal, barMetrics: .default)
        setBackgroundImage(image, for: .selected, barMetrics: .default)
        setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
}



final class CustomSegmentControlVC: UIViewController {

    private let segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["첫번째", "두번째", "세번째"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        // 스타일 커스텀
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ], for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.invertedSystemBackground,
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
        ], for: .selected)
        segment.selectedSegmentTintColor = .clear
        let image = UIImage()
        segment.setBackgroundImage(image, for: .normal, barMetrics: .default)
        segment.setBackgroundImage(image, for: .selected, barMetrics: .default)
        segment.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        segment.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        return segment
    }()

    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .invertedSystemBackground
        view.layer.cornerRadius = 0
        return view
    }()

    private let vc1: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        return vc
    }()
    private let vc2: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .blue
        return vc
    }()
    private let vc3: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .green
        return vc
    }()
    var dataViewControllers: [UIViewController] { [vc1, vc2, vc3] }

    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
        vc.delegate = self
        vc.dataSource = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()

    var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
            moveUnderline(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.underlineView)
        self.view.addSubview(self.pageViewController.view)

        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),

            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
        ])

        // 언더라인의 높이와 최초 위치 설정 (width, x는 viewDidLayoutSubviews에서)
        underlineView.frame = CGRect(x: 0, y: 0, width: 0, height: 4)

        segmentedControl.addTarget(self, action: #selector(changeValue(control:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        changeValue(control: segmentedControl)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 최초 렌더링 시 언더라인 위치 정확히 세팅
        moveUnderline(animated: false)
        // 언더라인의 y위치를 세그먼트 하단에 맞추기
        let segFrame = segmentedControl.frame
        underlineView.frame.origin.y = segFrame.maxY - 4
        underlineView.frame.size.height = 4
    }

    @objc private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }

    /// 언더라인 이동 (frame 연산)
    private func moveUnderline(animated: Bool) {
        let segFrame = segmentedControl.frame
        let segmentCount = CGFloat(segmentedControl.numberOfSegments)
        let segmentWidth = segFrame.width / segmentCount
        let targetX = segFrame.minX + segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex)

        let newFrame = CGRect(x: targetX,
                              y: segFrame.maxY - 4,
                              width: segmentWidth,
                              height: 4)
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.underlineView.frame = newFrame
            }
        } else {
            self.underlineView.frame = newFrame
        }
    }
}

extension CustomSegmentControlVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.dataViewControllers.firstIndex(of: viewController), index - 1 >= 0 else { return nil }
        return self.dataViewControllers[index - 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.dataViewControllers.firstIndex(of: viewController), index + 1 < self.dataViewControllers.count else { return nil }
        return self.dataViewControllers[index + 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?[0], let index = self.dataViewControllers.firstIndex(of: viewController) else { return }
        self.currentPage = index
        self.segmentedControl.selectedSegmentIndex = index
        self.moveUnderline(animated: true)
    }
}

#Preview {
    CustomSegmentControlVC()
}

extension UIColor {
    static var invertedSystemBackground: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // 다크 모드에서는 밝은 배경색
                return .white
            default:
                // 라이트 모드에서는 어두운 배경색
                return .black
            }
        }
    }
}

```


## Reference
- https://ios-development.tistory.com/963