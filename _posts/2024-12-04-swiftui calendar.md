---
title: "[SwiftUI] Calendar 구현"
tags:
- SwiftUI
category: ''
use_math: true
---

## SwiftUI에서 제공하는 캘린더

SwiftUI에서 제공하는 `DatePicker`를 사용하여 간단한 캘린더를 구현할 수 있습니다.

<table>
<tr>
<td>

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
    CalendarView()
}
```

</td>
<td>

![Calendar Preview](../assets/img/Calendar.png)

</td>
</tr>
</table>

위 코드와 이미지를 참고하여 SwiftUI에서 제공하는 `DatePicker`의 기본적인 사용법을 익혀보세요.
