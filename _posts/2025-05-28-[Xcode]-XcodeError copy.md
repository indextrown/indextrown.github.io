---
title: "[Xcode] 라이브러리 설치 에"
tags: 
- Xcode
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 해결법

✅ Package.resolved 삭제 명령어
rm -f ./Package.resolved
rm -f ./EUMMEYO.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
두 파일이 둘 다 존재할 수 있으니, 둘 다 삭제하는 게 좋습니다.
✅ 이후 조치
Xcode 완전히 종료 (⌘ + Q)
다시 Xcode 실행
메뉴에서 → File → Packages → Resolve Package Versions 선택
🔁 그래도 안 되면?
Xcode > Preferences > Locations > DerivedData 열기 → 전체 삭제
또는 터미널에서:
rm -rf ~/Library/Developer/Xcode/DerivedData


