---
title: "[Haruhancut] Widget"
tags: 
- Haruhancut
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## Widget 도입
하루한컷 앱에 위젯을 추가하여 앱의 사진을 위젯으로 보여주려고 한다.

## 기존 번들 식별자에 App Groups 체크 및 저장
Identifiers에서 com.indextrown.Haruhancut를 찾아서 App Groups 체크박스를 추가 및 저장한다.

### 1. 위젯용 번들 식별자 준비
<img src="{{ '/assets/img/2025-05-30-[Haruhancut]-Widget/image-20250610145644562.png' | relative_url }}" alt="이미지" width="30%">
com.indextrown.Haruhancut.WidgetExtension로 번들 식별자를 만들고 App Groups만 체크해준다.
이제 프로비저닝 프로파일을 만들건데 편의를 위해 fastlane을 사용하겠다.


### 2. 프로비저닝 프로파일 만들기
```bash
# 기존 프로젝트가 이거면  
# match Development com.indextrown.Haruhancut

# 위젯은 아래와 같이 프로비저닝 프로파일을 만들어준다.   
# match Development com.indextrown.Haruhancut.WidgetExtension

# 개발용
fastlane match development --app_identifier "com.indextrown.Haruhancut.WidgetExtension"

# 배포용
fastlane match appstore --app_identifier "com.indextrown.Haruhancut.WidgetExtension"

# ⚠️Provisioning profile "" doesn't include signing ...발생시
fastlane match development --force
fastlane match appstore --force  
```

### 3. Widget Extension 생성

- Targets목록 아래 + 버튼 눌러서 WIdget Extension 생성한다.

### 4. App Groups 설정
기존 프로젝트와 WIdgetExtension 프로젝트에 각각 App Groups 추가한다.


## WidgetKit
- iOS 14부터 도입되었으며 SwiftUI로만 구현 가능하다.
- UIViewRepresentable 불가능하다.

### Widget COnfiguration(속성 편집에 대한 기능)
- Static configuration
    - 위젯 편집 항목이 나타나지 않으며, 사용자가 설정을 변경할 수 있는 옵션이 없다.
- Intent Configuration
    - 위젯 편집 기능을 통해 여러 Intent 값을 수정할 수 있도록 위젯을 구성할 수 있다.
    - iOS 17부터 AppIntentCOnfiguration으로 변경
- Activity Configuration
    - Live Activity

### Widget은 크게 4가지의 struct로 구성

<img src="{{ '/assets/img/2025-05-30-[Haruhancut]-Widget/image-20250610173933798.png' | relative_url }}" alt="이미지" width="30%">    

- Provider에서 사용자가 설정한 시간에 맞춰 위젯을 업데이트할 수 있게 한다  
- Entry에서 위젯에 필요한 데이터를 제공한다  
- EntryView는 Entry를 통해 구성하며, UI를 담당하는 역할과 유사하다  
- Widget에서는 static, intent, activity인지에 따라 최종적인 위젯을 구성한다  

## Reference
- https://velog.io/@s_sub/새싹-iOS-20주차