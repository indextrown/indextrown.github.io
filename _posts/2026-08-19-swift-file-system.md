---
title: Swift File System
date: 2026-08-19
tags: []
---

<img src="/assets/img/2026-08-19-swift-file-system/pasted-image-20260819T081816-2.png" alt="붙여넣은 이미지" style="width: 37%;">

<img src="/assets/img/2026-08-19-swift-file-system/pasted-image-20260819T081943-2.png" alt="붙여넣은 이미지" style="width: 51%;">

iOS는 각 앱마다 전부 Sandbox화 되어 있습니다. Sandbox는 각 앱에 대한 파일, 네트워크 리소스, 하드웨어 등 앱의 접근을 제한하는 세분화된 제어 집합입니다.

새로운 앱을 설치하면 해당 앱을 위한 `sandbox`와 `하위 여러 컨테이너 디렉터리`를 생성합니다. 보안상의 이유로 앱은 샌드박스 이내의 디렉터리에 대해서만 접근할 수 있습니다.

&nbsp;

---

&nbsp;

#### Bundle

- 실행 가능한 코드, 이미지, 사운드, plist와 같은 관련 리소스를 한 곳에 모아 놓은 디렉터리입니다. 
- 애플리케이션, 프레임워크, 플러그인 같은 소프트웨어를 번들이라고 합니다.
- 임의 조작을 방지하기 위해 앱이 설치되는 동안 이 디렉토리는 signed됩니다(read-only)

#### 1. Bundle Container

- 앱 번들 이라고 부르며 앱의 Bundle을 보유합니다.
- read-only 권한으로 접근가능하고 iCloud, iTunes에 백업되지 않습니다.

```swift
// bundle 경로 출력하기
print(Bundle.main.bundleURL)
```

---

&nbsp;

#### 2. Data Container

<img src="/assets/img/2026-08-19-swift-file-system/pasted-image-20260819T083944-2.png" alt="붙여넣은 이미지" style="width: 55%;">

- 앱과 사용자를 위한 Data를 담고 있고 몇 개의 서브 디렉토리를 갖고 있습니다.

#### Documents

- 앱을 통해 생성된 사용자가 생성한 문서나 데이터 등을 저장합니다.
- 사용자의 수정/추가/삭제가 가능하고 개발자가 원한다면 특정 부분에 대해서만 접근을 제한할 수 있습니다.
- 사용자에게 노출되는 파일만 저장해야 하고 내부의 파일들은 Tunes와 iCloud에 백업이 될 수 있습니다.
- 참고: Realm은 기본적으로 Documents에 DB 파일을 저장하며, 사용자에게 노출할 필요가 없는 앱 내부 데이터라면 Library/Application Support로 경로를 변경해서 사용할 수 있습니다.

#### Library

- 사용자 데이터 파일을 제외한 모든 파일을 저장하는 디렉토리입니다.
- 하위 디렉토리를 생성할 수 있습니다.
  - Application Support
    - 앱이 생성하고 관리하는 데이터, 설정, 리소스 등이 저장되며 사용자에게 보여지지는 않지만 App에서 사용자 기록을 남기는 공간입니다. 
    - ex) CoreData, SwiftData
  - Caches
    - 없어져도 다시 생성/다운로드할 수 있는 캐시를 저장합니다.
    - ex) Kingfisher 이미지
  - Preferences
    - 애플리케이션 환경설정 데이터 저장합니다. 
    - ex) UserDefaults, CFPreferences
  - Snapshots
    - 앱이 백그라운드로 이동할 때 iOS가 마지막 화면 모습을 캡처해 두는 이미지가 저장됩니다.
    - applicationDidEnterBackground 호출후 현재 뷰에대한 스냅샷을 생성하고 Background에서 Foreground로 넘어올때 이 이미지를 사용합니다.

#### Tmp

- 앱에 재사용이 되지 않으며 장기간 유지할 필요가 없는 일시적으로 필요한 파일을 저장합니다.
- 시스템은 앱을 실행하고 있지 않을 때 주기적으로 파일을 삭제해서 디바이스 공간을 낭비하지 않도록 합니다.

&nbsp;

---

&nbsp;

#### 3. iCloud Container

- 런타임에 접근을 요청할 수 있는 추가 컨테이너입니다.

&nbsp;

---

## FileManager

파일 시스템의 파일과 디렉터리를 생성/조회/복사/이동/삭제하는 Foundation API 입니다. FileManager 자체가 저장소는 아니라 아래와 같이 앱이 접근할 수 있는 파일 시스템에서 어떤 디렉터리를 사용할 지 개발자가 직접 선택하고 파일을 관리하는 저수준 API 입니다.

Apple은 Documents, Application Support, Caches, tmp와 같은 표준 디렉터리를 제공하며 FileManager를 통해 해당 위치의 URL을 얻을 수 있습니다.

