---

title: "[TableView] 3. 스토리보드로 커스텀 테이블뷰 구현하기"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="커스텀셀" width="30%"> -->

## 스토리보드로 커스텀 테이블뷰 구현하기

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView3/image-20250509003319693.png' | relative_url }}" alt="커스텀셀" width="30%"> 
위 사진은 **1. 테이블뷰 예제**에서 구현한 방식이다. 사진처럼 셀 스타일이 기본 셀이라서 커스텀을 할 수 없다. 그래서 보통 UITableViewCell을 상속받아 커스텀 Cell Class를 만들어 입맛대로 만든다. 커스텀 Cell 적용 방식이 **1. 스토리보드, 2. Nib파일, 3. 코드 방식** 총 3가지가 있는데 이번 포스팅에서는 스토리보드 방식으로 진행한다.





