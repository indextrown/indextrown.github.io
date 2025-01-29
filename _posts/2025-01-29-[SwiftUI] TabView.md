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

<div style="display: flex; align-items: center;">
  <div style="flex: 1;">
    <pre><code class="language-swift">
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
    </code></pre>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="/assets/img/Animation.png" alt="TabView 예제" width="300">
  </div>
</div>