```bash
Data Container
├─ Documents                  ← .documentDirectory
│
├─ Library                    ← .libraryDirectory
│  ├─ Application Support     ← .applicationSupportDirectory
│  ├─ Caches                  ← .cachesDirectory
│  └─ Preferences
│
└─ tmp                        ← .temporaryDirectory
```

FileManager로 저장 위치를 선택할 때는 파일의 용도와 보존 필요성을 기준으로 합니다. 사용자가 직접 생성하거나 관리하는 파일은 Documents, 사용자에게 보여줄 필요는 없지만 앱이 계속 보존해야 하는 내부 데이터는 Library/Application Support, 삭제되어도 다시 생성하거나 다운로드할 수 있는 데이터는 Library/Caches, 작업 중 잠시만 필요한 파일은 tmp에 저장됩니다.

&nbsp;

#### 사용법

```swift
let fileManager = FileManager.default

// 저장할 예시 데이터
let text = "Hello, iOS!"
let data = text.data(using: .utf8)!


// 1. Documents
// 사용자가 생성하거나 직접 다루는 파일
let documentsURL = fileManager.urls(
    for: .documentDirectory,
    in: .userDomainMask
)[0]

let documentsFileURL = documentsURL
    .appendingPathComponent("sample.txt")
try data.write(to: documentsFileURL)


// 2. Library
// 앱 내부 데이터 전반을 저장하는 Library 디렉터리
let libraryURL = fileManager.urls(
    for: .libraryDirectory,
    in: .userDomainMask
)[0]

let libraryFileURL = libraryURL
    .appendingPathComponent("sample.txt")
try data.write(to: libraryFileURL)


// 3. Library/Application Support
// 앱 내부에서 계속 보존해야 하는 데이터
// ex) JSON, DB 파일 등
let applicationSupportURL = fileManager.urls(
    for: .applicationSupportDirectory,
    in: .userDomainMask
)[0]

let applicationSupportFileURL = applicationSupportURL
    .appendingPathComponent("sample.txt")
try data.write(to: applicationSupportFileURL)


// 4. Library/Caches
// 없어져도 다시 생성하거나 다운로드할 수 있는 데이터
// ex) 이미지 캐시
let cachesURL = fileManager.urls(
    for: .cachesDirectory,
    in: .userDomainMask
)[0]

let cachesFileURL = cachesURL
    .appendingPathComponent("sample.txt")
try data.write(to: cachesFileURL)


// 5. tmp
// 잠깐 사용하고 버려도 되는 임시 파일
let temporaryURL = fileManager.temporaryDirectory

let temporaryFileURL = temporaryURL
    .appendingPathComponent("sample.txt")
try data.write(to: temporaryFileURL)
```

&nbsp;

&nbsp;

---

&nbsp;

## 고수준 저장 방법

```bash

직접 파일 관리
│
└─ FileManager
   → 어느 디렉터리
   → 어떤 파일명
   → 어떤 형식
   을 사용할지 개발자가 직접 결정


더 높은 수준의 저장 추상화
│
├─ UserDefaults
│  └─ 설정값 저장
│
├─ Core Data
│  └─ 모델 데이터 영속성 관리
│
├─ SwiftData
│  └─ Swift 모델 데이터 영속성 관리
│
├─ Realm
│  └─ 로컬 데이터베이스
│
└─ Kingfisher
   └─ 이미지 캐싱

```

모든 데이터를 FileManager를 이용해 직접 파일로 관리할 필요는 없습니다. iOS에서는 저장 목적에 따라 고수준 추상화 API, 프레임워크, 라이브러리를 사용할 수 있습니다.

&nbsp;

---

&nbsp;

#### UserDefaults

앱의 간단한 환경설정 값을 저장하기 위한 Foundation API 입니다. 값을 설정하면 메모리의 값이 즉시 갱신되고 디스크에는 비동기적으로 기록됩니다.  
iOS의 UserDefaults 시스템은 앱 Sandbox 내부의 preference 데이터를 관리하며 전통적으로 앱의 Bundle Identifier를 기준으로 한 plist 형태의 저장소를 사용합니다.

#### 위치

```bash
Data Container
└─ Library
   └─ Preferences
      └─ UserDefaults가 관리하는 설정 데이터
```

&nbsp;

#### 예시

```swift
// 다크모드 여부 
// 온보딩 완료 여부 
// 사용자가 선택한 정렬 방식 
// 알림 설정 
// 간단한 String / Bool / Int 값
UserDefaults.standard.set(
    true,
    forKey: "isDarkMode"
)

let isDarkMode = UserDefaults.standard.bool(
    forKey: "isDarkMode"
)
```

