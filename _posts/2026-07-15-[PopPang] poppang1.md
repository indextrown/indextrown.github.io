---
# title: "모바일 개발자 2명이 iOS·Android를 함께 개발하는 방법: React Native 모듈 도입기"
title: "네이티브로 개발하던 팝팡에 React Native를 더한 이유"
tags:
  - React Native
  - iOS
  - Android
  - AI
header:
  teaser: /assets/img/2026-07-15-PopPang-RN/react-native-module-ai-hero.png
typora-root-url: ../
---

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/react-native-module-ai-hero.png' | relative_url }}" alt="하나의 공통 모듈을 iOS와 Android 앱에 연결하고 AI로 실험하는 구조" width="100%">
  <figcaption>네이티브 앱은 유지하고, 새 기능 중 네이티브 상태 의존성이 낮은 영역을 React Native 모듈로 개발했습니다.</figcaption>
</figure>

> 팝팡에서는 iOS 개발자 1명과 Android 개발자 1명이 각자의 플랫폼에서 같은 기능을 따로 구현하고 있었습니다. 이 중 네이티브 상태 의존성이 낮은 새 기능을 React Native 모듈로 분리해 함께 개발할 수 있는 환경을 만들었습니다. 익숙하지 않았던 빌드 영역은 AI로 빠르게 탐색하되, 모든 가설은 실제 빌드와 앱 동작으로 검증했습니다.

## 한눈에 보기

| 구분 | 내용 |
| --- | --- |
| 문제 | 두 모바일 개발자가 같은 기능을 각자 담당하는 플랫폼에서 따로 구현하고 있었습니다. |
| 제약 | 기존 네이티브 앱과 Swift Package Manager·Gradle 기반 개발 환경은 유지해야 했습니다. |
| 해결 | React Native를 별도 프로젝트에서 빌드해 iOS에는 XCFramework, Android에는 AAR과 로컬 Maven 저장소로 배포했습니다. |
| AI 활용 | 최신 React Native의 Prebuild 구조를 분석하고, 빌드 가설과 스크립트 초안을 빠르게 실험하는 데 활용했습니다. |
| 결과 | 네이티브 상태 의존성이 낮은 새 기능을 두 개발자가 공통 모듈에서 함께 만들며, 해당 영역의 구현 단위를 플랫폼별 2회에서 1회로 줄였습니다. |

## 팝팡 React Native 도입 배경
<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/team-composition.svg' | relative_url }}" alt="디자이너, 백엔드 개발자, iOS 개발자, Android 개발자가 각 한 명씩인 팝팡 팀 구성" style="display: block; width: 85%; max-width: 100%; margin: 0 auto;">
  <figcaption>팝팡은 디자이너, 백엔드, iOS, Android 담당자가 한 명씩인 4인 팀입니다.</figcaption>
</figure>

팝팡은 iOS 앱을 Swift로, Android 앱을 Kotlin으로 개발합니다. 팀은 디자이너·백엔드·iOS·Android 담당자 각 1명으로 구성되어 있으며, 모바일 개발자는 각자 한 플랫폼의 기능 개발과 유지보수를 모두 맡습니다.

개발 초기에는 팀원 모두가 취업을 준비하고 있어 하루 8시간 이상을 팝팡 개발에 쓸 수 있었습니다. 같은 기능을 iOS와 Android에서 각각 구현해도 일정을 감당할 수 있었고, 새로운 기능도 빠르게 추가할 수 있었습니다.

팀원들이 취업한 뒤에는 상황이 달라졌습니다. 평일에 팝팡 개발에 쓸 수 있는 시간이 하루 최대 2시간으로 줄었습니다. 같은 기능을 두 플랫폼에서 반복해서 만들면서 서비스 운영과 새 기능 개발을 병행하기는 어려웠습니다.

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/before-after.svg' | relative_url }}" alt="React Native 도입 전에는 같은 기능을 두 번 구현하고 도입 후에는 공통 모듈을 한 번 구현하는 비교" width="100%">
  <figcaption>공통 화면의 구현 단위를 두 번에서 한 번으로 줄였습니다.</figcaption>
