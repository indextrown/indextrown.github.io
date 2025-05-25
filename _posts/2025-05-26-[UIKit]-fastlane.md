---
title: "[Xcode] fastlane 에러 해결"
tags: 
- Xcode
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# fastlane 에러 해결

## 깃 저장소에서 관련 내용 삭제
```bash
## 각 명령에서 질문 나오면 y 눌러주기 -> 깃허브에서 제거됨
fastlane match nuke distribution
fastlane match nuke development
```

```bash
## 인증서 & 프로비저닝 프로파일 생성 -> 깃허브에 저장됨
fastlane match appstore
fastlane match development
```

```bash
## 팀원이 같은 인증서를 내려받을 때
fastlane match appstore --readonly
fastlane match development --readonly
```