개발자는 FileManager를 만들고 Preferences 폴더를 찾고 plist만들고 데이터 쓰기를 할 필요 없이 UserDefaults를 이용해 key-value를 저장하고 Preferences System이 저장 관리하는 구조입니다.

&nbsp;

---

&nbsp;

#### Core Data

Apple에서 제공하는 객체 그래프 관리 및 영속성 프레임워크입니다. 단순히 파일을 하나 저장하는 것이아니라 아래의 기능을 제공합니다.  
FileManager처럼 데이터를 직접 파일로 변환하고 저장하는 것이 아니라, 객체 단위로 데이터를 저장/조회/수정하고 실제 Persistent Store까지 관리해줍니다.  
Core Data 자체가 데이터베이스는 아니며 실제 데이터를 저장하기 위해 여러 종류의 Persistent Store를 사용할 수 있습니다.

#### 제공하는 기능

```bash
모델 저장
모델 조회
모델 수정/삭제
객체 간 Relationship
변경 사항 추적
Undo
Persistent Store 관리
```

#### Persistent Store

Persistent Store는 Core Data가 객체 데이터를 실제로 보관하는 저장 방식입니다.

#### Persistent Store 종류

- **SQLite Store**: 가장 일반적입니다. 디스크에 SQLite DB 파일 형태로 저장합니다. 실제 앱의 영구 데이터 저장에 주로 사용합니다.
- **Binary Store**: 객체 그래프를 하나의 바이너리 파일로 저장합니다. 작은 데이터에 적합하고, 전체 Store 단위로 다루는 성격이 강합니다.
- **In-Memory Store**: 디스크에 저장하지 않고 RAM에만 둡니다. 앱이 종료되면 사라지기 때문에 테스트나 임시 데이터에 주로 씁니다.
- **XML Store**: XML 파일로 저장합니다. 다만 **iOS에서는 지원하지 않고 macOS에서 사용**합니다.

#### 실제 파일의 위치

```bash
Data Container
└─ Library
   └─ Application Support
      └─ Core Data Persistent Store

Application Support
→ 어디에 저장하는가 (파일 시스템 위치)

SQLite / Binary / In-Memory
→ 어떤 방식으로 저장하는가 (Persistent Store)
```

SQLite나 Binary처럼 파일을 생성하는 Persistent Store는 앱의 파일 시스템 안에 위치하며, 일반적으로 앱 내부 데이터이므로 Library/Application Support에 둘 수 있습니다.

즉 FileManager처럼 user.json을 직접 만들고 jsonEncoder로 변환해서 특정 폴더에 저장하는 대신 User 객체를 저장해서 Core Data가 객체와 Persistend Store를 관리합니다.

&nbsp;

---

&nbsp;

#### SwiftData

iOS17부터 제공되는 Swift 친화적인 영속성 프레임워크입니다.  Core Data에서 모델을 정의하고 Context와 Fetch Request 등을 관리하던 방식을 Swift 문법에 맞게 단순화했습니다.

&nbsp;

```swift
@Model
final class User {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

// 저장
let user = User(
    name: "Dong",
    age: 27
)
modelContext.insert(user)

// 조회
@Query
var users: [User]
```

SwiftData는 기본적으로 SQL 데이터베이스에 모델 데이터를 영속화하며, 개발자가 underlying persistent store에 직접 접근하지 않고 `ModelContext`와 `ModelContainer`를 통해 데이터를 다루도록 추상화합니다.

또한 SwiftData의 기본 `DefaultStore`는 내부 저장 메커니즘으로 Core Data를 사용합니다.

&nbsp;

---

&nbsp;

#### Realm

객체 형태의 데이터를 로컬에 영속적으로 저장할 수 있는 데이터배이스입니다. Core Data나 SwiftData와 마찬가지로 구조화된 데이터를 관리할 때 사용하고 있습니다. realm은 자체 .realm 데이터베이스 파일을 사용합니다.

#### 위치

```bash
Data Container
└─ Documents
   └─ default.realm
```

#### FileURL

```bash
기본
Documents/default.realm

필요한 경우
↓
Realm.Configuration.fileURL 변경

Application Support/database.realm
App Group/database.realm
...
```

그리고 Realm의 fileURL을 변경하면 저장 위치를 다른 디렉터리나 App Group Container 등으로 지정할 수도 있습니다.

&nbsp;

## Reference

- [https://nsios.tistory.com/70](https://nsios.tistory.com/70)
- [https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html?utm\_source=chatgpt.com](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html?utm_source=chatgpt.com)
- [https://ios-development.tistory.com/339](https://ios-development.tistory.com/339)
- [https://leeari95.tistory.com/46](https://leeari95.tistory.com/46)
- [https://lxxyeon.tistory.com/222](https://lxxyeon.tistory.com/222)

&nbsp;

&nbsp;

&nbsp;