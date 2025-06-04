---
title: "[CustomView] 커스텀 캘린더뷰 만들기"
tags: 
- CustomView
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# iOS 16부터 기본 제공되는 캘린더

### 기본 캘린더
```swift
import UIKit

final class BasicCalendarViewController: UIViewController {
    
    // MARK: - UI Conponent
    private lazy var calendarView: UICalendarView = {
        let view = UICalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        /// 점이나 뱃지 표시 등 달력 Custom 하기 위해 설정해야 하는 속성
        view.wantsDateDecorations = true
        return view
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        constraints()
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(calendarView)
    }
    
    private func constraints() {
        let calendarViewConstraints = [
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(calendarViewConstraints)
    }
}
```

### UICalendarSelectionSingleDateDelegate를 설정하여 날짜 선택시 이모지 표시
```swift 
import UIKit

final class BasicCalendarViewController: UIViewController {
    
    /// 현재 선택된 날짜
    var selectedDate: DateComponents? = nil
    
    // MARK: - UI Conponent
    /// 날짜별 데코레이션(점, 이모지 등)을 지원하는 캘린더 뷰
    private lazy var calendarView: UICalendarView = {
        let view = UICalendarView()
        view.locale = Locale(identifier: "ko_KR")
        view.translatesAutoresizingMaskIntoConstraints = false
        /// 점이나 뱃지 표시 등 달력 Custom 하기 위해 설정해야 하는 속성
        view.wantsDateDecorations = true
        return view
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeUI()
        self.constraints()
        self.setCalendar()
    }
    
    /// 캘린더 delegate 및 날짜 선택 동작 설정
    private func setCalendar() {
        self.calendarView.delegate = self
        
        /// 한 번에 한 날짜만 선택 가능
        let dateSection = UICalendarSelectionSingleDate(delegate: self)
        /// 선택 이벤트(날짜 선택 시 콜백)를 BasicCalendarViewController에서 직접 처리하겠다
        calendarView.selectionBehavior = dateSection
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(calendarView)
    }
    
    private func constraints() {
        let calendarViewConstraints = [
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(calendarViewConstraints)
    }
    
    /// 특정 날짜 셀만 데코레이션 새로고침(이모지 추가)
    private func reloadDateView(date: Date?) {
        if date == nil { return }
        let calendar = Calendar.current
        calendarView.reloadDecorations(forDateComponents: [calendar.dateComponents([.day, .month, .year], from: date!)], animated: true)
    }
}

// MARK: - 캘린더 Delegate
extension BasicCalendarViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    /// 날짜별 데코레이션 표시 커스텀(필요시 구현)
    /// 선택된 날자의 셀에 이모지로 커스텀 데코레이션을 보여준다
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let selectedDate = selectedDate, selectedDate == dateComponents {
            return .customView {
                let label = UILabel()
                label.text = "🐶"
                label.textAlignment = .center
                return label
            }
        }
        return nil
    }
    
    /// 날짜 선택 시 동작
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        /// selection 객체에 저장
        selection.setSelected(dateComponents, animated: true)
        /// selectedDate 프로퍼티를 업데이트
        selectedDate = dateComponents
        /// 선택한 날짜 셀의 데코레이션만 새로고침(🐶 이모지가 바로 반영되게)
        reloadDateView(date: Calendar.current.date(from: dateComponents!))
    }
}
```

<img src="{{ '/assets/img/2025-05-30-[CustomView]-CalendarView/image-20250530145103523.png' | relative_url }}" alt="이미지" width="50%">

<div align="center">참고: 한국어로 설정해도 시뮬레이터에서는 요일이 영어로 보이는 버그가 있다.
</div>


<img src="{{ '/assets/img/2025-05-30-[CustomView]-CalendarView/image-20250604141453258.png' | relative_url }}" alt="이미지" width="50%">



### 커스텀 캘린더

```swift
//
//  1. CustomCalendar.swift
//  UIComponentTutorial
//
//  Created by 김동현 on 6/4/25.
//

import UIKit
import FSCalendar

final class CustomCalendarVC: UIViewController {
    
    // MARK: - UI Component
    private lazy var calendarView: FSCalendar = {
        let calendar = FSCalendar()
        
        // 첫 열을 월요일로 설정
        calendar.firstWeekday = 2
        
        // week 또는 month 가능
        calendar.scope = .month
        
        calendar.scrollEnabled = true
        calendar.locale = Locale(identifier: "ko_KR")
        
        // 현재 달의 날짜들만 표기하도록 설정
        calendar.placeholderType = .none
        
        // 헤더뷰 설정
        calendar.headerHeight = 55
        calendar.appearance.headerDateFormat = "MM월"
        calendar.appearance.headerTitleColor = .black
        
        // 요일 UI 설정
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 17, weight: .light)
        calendar.appearance.weekdayTextColor = .black
        
        // 날짜별 UI 설정
        calendar.appearance.titleTodayColor = .white
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .light)
        calendar.appearance.subtitleFont = UIFont.systemFont(ofSize: 10, weight: .light)
        calendar.appearance.subtitleTodayColor = .systemYellow
        calendar.appearance.todayColor = .gray
        
        // 일요일 라벨의 textColor는 red로 설정
        calendar.calendarWeekdayView.weekdayLabels.last!.textColor = .red
        return calendar
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        constraints()
    }
    
    // MARK: - UI Setting
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
}

#Preview {
    CustomCalendarVC()
}
```

## Reference

- https://ohwhatisthis.tistory.com/23
- https://maramincho.tistory.com/106
- https://dongdida.tistory.com/128
- https://velog.io/@xanxnu/iOSSwift-UICalendarView-사용해-보기
- https://lsj8706.tistory.com/4