</figure>

이 글에서 말하는 생산성 약 2배는 공통 화면의 UI와 기능 흐름을 구현하는 작업에 한정한 수치입니다. 네이티브 연동과 플랫폼별 QA까지 포함한 전체 개발 기간이 정확히 절반으로 줄었다는 의미는 아닙니다.

## 네이티브 상태 의존성이 낮은 새 기능부터 적용했습니다

React Native로 iOS와 Android 앱 전체를 다시 만들 생각은 없었습니다. 이미 안정적으로 동작하는 네이티브 앱은 유지하면서, 두 번 만들던 새 기능을 공통 코드로 개발하는 것이 목표였습니다.

기존 화면부터 옮기면 React Native 도입과 회귀 테스트를 동시에 진행해야 합니다. 연동 방식을 빠르게 검증하고 기존 기능에 미치는 영향을 줄이기 위해 새로 만드는 기능부터 적용했습니다. 그중에서도 로그인 세션이나 앱 전역 내비게이션처럼 네이티브 앱이 관리하는 상태에 덜 의존하는 기능을 골랐습니다.

첫 대상은 팝업 제보와 팝업 제보 관리 화면이었습니다. 두 화면은 필요한 입력값을 받으면 모듈 안에서 흐름을 처리할 수 있고, 완료나 뒤로가기 같은 결과만 네이티브 앱에 돌려주면 됩니다. 앱 전역의 탭 구조와 로그인 흐름을 건드리지 않고도 React Native를 시험하기에 적합했습니다.

### 기존 앱과 공통 모듈의 책임을 나눴습니다

책임을 나누는 기준은 두 플랫폼에서 같은 방식으로 동작하는지가 아니라, 네이티브 앱의 상태를 얼마나 알아야 하는지였습니다. 로그인 세션, 앱 전역 내비게이션, 네이티브 SDK, 앱 생명주기는 기존 앱에 남겼습니다. 필요한 입력값만 받아 내부 흐름을 처리하고 결과를 돌려줄 수 있는 새 기능은 React Native 모듈이 맡았습니다.

| 네이티브 앱 | React Native 모듈 |
| --- | --- |
| 로그인 세션, 앱 전역 내비게이션, 네이티브 SDK, 앱 생명주기 | 입력값으로 시작할 수 있는 신규 화면 UI, 화면 상태, 기능 내부 흐름 |

### 연결 지점은 입력값과 결과 이벤트로 제한했습니다

React Native 화면이 네이티브 앱의 상태를 직접 알기 시작하면 둘 사이의 연결은 금세 복잡해집니다. 그래서 네이티브 앱이 React Native에 전달하는 값을 세 가지로 제한했습니다.

네이티브 앱은 열려는 화면을 나타내는 `feature`, 사용자를 식별하는 `userUuid`, 네이티브와 연결할 이벤트를 지정하는 `nativeEvents`만 전달합니다. React Native 모듈은 전달받은 값으로 화면 안의 기능을 처리합니다.

처리가 끝나면 제보 완료나 뒤로가기처럼 네이티브 앱이 알아야 하는 결과만 이벤트로 돌려보냅니다. 화면을 닫거나 이전 화면을 갱신하는 일은 앱 전체의 화면 흐름을 관리하는 네이티브 앱이 맡습니다.

| 방향 | 전달하는 값 |
| --- | --- |
| Native → React Native | `feature`, `userUuid`, `nativeEvents` |
| React Native → Native | 제보 완료, 뒤로가기와 같은 네이티브 이벤트 |

## 기존 앱의 개발 환경을 유지해야 했습니다

React Native 모듈을 도입하더라도 기존 앱의 프로젝트 구조와 의존성 관리 방식은 바꾸지 않기로 했습니다. iOS 앱은 Swift Package Manager를, Android 앱은 Gradle을 계속 쓰기로 했습니다.

React Native 빌드는 별도 프로젝트에서 처리하고, 네이티브 앱에는 완성된 산출물만 전달하도록 설계했습니다.

