---
title: "[SwiftUI] Calendar 구현"
tags:
- SwiftUI
category: ''
use_math: true
---

## SwiftUI에서 제공하는 캘린더

<div style="display: flex; align-items: flex-start; gap: 20px;">
    <!-- 코드 섹션 -->
    <div style="flex: 1;">

```swift   
struct Calendar: View {
    @State private var selectedDate = Date() // 선택된 날짜를 저장할 변수

    var body: some View {
        VStack {
            Text("선택한 날짜: \(selectedDate, formatter: dateFormatter)")
                .padding()

            DatePicker(
                "날짜 선택",
                selection: $selectedDate,
                displayedComponents: [.date] // 날짜만 표시 (시간은 제외)
            )
            .datePickerStyle(GraphicalDatePickerStyle()) // 그래픽 스타일
            .environment(\.locale, Locale(identifier: "ko_KR")) // 한국 로케일 설정
            .padding()

            Spacer()
        }
        .navigationTitle("캘린더")
        .padding()
    }

    // 날짜 형식을 지정하기 위한 Formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    ProfileView()
}    
```

</div>
    <div style="flex: 1;">
        <img src="../assets/img/Calendar.png" alt="Calendar.png" style="max-width: 100%; border: 1px solid #ccc;" />
    </div>
</div>

<!-- ![](/assets/img/Calendar.png){: .align-center}    -->
