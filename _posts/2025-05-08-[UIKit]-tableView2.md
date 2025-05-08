---
title: "[TableView] 2. 스토리보드로 여러 화면 분기하기"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="커스텀셀" width="30%"> -->

## 스토리보드로 여러 화면 분기하기

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508214538806.png' | relative_url }}" alt="커스텀셀" width="70%">



### 필요 파일

- MainViewController
- Main.storyboard

MainStoryboard에서 Command + Shift + L을 눌러서 Storyboard를 추가하고 우측 하단의 Embeded In을 눌러서 Navigation Controller(화면 이동 관할)을 추가한다.   
<br>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508215655099.png' | relative_url }}" alt="커스텀셀" width="70%">
다음으로 현재 Main스토리보드에서 어떤 화변이 먼저 실행이 될 지 정해줘야 한다. Attribute Inspector에서 is Initial View Controller 클릭해서 첫 시작 뷰 컨트롤러를 설정해준다.
<br>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508220915956.png' | relative_url }}" alt="커스텀셀" width="70%">
filled버튼들을 추가하고 전체 버튼들을 드래그하여 Embed In 클릭 후 Stack View를 눌러준다 그러면 버튼들이 StackView로 묶인다. 버튼들을 Stack에 같은 크기로 채우려면 alignment를 fill로 해주고 Distribution은 Fill Equally로 해준다. 그 이후 StackView를 SafeArea로 드래그하여 horizontal, vertical 각각 center 지정해준다. 주황색이 뜨면 새로고침 눌러준다.
<br/>

alignment(정렬)는 요소들이 한 축을 기준으로 어떻게 정렬될지를 결정한다.
`horizontal` stack view일 경우:
- `.leading` → 왼쪽 정렬
- `.center` → 가운데 정렬
- `.trailing` → 오른쪽 정렬
- `.top`, `.bottom` → 요소들의 **수직 위치** 정렬 방식도 있음
<br/>

distribution(분배)는 여러 UI 요소를 Stack View 안에서 얼마나 넓게 어떻게 나눌지 결정한다.
`.fill` → 가능한 공간만큼 채움
`.fillEqually` → 모든 요소가 **동일한 크기**로 공간 분배
`.fillProportionally` → 각 요소의 **원래 크기 비율**에 따라 분배
`.equalSpacing` → 요소들 사이 간격을 **동일하게 유지**
`.equalCentering` → 중심점 기준으로 **균등하게 배치**
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508222122754.png' | relative_url }}" alt="커스텀셀" width="70%">
Default버튼을 우측 ViewController쪽으로 드래그하여 Show를 눌러준다 이때 ViewController는 CustomClass에서 Class설정을 해줘서 ViewController코드와 연결해둬야한다. 그러면 Default를 누르면 화면이동이 된다. 동일하게 나머지 버튼들도 ViewController를 만들어서 연결해준다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/스크린샷 2025-05-08 오후 10.56.48(2).png' | relative_url }}" alt="커스텀셀" width="70%">
완성하면 이렇게 되는데 MainStoryBoard 파일 안에서 View가 많아지게 되면 상당히 무거워지기 때문에 작업이 힘들어 진다. 추천하는 방식은 Reference 방식이다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508230321228.png' | relative_url }}" alt="커스텀셀" width="70%">
StoryboardList.storyboard를 만들고 만들면 제공되는 ViewController를 없앤다. 그럼 이렇게 빈 화면이 나온다. 그리고 MainStoryboard에 있는 Storyboard 타이틀 VC를 Control + X로 잘라내어 StoryboardList.storyboard에 붙여넣는다
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508230739196.png' | relative_url }}" alt="커스텀셀" width="70%">
그리고 나서 타이틀을 설정해준다. 그리고 MainStoryboard로 가서 Command + Shift + L로 reference검색해서 드래그한다. 이는 스토리보드에 대한 참조(메모리 주소)이다. 즉 이로 서로 연걸이 되게끔 할 수 있다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508231122558.png' | relative_url }}" alt="커스텀셀" width="70%">
스토리보드Id를 설정한다 보통 클래스이름과 동일하게 적는다. 여기서 사진에는 표시 안되어 있지만 Use StoryboardId 체크 클릭해준다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508231515586.png' | relative_url }}" alt="커스텀셀" width="70%">
<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508231740354.png' | relative_url }}" alt="커스텀셀" width="70%">
스토리보드와 스토리보드Id를 적어준다. 그리고 Identifier도 동일하게 스토리보드Id를 적어준다.
<br/>

<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508232019316.png' | relative_url }}" alt="커스텀셀" width="70%">
최종적으로 참조에 드래그를 해서 show로 지정해준다. 이러면 이전의 방식과 동일한 방식이다. 이렇게 하면 작업이 용이해진다. 나머지 코드들도 동일하게 해주자. 
<br/>



## 최종화면
<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/스크린샷 2025-05-08 오후 11.46.20(2).png' | relative_url }}" alt="커스텀셀" width="70%">
<img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/image-20250508234707587.png' | relative_url }}" alt="커스텀셀" width="30%">
