---
title: "[SwiftUI] TabView"
tags: 
- SwiftUI
use_math: true
header: 
  teaser: /assets/img/Swift/SwiftWhite.png
---

# 기본 TabView
- 사용목적: 여러 개의 화면을 탭으로 관리할 수 있다.
- 제약사항: TabView에는 자체적으로 배경색을 변경할 수 있는 modifier가 없다.
- UITabBar.appearance().backgroundColor = .white 같은 UIKit 코드를 사용해야 한다.
- 원하는 디자인을 만들기 위해 번거러운 작업이 필요하다.

<div style="display: flex; align-items: center;">
  <div style="flex: 1;">

{% highlight swift %}
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("홈 화면")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
                .tag(0)

            Text("검색 화면")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("검색")
                }
                .tag(1)

            Text("설정 화면")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
                .tag(2)
        }
    }
}
{% endhighlight %}

  </div>
  <div style="flex: 1; text-align: center;">
    <img src="/assets/img/SwiftUI/[SwiftUI] TabView.png" alt="TabView 예제" width="300">
  </div>
</div>

# 커스텀 탭뷰

### 커스텁 탭뷰 타입
```swift
enum MainTabType: CaseIterable {
    case csView
    case iosView
    case aosView
    case profileView
    
    var title: String {
        switch self {
        case .csView:
            return "CS"
        case .iosView:
            return "iOS"
        case .aosView:
            return "aOS"
        case .profileView:
            return "profile"
        }
    }
    
    func imageName(isSelected: Bool) -> String {
        switch self {
        case .csView:
            return isSelected ? "desktopcomputer" : "desktopcomputer"
        case .iosView:
            return isSelected ? "apple.logo" : "apple.logo"
        case .aosView:
            return isSelected ? "smartphone" : "smartphone"
        case .profileView:
            return isSelected ? "person.fill" : "person"
        }
    }
}
```
### 커스텀 탭뷰
```swift
struct CustomMaintabView: View {
    
    @State private var selectedTab: MainTabType = .csView
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 0) {
                switch selectedTab {
                case .csView:
                    CSView()
                case .iosView:
                    iOSView()
                case .aosView:
                    AosView()
                case .profileView:
                    ProfileView()
                }
            }

            VStack(spacing: 0) {
                Spacer()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                HStack {
                    ForEach(MainTabType.allCases, id: \.self) { tab in
                        
                        Spacer()
                            .frame(width: 10)
                        
                        VStack {
                            Spacer()
                                .frame(height: 5)
                            Image(systemName: tab.imageName(isSelected: selectedTab == tab))
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                            Text(tab.title)
                                .font(.caption2)
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                            Spacer()
                                .frame(height: 20)
                        }
                        .padding(.horizontal, 20) // 좌우 터치 영역 추가
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle()) // 터치 가능한 영역을 명시적으로 지정
                        .onTapGesture {
                            // 진동 발생
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            selectedTab = tab
                        }
                        Spacer()
                            .frame(width: 10)
                    }
                    .frame(height: 100) // 고정 높이
                }
                .background(.black)
            }
        }
        .ignoresSafeArea(edges: .all)
    }
}
```