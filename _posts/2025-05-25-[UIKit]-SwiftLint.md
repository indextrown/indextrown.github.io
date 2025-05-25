---
title: "[UIKit] 프로젝트에 SwiftLint적용하기"
tags: 
- UIKit
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 프로젝트에 SwiftLint적용하기

<br/><br/>



  

  

```bash
brew install swiftlint
```

[공식 사이트](https://github.com/realm/SwiftLint)
설치는 SPM, Pod 등 여러 방법으로 설치할 수 있다. 다양한 프로젝트에 계속 사용하기 위해 HomeBrew로 설치 진행.
<br/><br/>

<img src="{{ '/assets/img/2025-05-25-[UIKit]-SwiftLint/image-20250525203357274.png' | relative_url }}" alt="이미지" width="100%">
New Run Script Phase 클릭하여 추가한다.
여기 컴파일(Run)시에 추가적으로 수행할 쉘 스크립트를 작성할 수 있다.
<br/><br/>



<img src="{{ '/assets/img/2025-05-25-[UIKit]-SwiftLint/image-20250525203727177.png' | relative_url }}" alt="이미지" width="100%">

```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

그다음 이 코드를 스크립트에 추가한다.
<br/><br/>

<img src="{{ '/assets/img/2025-05-25-[UIKit]-SwiftLint/image-20250525204358876.png' | relative_url }}" alt="이미지" width="100%">
Run Script라는 이름을 SwiftLint Script로 바꿔 준 다음, 위치를 Compile Sources위로 올려준다.
컴파일 하기 전에 스크립트를 실행시켜서 SwiftLint를 검사하는 것이 효율적이라고 순서를 이렇게 한다고 한다.
<br/><br/>



# Reference

- https://dokit.tistory.com/64
- https://didu-story.tistory.com/274