### 팝팡이 React Native 공식 통합 방식을 선택하지 않은 이유

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/official-vs-poppang-integration-folder.svg' | relative_url }}" alt="React Native 공식 통합 방식과 팝팡이 선택한 모듈 배포 방식을 폴더 구조로 비교" width="100%">
  <figcaption>공식 방식은 React Native 프로젝트를 중심으로 기존 앱을 배치합니다. 팝팡은 기존 앱을 유지한 채, 미리 빌드한 모듈만 각 앱에 연결하는 방식을 선택했습니다.</figcaption>
</figure>

[React Native 공식 문서](https://reactnative.dev/docs/integration-with-existing-apps.html)는 React Native 프로젝트를 개발 환경의 중심에 둡니다. 기존 iOS 프로젝트는 `ios` 폴더에, Android 프로젝트는 `android` 폴더에 배치하고 React Native를 앱 빌드에 직접 연결합니다.

React Native가 앱 빌드에 직접 참여해야 한다면 자연스러운 구조입니다. 하지만 기존 iOS·Android 앱을 유지하면서 필요한 새 기능만 모듈로 추가하려던 팝팡의 요구와는 맞지 않았습니다. 선택하지 않은 이유는 두 가지였습니다.

첫째, 프로젝트 구조가 팝팡이 원한 방향과 반대였습니다. 일부 기능을 추가하기 위해 기존 앱 전체를 React Native 프로젝트 아래로 옮겨야 했습니다. 기존 앱에 모듈을 넣으려던 일이 오히려 모듈 프로젝트를 중심으로 기존 앱을 재구성하는 일이 됐습니다.

둘째, 기존 앱이 관리해야 할 의존성과 빌드 설정이 늘어났습니다. React Native를 직접 통합하면 iOS 앱에는 `Gemfile`, `Podfile`, CocoaPods가 추가되고, Android 앱에는 React Native Gradle Plugin과 런타임 설정이 들어갑니다.

특히 Swift Package Manager와 CocoaPods는 서로의 의존성을 알지 못합니다. 두 도구를 함께 사용하면 중복 의존성과 빌드 충돌을 별도로 관리해야 합니다. [토스 기술 블로그의 사례](https://toss.tech/article/react-native-without-cocoapods)에서도 이 문제를 자세히 설명합니다.

기존 앱의 구조와 의존성 관리 방식을 유지한다는 기준으로 세 가지 방식을 비교했습니다.

| 검토한 방식 | 얻을 수 있는 것 | 판단 |
| --- | --- | --- |
| 전체 앱을 React Native로 전환 | 공통 코드 범위를 가장 넓힐 수 있음 | 안정화된 네이티브 기능까지 다시 구현하고 검증해야 하므로 제외 |
| 공식 가이드대로 기존 앱에 직접 통합 | 공식 생태계와 설정을 그대로 사용할 수 있음 | 기존 앱의 구조가 바뀌고 의존성 관리 범위가 늘어나므로 제외 |
| React Native를 모듈로 Prebuild | 기존 앱의 구조와 의존성 관리 방식을 유지할 수 있음 | 빌드 체계를 직접 관리하는 비용을 감수하고 선택 |

팝팡은 플랫폼별 산출물을 직접 관리하더라도 기존 앱을 흔들지 않는 세 번째 방식을 선택했습니다. React Native 빌드에 필요한 도구는 별도 프로젝트에 모으고, 각 앱에는 완성된 모듈만 배포하기로 했습니다.

### 토스의 Prebuild 방식은 최신 버전에 그대로 적용되지 않았습니다

[토스 기술 블로그의 Prebuild 방식](https://toss.tech/article/react-native-without-cocoapods)은 팝팡의 요구에 가까웠습니다. CocoaPods는 빌드 전용 프로젝트에서만 사용하고 실제 앱에는 미리 만든 산출물만 전달합니다. 이렇게 하면 기존 앱의 의존성 관리 도구를 바꾸지 않아도 됩니다.

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/poppang-rn-prebuild.png' | relative_url }}" alt="React Native 코드를 Android AAR과 iOS XCFramework로 빌드해 각 앱에서 사용하는 Prebuild 구조" width="100%">
  <figcaption><a href="https://github.com/team-PopPang/PopPang-RN">PopPang-RN</a>에서 정리한 초기 Prebuild 구상입니다. 실제 구현에서는 Package Registry 대신 GitHub Release를 사용하고, Android에는 AAR을 포함한 로컬 Maven 저장소를 배포합니다.</figcaption>
</figure>

그러나 팝팡이 사용한 React Native 버전은 0.86이었습니다. 토스 글의 예시는 더 오래된 버전을 기준으로 작성되어 있어, 소개된 빌드 스크립트를 그대로 적용할 수 없었습니다. 최신 React Native가 제공하는 Prebuild 산출물은 Swift Package에서 바로 동작하지 않았습니다.

React Native 0.86은 [미리 빌드한 React Core를 `React.xcframework`로 제공](https://github.com/facebook/react-native/blob/v0.86.0/packages/react-native/React-Core-prebuilt.podspec)합니다. 공통 의존성인 `ReactNativeDependencies.xcframework`와 Hermes도 미리 빌드된 XCFramework로 받을 수 있습니다.

따라서 최신 환경에서는 React Native 코드를 모두 처음부터 다시 컴파일할 필요가 없습니다. 대신 CocoaPods가 내려받은 Prebuild 프레임워크와 팝팡의 네이티브 모듈을 하나의 배포 단위로 다시 묶어야 했습니다.

`PopPang-RN`에서는 두 환경 변수로 최신 Prebuild 경로를 지정했습니다.

```bash
export RCT_USE_PREBUILT_RNCORE=1
export RCT_USE_RN_DEP=1
```

### Swift Package에 전달되지 않는 헤더 경로를 복구했습니다

환경 변수를 설정하고 프레임워크 파일을 복사하는 것만으로는 빌드할 수 없었습니다. Prebuild된 React Core는 CocoaPods가 만든 가상 파일 시스템(Virtual File System, VFS)의 헤더 매핑과 검색 경로를 전제로 동작합니다.

그러나 Swift Package의 binary target은 이를 사용하는 앱에 CocoaPods의 설정을 넘기지 않습니다. `React.xcframework`만 배포하면 프레임워크 파일은 있어도 React가 참조하는 Folly·Hermes·React Native 의존성 헤더와 모듈을 찾지 못합니다.

Swift Package에서도 필요한 헤더를 찾을 수 있도록 빌드 과정을 세 단계로 구성했습니다.

1. **플랫폼별 프레임워크를 만듭니다.** [`New_build_xcframeworks.sh`](https://github.com/team-PopPang/PopPang-RN/blob/main/react_native_prebuild/New_build_xcframeworks.sh)는 `pod install`로 Prebuild 프레임워크를 내려받습니다. 이어서 팝팡의 네이티브 모듈을 시뮬레이터용과 디바이스용으로 각각 archive합니다.
2. **VFS 헤더를 실제 파일로 옮깁니다.** [`materialize_react_vfs_headers.rb`](https://github.com/team-PopPang/PopPang-RN/blob/main/react_native_prebuild/materialize_react_vfs_headers.rb)는 VFS와 의존성 헤더를 `React.framework/Headers` 아래에 배치합니다. import 경로를 `React` 이름공간으로 통일하고, `React_RCTAppDelegate`에는 Swift Package가 요구하는 모듈 이름을 제공하는 얇은 shim을 만듭니다.
3. **빌드부터 배포까지 한 번에 실행합니다.** [`release-rn.sh`](https://github.com/team-PopPang/PopPang-RN/blob/main/scripts/release-rn.sh)는 iOS·Android용 JavaScript bundle과 플랫폼별 네이티브 패키지를 한 번에 만듭니다. 완성된 산출물은 GitHub Release에 게시합니다.

[v0.1.0 릴리스](https://github.com/team-PopPang/PopPang-RN/releases/tag/v0.1.0)에는 다음 네 가지 산출물이 포함됩니다.

| 플랫폼 | 네이티브 패키지 | JavaScript bundle |
| --- | --- | --- |
| iOS | `poppang-rn-spm-v0.1.0.zip` | `poppang-rn-ios-bundle-v0.1.0.zip` |
| Android | `poppang-rn-android-maven-v0.1.0.zip` | `poppang-rn-android-bundle-v0.1.0.zip` |

React Native에 필요한 CocoaPods, npm 의존성, 빌드 설정은 [PopPang-RN](https://github.com/team-PopPang/PopPang-RN)에만 남겼습니다. iOS와 Android 앱은 React Native 프로젝트나 `node_modules`를 직접 포함하지 않고, 검증된 릴리스 버전만 올려 공통 모듈을 적용합니다.

## AI로 낯선 빌드 영역에서 가설을 세우고 실험하는 속도를 높였습니다

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/ai-validation-loop.svg' | relative_url }}" alt="문제를 정의하고 AI로 탐색한 뒤 개발자가 실제 빌드로 검증하고 릴리스를 자동화한 과정" width="100%">
  <figcaption>AI로 가설을 세우고 반복하는 속도를 높였으며, 실제 빌드와 앱 동작으로 검증했습니다.</figcaption>
</figure>

React Native 0.86의 Prebuild와 CocoaPods의 VFS 헤더는 팀에 익숙한 영역이 아니었습니다. 먼저 `React.xcframework`가 어떤 헤더를 필요로 하는지, CocoaPods가 만든 설정 가운데 무엇이 Swift Package에 전달되지 않는지 확인해야 했습니다.

AI로 React Native 0.76 기반 사례와 0.86 소스를 비교하며 `React.xcframework`가 Swift Package에서 동작하지 않는 원인 후보를 좁혔습니다. 빌드 스크립트와 헤더 변환 코드의 초안을 만들고, 오류가 날 때마다 다음 실험을 정하는 데도 활용했습니다.

AI가 제안한 내용을 바로 구현 근거로 삼지는 않았습니다. 답변을 정답으로 받아들이지 않고, 실제 빌드로 확인할 가설로 다뤘습니다.

설치된 Pod의 디렉터리와 헤더를 직접 살펴 가설이 맞는지 확인했습니다. 그다음 시뮬레이터용과 디바이스용 XCFramework를 만들었습니다. 마지막에는 Swift Package와 로컬 Maven 저장소를 네이티브 앱에 연결해 화면과 이벤트가 실제로 동작하는지 검증했습니다.

| AI를 사용한 지점 | 직접 검증한 근거 |
| --- | --- |
| 공식 문서·오픈소스 비교, 버전 차이 요약 | React Native 0.86 Podspec과 설치된 Prebuild 산출물 확인 |
| VFS·헤더·모듈 문제의 원인 후보 도출 | 시뮬레이터·디바이스 archive와 Swift Package 빌드 |
| 빌드·릴리스 스크립트 초안과 오류 분석 | iOS·Android 앱 연동, 화면·이벤트 동작, v0.1.0 릴리스 |

AI를 활용해 낯선 빌드 과정을 조사하고 실패 원인을 좁히는 시간을 줄였습니다. 최종 판단은 빌드 산출물과 iOS·Android 앱의 실제 동작을 기준으로 내렸습니다. 그럴듯하지만 틀린 설명을 구현 근거로 채택하지 않기 위해서였습니다.

## 공통 기능 개발 생산성을 약 2배 높였습니다

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/shared-features-ios-android.png' | relative_url }}" alt="React Native에서 팝업 제보와 제보 관리 화면을 한 번 구현해 iOS와 Android 앱에서 함께 사용하는 구조" width="100%">
  <figcaption>제보하기와 제보 관리 화면은 React Native 공통 모듈에서 한 번 구현하고 iOS와 Android 앱에서 함께 사용합니다.</figcaption>
</figure>

팝업 제보와 팝업 제보 관리 화면은 [PopPang-RN](https://github.com/team-PopPang/PopPang-RN)에서 한 번 개발합니다. 이제 Swift와 Kotlin으로 나뉘어 일하던 두 모바일 개발자는 이 저장소에서 같은 코드를 함께 수정합니다. 같은 데모 앱에서 화면과 기능 흐름을 확인한 뒤, 릴리스된 모듈을 각자 담당하는 네이티브 앱에 연결합니다.

공통 기능은 두 개발자가 함께 만들고, 네이티브 연동과 QA는 각 플랫폼 담당자가 맡습니다. React Native를 도입했다고 해서 플랫폼별 작업이 모두 사라지는 것은 아닙니다.

화면에 진입하는 방법, 앱 생명주기, 이벤트 처리는 여전히 플랫폼별로 다뤄야 합니다. 따라서 전체 개발 기간이 항상 절반으로 줄어드는 것은 아닙니다.

이전에는 새 기능의 UI와 기능 흐름을 iOS와 Android에서 각각 구현했습니다. 지금은 공통 모듈에서 한 번 만든 코드를 두 앱에서 사용합니다. 이 영역의 구현 횟수가 플랫폼별 2회에서 공통 모듈 1회로 줄었기 때문에 생산성을 약 2배로 봤습니다.

처음부터 네이티브 코드를 없애려던 것은 아닙니다. 기존 앱과 개발 환경을 유지하면서, 네이티브 상태에 덜 의존하는 새 기능만 함께 개발하고 싶었습니다. AI는 이 과정에서 낯선 기술을 조사하고 실험하는 속도를 높이는 데 활용했습니다.

React Native의 적용 범위는 필요한 새 기능으로 제한했습니다. 그 대신 두 모바일 개발자가 하나의 기능을 함께 만들고 각 플랫폼에 배포할 수 있는 기반을 마련했습니다.

## 다음에는 모든 팀원이 아이디어를 앱에서 검증할 수 있게 만들려고 합니다

<figure>
  <img src="{{ '/assets/img/2026-07-15-PopPang-RN/team-idea-to-app.svg' | relative_url }}" alt="팝팡의 모든 팀원이 AI를 활용해 PopPang-RN에서 공통 화면을 만들고 데모 앱으로 검증한 뒤 iOS와 Android 앱에 함께 배포하는 흐름" width="100%">
  <figcaption>팀원 누구나 아이디어를 공통 화면으로 만들고, 데모 앱에서 확인한 뒤 두 플랫폼에 함께 배포하는 환경을 구상하고 있습니다.</figcaption>
</figure>

React Native 공통 모듈의 역할을 iOS와 Android의 중복 구현을 줄이는 데서 끝내고 싶지는 않습니다. 다음 목표는 팝팡의 모든 팀원이 아이디어를 실제 화면으로 빠르게 검증할 수 있는 환경을 만드는 것입니다.

백엔드 개발자·디자이너·모바일 개발자 누구나 [PopPang-RN](https://github.com/team-PopPang/PopPang-RN)을 열고 AI와 함께 React Native 화면을 만들 수 있게 하려고 합니다. 새로운 아이디어가 나오면 바이브 코딩으로 UI와 사용자 흐름을 구현해 데모 앱에서 바로 실행해 봅니다. 팀에서 검토를 마친 기능만 모듈로 릴리스해 iOS와 Android 앱에 함께 연결합니다.

먼저 공통 컴포넌트와 디자인 규칙을 정리하고, AI가 프로젝트를 이해할 수 있도록 개발 지침과 구현 예시를 보강할 계획입니다. 데모 앱에서 확인한 기능을 iOS·Android용 패키지로 배포하는 과정도 더 자동화하려고 합니다.

이 환경이 갖춰지면 아이디어를 낸 팀원이 직접 동작하는 화면까지 빠르게 만들 수 있습니다. 모바일 개발자는 같은 화면을 플랫폼별로 반복해서 구현하는 대신, 네이티브 연동과 앱 품질을 검증하는 데 더 집중할 수 있습니다.
