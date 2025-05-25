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
// 1번 방식
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

// 2번 방식(나는 이걸로 성공)
export PATH="$PATH:/opt/homebrew/bin"
if which swiftlint > /dev/null; then
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

<img src="{{ '/assets/img/2025-05-25-[UIKit]-SwiftLint/image-20250525230013507.png' | relative_url }}" alt="이미지" width="100%">
.swiftlint.yml파일을 만들고 빌드(commakd + R) 해보면 Sandbox 관련 오류가 발생한다.
<br/><br/>

<img src="{{ '/assets/img/2025-05-25-[UIKit]-SwiftLint/image-20250525230201996.png' | relative_url }}" alt="이미지" width="30%">

<img src="{{ '/assets/img/2025-05-25-[UIKit]-SwiftLint/image-20250525230341162.png' | relative_url }}" alt="이미지" width="100%">
Build Settings -> User Script Sandboxing 검색후 No로 변경해준다.
<br/><br/>

```swi
# swiftlint.yml

# 사용하지 않을 규칙 설정
disabled_rules:
  - force_cast               # 강제 형변환 사용 시 경고하지 않음
  - trailing_whitespace      # 줄 끝 공백에 대해 경고하지 않음

# 식별자(변수, 상수, 함수 이름 등)의 글자 수 제한
identifier_name:
  min_length: 1              # 최소 글자 수: 1자
  max_length: 40             # 최대 글자 수: 40자
  allowed_symbols: ["_"]     # 밑줄(_) 사용 허용
  validates_start_with_lowercase: true  # 소문자로 시작해야 함

# 사이클 복잡도 설정 (분기 개수)
cyclomatic_complexity:
  warning: 20                # 20 이상이면 경고
  error: 30                  # 30 이상이면 오류

# 함수 본문의 줄 수 제한
function_body_length:
  warning: 120               # 120줄 이상이면 경고
  error: 160                 # 160줄 이상이면 오류

# 클래스, 구조체, enum 등의 본문 줄 수 제한
type_body_length:
  warning: 500               # 500줄 이상이면 경고
  error: 1000                # 1000줄 이상이면 오류

# 한 줄의 최대 길이 제한
line_length:
  warning: 200               # 200자 이상이면 경고
  error: 300                 # 300자 이상이면 오류
  ignores_comments: true     # 주석은 길이 제한에서 제외
  ignores_urls: true         # URL은 길이 제한에서 제외


```

.yml코드 완성을 해주면 끝난다.
<br/><br/>

Reference

- https://dokit.tistory.com/64
- https://didu-story.tistory.com/274



