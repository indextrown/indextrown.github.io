---
title: "[C++] C++ 코어로 Swift 라이브러리 만들기 - 해양 알고리즘 라이브러리를 처음부터"
date: 2026-11-04 00:00:00 +0900
tags:
  - C++
  - Swift
---

선박 두 척 사이의 거리, 목적지까지의 방위, 가까워지는 시점(CPA/TCPA), 칼만 필터로 다듬은 위치. 해양 앱을 만들다 보면 이런 계산이 iOS에도, Android에도, 웹에도 똑같이 필요합니다.

플랫폼마다 Swift, Kotlin, JavaScript로 따로 구현하면 이런 일이 생깁니다.

- 같은 두 좌표인데 iOS와 Android가 서로 다른 거리를 보여줍니다. 공식이 같아도 반올림, 각도 정규화, 경계 처리가 조금씩 다르기 때문입니다.
- 버그를 고칠 때 세 군데를 고쳐야 하고, 정확도 테스트도 세 벌을 만들어야 합니다.

그래서 계산은 **C++ 한 곳에서 하고**, 각 플랫폼은 그 결과를 받아 쓰기만 하도록 [marine-algorithms](https://github.com/indextrown/marine-algorithms)라는 라이브러리를 만들고 있습니다. 지금은 측지 계산(하버사인, Vincenty)과 단위 변환까지 C++ 코어 → C 다리층 → Swift 바인딩으로 이어 놓았습니다.

이 글은 알고리즘보다 **C++ 코어를 Swift에서 쓰게 만드는 방법**을 다룹니다. 처음 접하면 `extern "C"`, 심볼, 모듈맵, `publicHeadersPath` 같은 단어가 한꺼번에 쏟아지기 때문에, 개념부터 쌓고 → 작은 라이브러리를 직접 만든 다음 → 실제 라이브러리 구조를 읽는 순서로 갑니다.

**Part 1. 먼저 알아둘 개념**

1. 한 장으로 먼저 보기
2. 컴파일, 링크, 심볼 - 링커는 이름으로 함수를 찾는다
3. `extern "C"`와 C ABI - 왜 굳이 C를 한 번 거치는가
4. Swift가 C를 가져오는 방법 - 모듈맵과 C++ interop

**Part 2. 처음부터 만들어 보기 - MiniNav**

5. 폴더 구조와 Package.swift
6. C++ 코어 - `std::expected`
7. C 다리층 - 상태 코드와 out 포인터
8. Swift 래퍼 - 값 타입과 typed throws
9. 테스트하고 심볼 확인하기
10. 자주 하는 실수 두 가지
{: start="5"}

**Part 3. 실제 라이브러리 - marine-algorithms**

11. 코어 설계 규칙
12. 다리층 규칙
13. 실패가 층을 넘는 방식
14. 빌드 두 갈래 - CMake와 SwiftPM
15. 테스트는 층마다 맡는 것이 다르다
16. 데모 앱에서 확인하기
17. 실제로 걸렸던 함정들
18. 다음 단계 - 상태 있는 객체
{: start="11"}

> 이 글의 결과는 모두 **Xcode 27.0 / Swift 6.4 / macOS(arm64)**에서 직접 빌드하고 돌려서 확인했습니다. 에러 메시지도 실제 출력을 그대로 옮겼습니다.

&nbsp;

---

&nbsp;

# Part 1. 먼저 알아둘 개념

## 1. 한 장으로 먼저 보기

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/layers.svg" alt="C++ 코어, C 다리층, 언어 바인딩의 세 층 구조" style="width: 100%;">

```text
marine-algorithms/
├── Package.swift            SwiftPM: iOS·macOS 앱이 가져다 쓰는 길
├── CMakeLists.txt           CMake: C++ 테스트, 이후 Android NDK가 쓰는 길
├── include/marine/          C++ 공개 헤더 (namespace marine::)
├── src/                     C++ 구현               ─┐ SwiftPM 타겟
├── bindings/                                        │ CMarineAlgorithms
│   ├── c/                                           │
│   │   ├── include/marine_c.h   C 헤더 (Swift에 보이는 유일한 헤더)
│   │   └── marine_c.cpp         extern "C" 구현    ─┘
│   └── swift/
│       ├── Sources/MarineAlgorithms/   Swift 래퍼 ← 앱이 import하는 모듈
│       └── Tests/                      Swift 테스트
└── tests/
    ├── cpp/                 C++ 테스트 (Catch2)
    └── data/                기준값 (GeodTest 일부)
```

규칙은 하나입니다. **Swift는 C 헤더 `marine_c.h`만 봅니다.** C++ 헤더는 Swift에 노출하지 않습니다.

| 층 | 하는 일 | 모르는 것 | 실패를 알리는 방법 |
| --- | --- | --- | --- |
| C++ 코어 | 계산 | 누가 자신을 부르는지 | `std::expected` |
| C 다리층 | C 타입 ↔ C++ 타입 변환 | 계산 방법 | `ma_status` + out 포인터 |
| Swift 바인딩 | C 값을 Swift 값 타입으로 | C++가 있다는 것 자체 | `throws(GeodesyError)` |

앞으로 나올 용어를 미리 정리해 두겠습니다.

| 용어 | 한 줄 설명 | 나오는 곳 |
| --- | --- | --- |
| 헤더 / 소스 | 선언(`.h`, `.hpp`)과 구현(`.c`, `.cpp`) | 2장 |
| 오브젝트 파일 (`.o`) | 소스 하나를 컴파일한 결과. 기계어 + 심볼 표 | 2장 |
| 심볼 | 오브젝트 파일 안에서 함수·변수를 가리키는 이름 | 2장 |
| 링커 | 여러 `.o`를 합치며, 부르는 쪽의 이름과 정의된 쪽의 이름을 맞추는 도구 | 2장 |
| name mangling | C++가 오버로딩을 위해 심볼 이름에 네임스페이스·인자 타입을 섞는 것 | 2장 |
| ABI | 컴파일된 코드끼리 지키는 약속. 심볼 이름, 인자 전달 방식, 구조체 메모리 배치 | 3장 |
| `extern "C"` | 이 함수는 C 방식(이름 그대로, C 호출 규약)으로 내보내라는 지시 | 3장 |
| POD 구조체 | 생성자·소멸자·가상 함수 없이 데이터만 있는 구조체. C와 메모리 배치가 같다 | 3장 |
| Clang 모듈 / 모듈맵 | C 헤더를 Swift가 `import`할 수 있는 모듈로 묶는 설명서 | 4장 |
| C++ interop | Swift 5.9부터 C++ 헤더를 직접 가져오는 기능 | 4장 |
| `std::expected` | "값 또는 오류"를 담는 C++23 타입. Swift `Result`와 비슷하다 | 6장 |
| typed throws | Swift 6의 `throws(ErrorType)`. 던지는 오류 타입을 정확히 적는다 | 8장 |

&nbsp;

---

&nbsp;

## 2. 컴파일, 링크, 심볼 - 링커는 이름으로 함수를 찾는다

Swift만 쓸 때는 잘 보이지 않지만, C++ 라이브러리를 붙이는 순간 **컴파일과 링크가 따로 일어난다는 것**을 알아야 에러 메시지를 읽을 수 있습니다.

```text
nav.cpp ─┐ 컴파일 ┌─▶ nav.o        ┐
mininav_c.cpp ──────▶ mininav_c.o  ├─ 링크 ─▶ 앱 실행 파일 / 테스트 번들
MiniNav.swift ──────▶ MiniNav.o    ┘
```

1. **컴파일**은 소스 파일 하나씩 따로 합니다. `MiniNav.swift`를 컴파일할 때 컴파일러는 `mn_haversine_distance`의 **선언**(헤더)만 보고 "이런 이름의 함수를 부른다"고 적어 둡니다. 구현이 어디 있는지는 모릅니다.
2. **링크**는 `.o`들을 합치면서, "부르는 쪽이 찾는 이름"과 "정의된 이름"을 맞춥니다. 이 이름이 **심볼**입니다.

심볼은 `nm`으로 볼 수 있습니다. 9장에서 만들 MiniNav의 C++·C 오브젝트 파일을 실제로 열어보면 이렇습니다.

```text
$ nm -gU .build/out/Products/Debug/CMiniNav.o
0000000000000460 T __ZN7mininav13average_speedENS_10CoordinateES0_d
00000000000002e8 T __ZN7mininav18haversine_distanceENS_10CoordinateES0_
00000000000000a0 T _mn_average_speed
0000000000000000 T _mn_haversine_distance
```

`T`는 "이 파일에 정의된 함수"라는 뜻입니다. 두 종류의 이름이 섞여 있습니다.

- `_mn_haversine_distance` - C 방식 이름입니다. 함수 이름 앞에 `_` 하나만 붙었습니다(macOS 규칙).
- `__ZN7mininav18haversine_distanceENS_10CoordinateES0_` - C++ 방식 이름입니다. 네임스페이스(`7mininav`), 함수 이름(`18haversine_distance`), 인자 타입(`10Coordinate`, `S0_`)이 모두 이름 안에 들어 있습니다. 이걸 **name mangling**이라고 합니다. `c++filt`로 풀면 원래 모양이 보입니다.

```text
$ nm -gU CMiniNav.o | c++filt
mininav::average_speed(mininav::Coordinate, mininav::Coordinate, double)
mininav::haversine_distance(mininav::Coordinate, mininav::Coordinate)
```

C++가 이름을 이렇게 바꾸는 이유는 **오버로딩** 때문입니다. `distance(int)`와 `distance(double)`이 둘 다 있으면 링커는 이름으로만 구분하니까, 인자 타입을 이름에 넣어야 합니다. C에는 오버로딩이 없어서 이름을 그대로 씁니다.

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/symbols.svg" alt="링커가 심볼 이름으로 함수를 찾는 과정" style="width: 100%;">

여기서 문제가 보입니다. **C++의 mangling 규칙은 컴파일러와 플랫폼마다 다릅니다.** Swift, Kotlin(JNI), WASM이 이 이름을 맞춰 부르기는 사실상 불가능합니다. 그래서 다른 언어가 부를 함수는 C 방식 이름으로 내보내야 합니다.

&nbsp;

---

&nbsp;

## 3. `extern "C"`와 C ABI - 왜 굳이 C를 한 번 거치는가

### ABI

**API**가 소스 코드 수준의 약속(함수 이름, 인자)이라면, **ABI**(Application Binary Interface)는 컴파일된 기계어 수준의 약속입니다.

| ABI가 정하는 것 | 예 |
| --- | --- |
| 심볼 이름 | `_mn_haversine_distance` vs `__ZN7mininav...` |
| 호출 규약 | 인자를 어느 레지스터에 넣는가, 반환값은 어디로 오는가 |
| 메모리 배치 | 구조체 필드 순서, 크기, 정렬(padding) |
| 예외 처리 방식 | 예외가 스택을 어떻게 거슬러 올라가는가 |

C의 ABI는 각 플랫폼(arm64 macOS, arm64 Android, x86_64 Linux...)마다 **하나로 정해져 있고 수십 년째 바뀌지 않았습니다.** 그래서 거의 모든 언어가 "C 함수 부르기"를 지원합니다. Swift는 C 헤더를 그대로 import하고, Kotlin은 JNI로, Rust는 FFI로, WASM은 export로 C 함수를 부릅니다.

### extern "C"

`extern "C"`는 C++ 컴파일러에게 **이 함수는 C ABI로 내보내라**고 알려줍니다. 이름을 mangling하지 않고, C 호출 규약을 씁니다.

```c
#ifdef __cplusplus      /* C++ 컴파일러가 읽을 때만 */
extern "C" {
#endif

double mn_haversine_distance(mn_coordinate from, mn_coordinate to);

#ifdef __cplusplus
}
#endif
```

`#ifdef __cplusplus`로 감싸는 이유는 이 헤더를 **C 컴파일러(그리고 Swift의 Clang importer)도 읽기 때문**입니다. C에는 `extern "C"`라는 문법이 없어서, C++ 컴파일러가 읽을 때만 보이게 합니다.

### C 경계를 넘을 수 있는 것과 없는 것

`extern "C"` 함수의 **시그니처**에는 C가 이해하는 타입만 쓸 수 있습니다. 함수 **안쪽**은 C++이라 무엇이든 써도 됩니다.

| 넘을 수 있다 | 넘을 수 없다 | 대신 |
| --- | --- | --- |
| `int`, `double`, `bool` | `std::string`, `std::vector` | `const char*` + 길이, 포인터 + 개수 |
| POD 구조체, `enum` | 클래스(생성자, 가상 함수) | 불투명 핸들 + `_new` / `_free` (18장) |
| 포인터 | 참조(`&`), 스마트 포인터 | 포인터 |
| 상태 코드 반환 | **예외** | 상태 코드 + out 포인터 (7장) |
| 함수 하나에 이름 하나 | 오버로딩, 템플릿, 기본 인자 | 이름을 다르게, 기본값은 Swift에서 |
| | 네임스페이스 | `mn_`, `ma_` 같은 접두사 |

특히 **예외**가 중요합니다. C++ 예외가 `extern "C"` 함수를 빠져나가 Swift 프레임으로 들어가면, Swift는 그 예외를 처리할 방법이 없어 프로세스가 죽습니다. 그래서 C 다리층 함수는 예외를 절대 밖으로 내보내지 않아야 하고, 이 글의 코어는 아예 예외 대신 `std::expected`로 실패를 반환합니다.

&nbsp;

---

&nbsp;

## 4. Swift가 C를 가져오는 방법 - 모듈맵과 C++ interop

### Clang 모듈과 모듈맵

Swift는 C 헤더를 직접 `#include`하지 않고 **Clang 모듈**로 가져옵니다. 모듈은 "이 헤더들을 묶어 `CMiniNav`라는 이름으로 import하게 한다"는 설명서(module map)로 정의됩니다. 아래는 SwiftPM이 MiniNav를 빌드하며 실제로 만든 모듈맵입니다(경로만 줄였습니다).

```text
// .build/out/Intermediates.noindex/GeneratedModuleMaps/CMiniNav.modulemap
module CMiniNav {
umbrella "<패키지 경로>/bindings/c/include"
export *
}
```

SwiftPM은 C/C++ 타겟의 `publicHeadersPath` 폴더를 보고 이 모듈맵을 **자동으로 만들어 줍니다.** 그래서 직접 모듈맵을 쓸 일은 거의 없습니다. 중요한 건 이 결과입니다.

- `publicHeadersPath` 폴더의 헤더는 **C 언어로 해석됩니다.** Swift 쪽 기본 설정에서는 C++ interop이 꺼져 있기 때문입니다.
- 그래서 이 폴더의 헤더에 `#include <expected>`나 `namespace`가 있으면 Swift 쪽에서 모듈을 만들다 실패합니다(10장에서 실제로 재현합니다).

Swift가 C 헤더를 가져오면 C 타입은 이렇게 바뀝니다.

| C | Swift에서 보이는 모습 |
| --- | --- |
| `double` | `Double` (`CDouble`) |
| `typedef struct { double latitude; ... } mn_coordinate` | `struct mn_coordinate`, 멤버별 이니셜라이저 `mn_coordinate(latitude:longitude:)` |
| `typedef enum mn_status { MN_OK, ... }` | `struct mn_status` + 전역 상수 `MN_OK` |
| `double* out` | `UnsafeMutablePointer<Double>!` - `&변수`로 넘긴다 |
| `mn_filter*` (내용을 모르는 구조체) | `OpaquePointer` |

### C++ interop으로 바로 부르면 안 되나

Swift 5.9부터는 **C++ interop**이 있어서, C 다리층 없이 C++ 헤더를 바로 가져올 수 있습니다. 실제로 해 봤습니다.

<details class="notion-toggle-list" markdown="1">
<summary>C++ interop으로 바로 부르기 - 코드 보기</summary>

```swift
// Package.swift
.target(name: "CxxNav"),                                  // nav.hpp, nav.cpp
.executableTarget(
    name: "Direct",
    dependencies: ["CxxNav"],
    swiftSettings: [.interoperabilityMode(.Cxx)]          // C++ interop 켜기
),
```

```swift
// main.swift
import CxxNav

let busan = mininav.Coordinate(latitude: 35.1028, longitude: 129.0403)
let fukuoka = mininav.Coordinate(latitude: 33.5902, longitude: 130.4017)
print(mininav.haversine_distance(busan, fukuoka))

let r = mininav.average_speed(busan, fukuoka, 36_000)   // std::expected<double, NavError>
print(r.has_value())
print(r.pointee)
```

</details>

```text
209543.01573428483
true
5.820639325952357
```

잘 됩니다. 네임스페이스가 Swift 타입처럼 보이고, `std::expected`의 `has_value()`와 `pointee`까지 부를 수 있습니다.

문제는 **이 라이브러리를 가져다 쓰는 쪽**입니다. interop을 켠 라이브러리 `NavLib`를 만들고, interop을 켜지 않은 앱이 `import NavLib`하면 이렇게 됩니다.

```text
error: module 'NavLib' was built with C++ interoperability enabled,
       but current compilation does not enable C++ interoperability
```

`NavLib`의 공개 API가 Swift 타입뿐이고, C++ 모듈을 `internal import`나 `@_implementationOnly import`로 가려도 결과는 같았습니다. **C++ interop은 쓰는 쪽으로 전염됩니다.** 라이브러리를 쓰는 모든 앱 타겟이 C++ interop을 켜야 하고, 그 앱이 쓰는 다른 의존성도 C++ interop 아래에서 다시 컴파일됩니다.

| | C 다리층 | C++ interop 직접 |
| --- | --- | --- |
| 쓰는 쪽 설정 | 없음 | 앱 타겟마다 `.interoperabilityMode(.Cxx)` |
| 다른 언어(Kotlin, WASM) | 같은 C 함수를 그대로 | Swift 전용. 다른 언어는 따로 |
| 작성할 코드 | C 헤더 + 변환 코드 | 거의 없음 |
| C++ 타입 변경 | C 시그니처만 같으면 바인딩 그대로 | Swift 코드에 그대로 드러남 |
| 잘 맞는 경우 | 배포하는 라이브러리, 여러 언어 | 내 앱 안에서만 쓰는 C++ 코드 |

marine-algorithms는 **다른 앱이 가져다 쓰는 라이브러리**이고 **Kotlin·WASM 바인딩도 붙일 계획**이라 C 다리층을 택했습니다. 내 앱 안에서만 쓰는 C++라면 interop이 훨씬 간단한 선택일 수 있습니다.

&nbsp;

---

&nbsp;

# Part 2. 처음부터 만들어 보기 - MiniNav

개념을 확인하기 위해, marine-algorithms와 같은 구조를 가진 아주 작은 라이브러리 **MiniNav**를 처음부터 만들어 보겠습니다. 함수는 두 개뿐입니다.

| 함수 | 실패 | 보여주는 것 |
| --- | --- | --- |
| `haversine_distance` - 두 좌표의 대권 거리 | 없음 | 값을 그대로 돌려주는 경로 |
| `average_speed` - 두 좌표와 걸린 시간으로 평균 속력 | 시간이 0 이하 | 실패가 세 층을 넘는 경로 |

## 5. 폴더 구조와 Package.swift

```text
MiniNav/
├── Package.swift
├── include/mininav/nav.hpp            C++ 공개 헤더
├── src/nav.cpp                        C++ 구현
├── bindings/
│   ├── c/include/mininav_c.h          C 헤더 (Swift에 보임)
│   ├── c/mininav_c.cpp                extern "C" 구현
│   └── swift/
│       ├── Sources/MiniNav/MiniNav.swift
│       └── Tests/MiniNavTests/MiniNavTests.swift
```

SwiftPM 타겟은 두 개입니다. C++ 코어와 C 다리층을 **한 타겟(`CMiniNav`)**으로 컴파일하고, Swift 래퍼(`MiniNav`)가 그 위에 올라갑니다.

<details class="notion-toggle-list" markdown="1">
<summary>Package.swift - 코드 보기</summary>

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiniNav",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "MiniNav", targets: ["MiniNav"]),
    ],
    targets: [
        // C++ 코어 + C 다리층을 한 타겟으로 컴파일한다.
        .target(
            name: "CMiniNav",
            path: ".",
            sources: ["src", "bindings/c/mininav_c.cpp"],
            publicHeadersPath: "bindings/c/include",   // Swift에 보이는 헤더
            cxxSettings: [.headerSearchPath("include")] // C++ 헤더는 컴파일할 때만
        ),
        // Swift 래퍼
        .target(
            name: "MiniNav",
            dependencies: ["CMiniNav"],
            path: "bindings/swift/Sources/MiniNav"
        ),
        .testTarget(
            name: "MiniNavTests",
            dependencies: ["MiniNav"],
            path: "bindings/swift/Tests/MiniNavTests"
        ),
    ],
    cxxLanguageStandard: .cxx2b
)
```

</details>

설정 하나하나가 1~4장의 개념과 이어집니다.

| 설정 | 뜻 |
| --- | --- |
| `path: "."`, `sources: [...]` | 패키지 루트를 기준으로, 이 파일들만 이 타겟으로 컴파일 |
| `publicHeadersPath: "bindings/c/include"` | 이 폴더의 헤더로 모듈맵을 만든다. **Swift에 보이는 건 C 헤더뿐** |
| `.headerSearchPath("include")` | C++ 헤더는 이 타겟을 **컴파일할 때만** 찾는다. 밖으로 노출되지 않음 |
| `cxxLanguageStandard: .cxx2b` | C++23(`std::expected`). SwiftPM에서는 `cxx2b`라는 이름을 쓴다 |
| `products`에 `MiniNav`만 | 앱은 Swift 래퍼만 의존한다. `CMiniNav`는 앱에서 직접 볼 일이 없다 |

## 6. C++ 코어 - `std::expected`

코어는 다른 언어를 전혀 모르는 평범한 C++입니다.

<details class="notion-toggle-list" markdown="1">
<summary>include/mininav/nav.hpp - 코드 보기</summary>

```cpp
#pragma once
#include <expected>

namespace mininav {

struct Coordinate {
    double latitude;   // 도
    double longitude;  // 도
};

enum class NavError {
    invalid_argument,  // 시간이 0 이하
};

/// 구면 대권 거리(m). 실패하지 않는다.
double haversine_distance(Coordinate from, Coordinate to) noexcept;

/// 두 위치와 걸린 시간(s)으로 평균 속력(m/s). 시간이 0 이하면 실패.
std::expected<double, NavError>
average_speed(Coordinate from, Coordinate to, double seconds) noexcept;

} // namespace mininav
```

</details>

<details class="notion-toggle-list" markdown="1">
<summary>src/nav.cpp - 코드 보기</summary>

```cpp
#include "mininav/nav.hpp"

#include <cmath>
#include <numbers>

namespace mininav {

namespace {
constexpr double kEarthRadius = 6371008.8;  // 평균 반경(m)
constexpr double to_radians(double d) noexcept { return d * std::numbers::pi / 180.0; }
} // namespace

double haversine_distance(Coordinate from, Coordinate to) noexcept {
    const double p1 = to_radians(from.latitude), p2 = to_radians(to.latitude);
    const double dp = p2 - p1;
    const double dl = to_radians(to.longitude - from.longitude);
    const double a = std::sin(dp / 2) * std::sin(dp / 2)
                   + std::cos(p1) * std::cos(p2) * std::sin(dl / 2) * std::sin(dl / 2);
    return 2 * kEarthRadius * std::atan2(std::sqrt(a), std::sqrt(std::fmax(0.0, 1 - a)));
}

std::expected<double, NavError>
average_speed(Coordinate from, Coordinate to, double seconds) noexcept {
    if (!(seconds > 0)) return std::unexpected(NavError::invalid_argument);  // NaN도 막는다
    return haversine_distance(from, to) / seconds;
}

} // namespace mininav
```

</details>

`std::expected<T, E>`는 "값 `T`가 들어 있거나, 오류 `E`가 들어 있는" 상자입니다. Swift의 `Result<T, E>`와 거의 같습니다.

| | C++ `std::expected<double, NavError>` | Swift `Result<Double, NavError>` |
| --- | --- | --- |
| 성공 만들기 | `return 5.82;` | `.success(5.82)` |
| 실패 만들기 | `return std::unexpected(NavError::invalid_argument);` | `.failure(.invalidArgument)` |
| 성공했나 | `if (r)` / `r.has_value()` | `if case .success = r` |
| 값 / 오류 꺼내기 | `*r`, `r.value()` / `r.error()` | `try r.get()` |

예외 대신 이걸 쓰는 이유는 3장에서 본 대로 **예외는 C 경계를 넘을 수 없기 때문**입니다. 실패가 그냥 반환값이면 다리층에서 `if` 하나로 상태 코드로 바꿀 수 있습니다. 실패할 수 있다는 사실이 시그니처에 드러나는 것도 장점입니다.

`!(seconds > 0)`처럼 부정형으로 쓴 데도 이유가 있습니다. `seconds <= 0`으로 쓰면 `NaN`이 들어왔을 때 비교가 `false`라 통과해 버립니다. `NaN > 0`도 `false`이므로 부정형은 `NaN`까지 막습니다.

## 7. C 다리층 - 상태 코드와 out 포인터

C 헤더는 **C 컴파일러도 읽을 수 있는** 타입만 씁니다. C++ 헤더를 include하지 않습니다.

<details class="notion-toggle-list" markdown="1">
<summary>bindings/c/include/mininav_c.h - 코드 보기</summary>

```c
#ifndef MININAV_C_H
#define MININAV_C_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum mn_status {
    MN_OK = 0,
    MN_INVALID_ARGUMENT = 1,
} mn_status;

typedef struct mn_coordinate {
    double latitude;
    double longitude;
} mn_coordinate;

/* 실패하지 않음: 값을 돌려준다 */
double mn_haversine_distance(mn_coordinate from, mn_coordinate to);

/* 실패할 수 있음: 상태를 돌려주고, 성공했을 때만 *out에 쓴다 */
mn_status mn_average_speed(mn_coordinate from, mn_coordinate to,
                           double seconds, double* out);

#ifdef __cplusplus
}
#endif

#endif
```

</details>

- C에는 네임스페이스가 없어서 `mn_` 접두사가 그 역할을 합니다.
- `mn_coordinate`는 C++ `Coordinate`와 필드가 같지만 **일부러 다른 타입**입니다. C 헤더가 C++ 헤더를 include하지 않아야 Swift가 읽을 수 있기 때문입니다.
- 실패할 수 있는 함수는 **상태 코드를 반환하고 결과는 out 포인터에** 씁니다. C에는 `expected`도 예외도 없으니 이것이 C의 관용적인 방식입니다.

구현은 "C 타입을 C++ 타입으로 → 코어 호출 → 결과를 C 타입으로"가 전부입니다. 이 파일은 `.cpp`라서 C++ 헤더를 마음껏 include합니다.

<details class="notion-toggle-list" markdown="1">
<summary>bindings/c/mininav_c.cpp - 코드 보기</summary>

```cpp
#include "mininav_c.h"
#include "mininav/nav.hpp"

namespace {
mininav::Coordinate to_cpp(mn_coordinate c) noexcept { return {c.latitude, c.longitude}; }

mn_status to_c(mininav::NavError e) noexcept {
    switch (e) {
    case mininav::NavError::invalid_argument: return MN_INVALID_ARGUMENT;
    }
    return MN_INVALID_ARGUMENT;
}
} // namespace

extern "C" {

double mn_haversine_distance(mn_coordinate from, mn_coordinate to) {
    return mininav::haversine_distance(to_cpp(from), to_cpp(to));
}

mn_status mn_average_speed(mn_coordinate from, mn_coordinate to,
                           double seconds, double* out) {
    if (!out) return MN_INVALID_ARGUMENT;
    const auto r = mininav::average_speed(to_cpp(from), to_cpp(to), seconds);
    if (!r) return to_c(r.error());  // 실패: out은 그대로
    *out = *r;
    return MN_OK;
}

} // extern "C"
```

</details>

- 변환 함수(`to_cpp`, `to_c`)는 익명 네임스페이스에 둬서 이 파일 밖으로 나가지 않습니다.
- `to_c`의 `switch`에는 `default`를 두지 않습니다. 나중에 `NavError`에 값이 추가되면 컴파일러가 "처리하지 않은 case" 경고를 내서, 다리층을 고쳐야 한다는 걸 알려줍니다.
- **실패하면 out을 건드리지 않습니다.** 쓰는 쪽이 out을 미리 초기화해 두면, 실패해도 그 값을 믿을 수 있습니다.

## 8. Swift 래퍼 - 값 타입과 typed throws

마지막으로 C 함수를 Swift다운 API로 감쌉니다.

<details class="notion-toggle-list" markdown="1">
<summary>bindings/swift/Sources/MiniNav/MiniNav.swift - 코드 보기</summary>

```swift
import CMiniNav

public struct Coordinate: Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    // Swift → C. internal이라 라이브러리 밖에서는 mn_coordinate가 보이지 않는다.
    var c: mn_coordinate { mn_coordinate(latitude: latitude, longitude: longitude) }
}

public enum NavError: Error, Hashable, Sendable {
    case invalidArgument
}

public enum Nav {
    /// 구면 대권 거리(m)
    public static func distance(from: Coordinate, to: Coordinate) -> Double {
        mn_haversine_distance(from.c, to.c)
    }

    /// 평균 속력(m/s). 시간이 0 이하면 throw.
    public static func averageSpeed(
        from: Coordinate, to: Coordinate, seconds: Double
    ) throws(NavError) -> Double {
        var out = 0.0
        guard mn_average_speed(from.c, to.c, seconds, &out) == MN_OK else {
            throw .invalidArgument
        }
        return out
    }
}
```

</details>

| C에서 | Swift에서 | 방법 |
| --- | --- | --- |
| `mn_coordinate` | `Coordinate` (`Hashable`, `Sendable`) | 같은 필드의 Swift 구조체로 감싸고, C로 가는 변환은 `internal` |
| `mn_status` + `double* out` | `throws(NavError) -> Double` | `&out`으로 Swift 변수를 out 포인터에 넘기고, `MN_OK`가 아니면 throw |
| `mn_` 접두사 | `Nav.distance(from:to:)` | 네임스페이스 역할의 `enum`과 인자 레이블 |

쓰는 쪽에서는 C++가 있다는 걸 전혀 모릅니다.

```swift
import MiniNav

let d = Nav.distance(from: busan, to: fukuoka)                          // 209,543 m
let v = try Nav.averageSpeed(from: busan, to: fukuoka, seconds: 36_000) // 5.82 m/s
```

## 9. 테스트하고 심볼 확인하기

Swift Testing으로 세 가지만 확인합니다. 거리 값, 속력 값, 그리고 실패가 `throw`로 바뀌는지입니다.

<details class="notion-toggle-list" markdown="1">
<summary>MiniNavTests.swift - 코드 보기</summary>

```swift
import Testing
import MiniNav

let busan = Coordinate(latitude: 35.1028, longitude: 129.0403)
let fukuoka = Coordinate(latitude: 33.5902, longitude: 130.4017)

@Test func distanceBusanFukuoka() {
    let d = Nav.distance(from: busan, to: fukuoka)
    #expect(abs(d - 209_543) < 1)
}

@Test func averageSpeedOverTenHours() throws {
    let v = try Nav.averageSpeed(from: busan, to: fukuoka, seconds: 36_000)
    #expect(abs(v - 5.82) < 0.01)   // 약 5.82 m/s ≈ 11.3노트
}

@Test func zeroSecondsThrows() {
    #expect(throws: NavError.invalidArgument) {
        try Nav.averageSpeed(from: busan, to: fukuoka, seconds: 0)
    }
}
```

</details>

```text
$ swift test
✔ Test zeroSecondsThrows() passed after 0.001 seconds.
✔ Test distanceBusanFukuoka() passed after 0.001 seconds.
✔ Test averageSpeedOverTenHours() passed after 0.001 seconds.
✔ Test run with 3 tests in 0 suites passed after 0.001 seconds.
```

처음에는 거리 기대값을 "부산-후쿠오카 약 208km, 오차 1km"로 적었다가 테스트가 실패했습니다. 실제 값은 **209,543m**였습니다. 대략적인 값으로 테스트를 쓰면 이렇게 걸러지니, 기준값은 직접 계산해서 넣는 편이 안전합니다.

빌드된 오브젝트 파일의 심볼은 2장에서 본 그대로입니다. C++ 코어 함수는 mangling된 이름, 다리층 함수는 `_mn_...` C 이름입니다. Swift 쪽이 찾는 것은 C 이름 두 개뿐입니다.

## 10. 자주 하는 실수 두 가지

### 실수 1. `extern "C"`를 빼먹었다

헤더와 구현에서 `extern "C"`를 지우고 다시 빌드해 봤습니다. `swift build`(라이브러리만 빌드)는 **성공합니다.** 링크가 일어나지 않기 때문입니다. 링크가 일어나는 `swift test`에서 이렇게 실패합니다.

```text
Undefined symbols for architecture arm64:
  "_mn_average_speed", referenced from:
      static MiniNav.Nav.averageSpeed(...) throws(MiniNav.NavError) -> Swift.Double in MiniNav.o
  "_mn_haversine_distance", referenced from:
      static MiniNav.Nav.distance(...) -> Swift.Double in MiniNav.o
ld: symbol(s) not found for architecture arm64
```

이때 `nm`으로 보면 원인이 바로 보입니다.

```text
$ nm -gU CMiniNav.o | grep mn_
00000000000000a0 T __Z16mn_average_speed13mn_coordinateS_dPd
0000000000000000 T __Z21mn_haversine_distance13mn_coordinateS_
```

함수는 분명히 있습니다. 다만 C++ 컴파일러가 이름을 `__Z21mn_haversine_distance13mn_coordinateS_`로 바꿔 버려서, Swift가 찾는 `_mn_haversine_distance`와 이름이 다릅니다(2장 그림의 빨간 경로). **"Undefined symbols"인데 함수를 분명히 구현했다면, 가장 먼저 `extern "C"`를 의심하면 됩니다.**

### 실수 2. C 헤더에 C++ 헤더를 include했다

C 헤더에서 C++ 타입을 쓰고 싶어서 `#include <expected>`를 넣으면 이렇게 됩니다.

```text
error: clang dependency scanning failure: While building module 'CMiniNav' imported from module-include.input:1:
bindings/c/include/mininav_c.h:4:10: fatal error: 'expected' file not found
error: bindings/swift/Sources/MiniNav/MiniNav.swift:1:8 unable to resolve module dependency: 'CMiniNav'
```

`<expected>`는 분명히 있는 헤더인데 "file not found"가 납니다. 4장에서 본 대로 **Swift는 공개 헤더를 C로 읽기 때문**입니다. C 모드에서는 C++ 표준 라이브러리 헤더 경로를 찾지 않습니다. 공개 헤더에는 C만, C++는 `.cpp`와 `include/` 쪽에만 둡니다.

| 증상 | 원인 | 확인 방법 |
| --- | --- | --- |
| `swift build`는 되는데 `swift test`나 앱 빌드에서 `Undefined symbols` | `extern "C"` 빠짐 | `nm -gU`로 `__Z...` 이름인지 |
| `fatal error: '<C++ 헤더>' file not found`, `could not build module` | 공개 헤더가 C++ 헤더를 include | 공개 헤더의 `#include` 목록 |

&nbsp;

---

&nbsp;

# Part 3. 실제 라이브러리 - marine-algorithms

MiniNav와 뼈대는 똑같습니다. 실제 라이브러리에서는 여기에 **설계 규칙, 정확도 기준값, 빌드 두 갈래, 함정**이 더해집니다.

## 11. 코어 설계 규칙

| 규칙 | 이유 |
| --- | --- |
| C++23 | `std::expected`를 쓰기 위해. Android NDK r26(clang 17, libc++ 17)과 Swift 패키지 양쪽에서 빌드됩니다 |
| 외부 의존성 없음 (테스트용 Catch2만) | 모바일 빌드에 끌고 갈 것이 없어야 합니다 |
| 공개 API는 SI 단위와 도(°) | 거리 m, 시간 s, 속도 m/s. 내부 계산만 라디안 |
| 순수 계산은 `noexcept` 자유 함수 | 상태가 없으니 클래스가 필요 없습니다. 필터처럼 상태가 필요한 것만 클래스로 |
| 실패는 `std::expected`로 반환 | 예외를 쓰지 않으니 C 경계에서 잡을 것도 없습니다 |

<details class="notion-toggle-list" markdown="1">
<summary>include/marine/geodesy.hpp (일부) - 코드 보기</summary>

```cpp
namespace marine::geodesy {

/// 위도·경도(도 단위).
struct Coordinate {
    double latitude;
    double longitude;
};

/// 회전 타원체. 장반경 a(m)와 편평률 f.
struct Ellipsoid {
    double semi_major_axis;
    double flattening;
};

/// GPS가 쓰는 WGS84 타원체.
inline constexpr Ellipsoid kWGS84{6378137.0, 1 / 298.257223563};

enum class GeodesyError {
    /// 반복 계산이 수렴하지 않았다. 두 점이 거의 대척점일 때 생긴다.
    not_converged,
};

/// 실패하지 않는 계산: 값을 그대로 돌려준다.
double haversine_distance(Coordinate from, Coordinate to) noexcept;

/// 실패할 수 있는 계산: std::expected로 돌려준다.
std::expected<InverseSolution, GeodesyError>
vincenty_inverse(Coordinate from, Coordinate to,
                 const Ellipsoid& ellipsoid = kWGS84) noexcept;

} // namespace marine::geodesy
```

</details>

함수가 두 종류로 나뉩니다. MiniNav의 `haversine_distance` / `average_speed`와 같은 구도입니다.

- **하버사인**은 지구를 구로 보고 닫힌 식으로 바로 계산합니다. 실패할 일이 없으니 `double`을 그대로 돌려줍니다.
- **Vincenty**는 지구를 타원체(WGS84)로 보고 고정점 반복으로 답을 찾습니다. 두 점이 거의 지구 반대편(대척점)에 있으면 반복이 흔들리며 수렴하지 않습니다. 그래서 `std::expected<InverseSolution, GeodesyError>`를 돌려줍니다.

<details class="notion-toggle-list" markdown="1">
<summary>vincenty.cpp 반복 루프 - 코드 보기</summary>

```cpp
for (;; ++iteration) {
    if (iteration == kMaxIterations)
        return std::unexpected(GeodesyError::not_converged);
    // ... λ 갱신 ...

    // 대척점 근처에서는 λ가 π를 넘어 흔들리며 수렴하지 않는다.
    if (std::fabs(lambda) > std::numbers::pi)
        return std::unexpected(GeodesyError::not_converged);
    if (std::fabs(lambda - previous) < kTolerance) break;
}
// ...
return InverseSolution{distance, initial_bearing, final_bearing};
```

</details>

## 12. 다리층 규칙

| 규칙 | 이유 |
| --- | --- |
| 값으로 넘길 수 있는 건 POD 구조체(`ma_coordinate`) | 수명 관리가 필요 없습니다 |
| 상태 있는 객체는 불투명 핸들 + `ma_*_new` / `ma_*_free` | C++ 타입을 숨기고, 누가 해제하는지 분명히 합니다 |
| 실패할 수 있는 함수는 `ma_status`를 돌려주고 결과는 out 포인터에. 실패하면 out은 그대로 | C·JNI·WASM은 C++ 예외를 받을 수 없습니다 |
| 실패하지 않는 함수는 결과를 값으로 | 쓰는 쪽이 상태를 확인할 필요가 없습니다 |
| 콜백을 두지 않습니다(pull 방식) | 거꾸로 넘어가는 콜백은 바인딩마다 가장 까다로운 부분입니다 |

MiniNav와 다른 점은 기본 인자 하나입니다. C++ `vincenty_inverse`에는 `ellipsoid = kWGS84` 기본값이 있지만 C에는 기본 인자가 없습니다. 그래서 C에는 `ma_wgs84()` 함수를 두고, Swift에서 `ellipsoid: Ellipsoid = .wgs84`로 기본값을 되살립니다.

<details class="notion-toggle-list" markdown="1">
<summary>marine_c.h / marine_c.cpp (일부) - 코드 보기</summary>

```c
typedef enum ma_status {
    MA_OK = 0,
    MA_NOT_CONVERGED = 1,     /* Vincenty 역문제의 대척점 근처 */
    MA_INVALID_ARGUMENT = 2,  /* out 포인터가 NULL */
} ma_status;

ma_ellipsoid ma_wgs84(void);

ma_status ma_vincenty_inverse(ma_coordinate from, ma_coordinate to,
                              ma_ellipsoid ellipsoid, ma_inverse* out);
```

```cpp
ma_status ma_vincenty_inverse(ma_coordinate from, ma_coordinate to,
                              ma_ellipsoid ellipsoid, ma_inverse* out) {
    if (!out) return MA_INVALID_ARGUMENT;
    const auto r = geo::vincenty_inverse(to_cpp(from), to_cpp(to), to_cpp(ellipsoid));
    if (!r) return to_c(r.error());   // 실패: out을 건드리지 않고 돌아간다
    *out = to_c(*r);                   // 성공했을 때만 쓴다
    return MA_OK;
}
```

```swift
public static func vincentyInverse(
    from: Coordinate, to: Coordinate, ellipsoid: Ellipsoid = .wgs84
) throws(GeodesyError) -> InverseSolution {
    var out = ma_inverse()
    let status = ma_vincenty_inverse(from.c, to.c, ellipsoid.c, &out)
    guard status == MA_OK else { throw GeodesyError(status) }
    return InverseSolution(out)
}
```

</details>

Swift에서 `&out`은 항상 유효한 포인터라 `MA_INVALID_ARGUMENT`는 여기까지 올 수 없습니다. 그래서 `GeodesyError(status)` 안에서 `precondition`으로 막아 둡니다. 도달할 수 없는 경우를 조용히 다른 오류로 바꾸지 않고, 일어나면 바로 드러나게 하는 것입니다.

## 13. 실패가 층을 넘는 방식

실패 하나를 세 층에 걸쳐 따라가 보겠습니다.

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/error-flow.svg" alt="not_converged가 C++, C, Swift를 넘는 과정" style="width: 100%;">

| 층 | 성공 | 실패 |
| --- | --- | --- |
| C++ | `std::expected`에 값 | `std::unexpected(GeodesyError::not_converged)` |
| C | `MA_OK`, 결과는 `out`에 | `MA_NOT_CONVERGED`, `out`은 그대로 |
| Swift | 값을 반환 | `throw GeodesyError.notConverged` |

실패는 층을 넘을 때마다 **그 언어에서 자연스러운 방식**으로 바뀝니다. C++ 개발자는 `expected`를, C 개발자는 상태 코드를, Swift 개발자는 `throws`를 봅니다. 어느 층에서도 예외가 경계를 넘지 않습니다.

## 14. 빌드 두 갈래 - CMake와 SwiftPM

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/build-paths.svg" alt="같은 소스를 CMake와 SwiftPM으로 빌드" style="width: 100%;">

소스는 한 벌인데 빌드 시스템은 두 개입니다.

| | CMake | SwiftPM |
| --- | --- | --- |
| 쓰는 곳 | C++ 테스트, 이후 Android NDK | iOS·macOS 앱 |
| 만드는 것 | 정적 라이브러리 `marine`(코어), `marine_c`(다리층) | `CMarineAlgorithms` + `MarineAlgorithms` 모듈 |
| 컴파일 플래그 | `-Wall -Wextra -Wpedantic -Werror -ffp-contract=off` | 원격 의존성으로 쓰이려면 `unsafeFlags`를 쓸 수 없음 |
| 테스트 | Catch2 (ASan + UBSan) | Swift Testing |

<details class="notion-toggle-list" markdown="1">
<summary>CMakeLists.txt - 코드 보기</summary>

```cmake
cmake_minimum_required(VERSION 3.24)
project(marine_algorithms VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(MARINE_BUILD_TESTS "Build C++ tests" ${PROJECT_IS_TOP_LEVEL})
option(MARINE_SANITIZE "Build with AddressSanitizer + UBSan" OFF)

if(MARINE_SANITIZE)
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
endif()

# C++ 코어
add_library(marine src/geodesy/haversine.cpp src/geodesy/vincenty.cpp)
target_include_directories(marine PUBLIC ${PROJECT_SOURCE_DIR}/include)
target_compile_options(marine PRIVATE -Wall -Wextra -Wpedantic -Werror -ffp-contract=off)

# C 다리층
add_library(marine_c bindings/c/marine_c.cpp)
target_include_directories(marine_c PUBLIC ${PROJECT_SOURCE_DIR}/bindings/c/include)
target_link_libraries(marine_c PRIVATE marine)
target_compile_options(marine_c PRIVATE -Wall -Wextra -Wpedantic -Werror)

if(MARINE_BUILD_TESTS)
    include(FetchContent)
    FetchContent_Declare(Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG v3.7.1
        GIT_SHALLOW TRUE)
    FetchContent_MakeAvailable(Catch2)

    enable_testing()
    add_executable(marine_tests
        tests/cpp/haversine_test.cpp tests/cpp/vincenty_test.cpp
        tests/cpp/units_test.cpp tests/cpp/c_api_test.cpp)
    target_link_libraries(marine_tests PRIVATE marine marine_c Catch2::Catch2WithMain)
    include(Catch)
    catch_discover_tests(marine_tests)
endif()
```

</details>

`marine_c`가 `marine`을 `PRIVATE`로 링크하는 점을 보면, 다리층을 쓰는 쪽에는 C++ 헤더 경로가 전파되지 않습니다. SwiftPM의 `publicHeadersPath` / `headerSearchPath` 구분과 같은 일을 CMake에서 하는 것입니다.

## 15. 테스트는 층마다 맡는 것이 다르다

같은 내용을 세 층에서 반복해서 테스트하지 않습니다. 층마다 맡는 질문이 다릅니다.

| 층 | 묻는 것 | 도구 |
| --- | --- | --- |
| C++ | 알고리즘이 **정확한가** | Catch2, 공개 기준값(GeodTest) |
| C API | 코어와 **같은 값을** 돌려주는가 | Catch2 |
| Swift | 바인딩이 **제대로 이어졌는가** | Swift Testing(`@Test`) |

### C++ - 공개 기준값과 비교

정확도 기준값은 GeographicLib이 공개한 측지선 테스트 데이터 GeodTest에서 400쌍을 가져왔습니다.

<details class="notion-toggle-list" markdown="1">
<summary>vincenty_test.cpp - 코드 보기</summary>

```cpp
TEST_CASE("vincenty_inverse: 수렴하면 GeodTest와 맞고, 실패는 대척점 근처에서만 난다") {
    const auto cases = marine::test::load_geodtest();
    REQUIRE(cases.size() == 400);

    int failures = 0;
    double worst_distance = 0, min_failed_arc = 180;
    for (const auto& c : cases) {
        const auto r = vincenty_inverse({c.lat1, c.lon1}, {c.lat2, c.lon2});
        if (!r) {
            CHECK(r.error() == GeodesyError::not_converged);
            ++failures;
            min_failed_arc = std::min(min_failed_arc, c.a12);
            continue;
        }
        worst_distance = std::max(worst_distance, std::fabs(r->distance - c.s12));
    }
    CHECK(worst_distance < 1e-3);
    // 실패는 보조 구 위의 호가 179도를 넘는(대척점에서 1도 안쪽) 경우에만.
    CHECK(min_failed_arc > 179);
}
```

</details>

이 테스트는 "정확하다"만 보지 않고 **"실패는 대척점 근처에서만 난다"**도 같이 확인합니다. 실패를 허용하는 함수라면, 실패가 엉뚱한 곳에서 나지 않는다는 것까지 테스트해야 합니다.

ASan + UBSan을 켜고 돌린 결과입니다.

```text
vincenty_inverse: failures=66, min failed a12=179.542755, worst distance error=7.813e-05 m
vincenty_direct: worst position error=9.034e-05 m
===============================================================================
All tests passed (539 assertions in 13 test cases)
```

| | 수렴 | 최대 오차 | 실패한 쌍 |
| --- | --- | --- | --- |
| 역문제 (두 점 → 거리·방위) | 334 / 400 | **0.078mm** | 66쌍, 모두 보조 구 위 호 179.54° 이상(대척점 근처) |
| 정문제 (출발점·방위·거리 → 도착점) | 400 / 400 | **0.090mm** | 없음 |

### C API - 코어와 같은지만

```cpp
SECTION("수렴하지 않으면 MA_NOT_CONVERGED, out은 그대로") {
    ma_inverse out{-1, -1, -1};
    CHECK(ma_vincenty_inverse({0, 0}, {0.5, 179.7}, ma_wgs84(), &out) == MA_NOT_CONVERGED);
    CHECK(out.distance == -1);
}
```

다리층 테스트는 정확도를 다시 재지 않고 `ma_haversine_distance(...) == geo::haversine_distance(...)`처럼 **코어 결과와 비트 단위로 같은지**만 봅니다. 그리고 "실패하면 out은 그대로" 규칙을 여기서 고정합니다.

### Swift - 이어졌는지만

Swift 쪽 11개 테스트는 "부산-후쿠오카 거리가 맞는 범위인가", "대척점에서 `throw`가 나오는가" 정도만 봅니다. 정확도는 이미 C++에서 0.1mm 단위로 확인했으니까요.

```text
$ swift test
✔ Suite UnitsTests passed after 0.001 seconds.
✔ Suite GeodesyTests passed after 0.001 seconds.
✔ Test run with 11 tests in 2 suites passed after 0.001 seconds.
```

## 16. 데모 앱에서 확인하기

레포의 `demo/`에는 이 라이브러리를 로컬 패키지로 가져다 쓰는 SwiftUI 데모 앱이 있습니다. 앱 코드는 `import MarineAlgorithms`만 하고, C나 C++는 전혀 보지 않습니다. iPhone 17 시뮬레이터(iOS 27)에서 실행한 화면입니다.

<div style="display: flex; flex-wrap: wrap; gap: 16px; justify-content: center;">
  <figure style="width: 240px; margin: 0;">
    <img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/sim-list.jpg" alt="데모 앱 예제 목록" style="width: 100%;">
    <figcaption style="font-size: 0.8em; text-align: center;">예제 목록</figcaption>
  </figure>
  <figure style="width: 240px; margin: 0;">
    <img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/sim-haversine.jpg" alt="하버사인 거리 예제, 부산-후쿠오카 209.543km" style="width: 100%;">
    <figcaption style="font-size: 0.8em; text-align: center;">하버사인: 부산 → 후쿠오카</figcaption>
  </figure>
</div>

<div style="display: flex; flex-wrap: wrap; gap: 16px; justify-content: center; margin-top: 16px;">
  <figure style="width: 240px; margin: 0;">
    <img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/sim-vincentyInverse.jpg" alt="Vincenty 역문제 예제, 부산-로스앤젤레스" style="width: 100%;">
    <figcaption style="font-size: 0.8em; text-align: center;">Vincenty 역문제: 부산 → LA</figcaption>
  </figure>
  <figure style="width: 240px; margin: 0;">
    <img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/sim-antipodal.jpg" alt="대척점에서 notConverged를 받아 하버사인으로 대신 계산" style="width: 100%;">
    <figcaption style="font-size: 0.8em; text-align: center;">대척점: notConverged → 하버사인</figcaption>
  </figure>
</div>

| 화면 | 값 | 확인할 것 |
| --- | --- | --- |
| 하버사인 | 부산 → 후쿠오카 209.543km (113.144해리), 처음 방위 142.9974° | MiniNav 테스트 값과 같다. 같은 공식, 같은 반경 |
| Vincenty 역문제 | 부산 → LA 9,664.214km, 하버사인 9,643.864km | 타원체와 구의 차이가 약 20km(0.2%) |
| 대척점 | (0, 0) → (0.5, 179.7): `notConverged`, 하버사인으로 19,950.277km | C++의 `std::unexpected`가 Swift `catch`까지 왔다 |

마지막 화면이 13장의 실패 경로가 실제 앱에서 동작하는 모습입니다. 앱 코드는 이것뿐입니다.

```swift
do {
    d = try Geodesy.vincentyInverse(from: a, to: b).distance
} catch .notConverged {
    d = Geodesy.haversineDistance(from: a, to: b)
}
```

## 17. 실제로 걸렸던 함정들

### FMA가 같은 점의 거리를 0이 아니게 만든다

컴파일러는 `a * b + c`를 FMA(fused multiply-add) 명령 하나로 합칠 수 있습니다. 반올림을 한 번만 하니 보통은 더 정확하지만, **두 값이 서로 지워지도록 짠 식**에서는 오히려 결과가 어긋납니다. 같은 점 사이의 거리가 정확히 0이 아니게 되는 식입니다.

CMake에는 `-ffp-contract=off`를 줬는데, SwiftPM에는 같은 플래그를 줄 마땅한 방법이 없습니다. `unsafeFlags`가 있지만 이걸 쓰면 다른 패키지가 이 패키지를 원격 의존성으로 가져올 수 없습니다. 그래서 소스 파일에 직접 적었습니다.

```cpp
// 곱셈·덧셈을 FMA 하나로 합치지 않는다. SwiftPM은 컴파일 플래그를 줄 수 없어 소스에 둔다.
#if defined(__clang__)
#pragma clang fp contract(off)
#endif
```

빌드 시스템이 두 개면 **한쪽에만 준 컴파일 플래그는 없는 것과 같다**고 보는 게 안전합니다. 결과에 영향을 주는 설정은 소스에 두는 편이 낫습니다.

### 반올림 때문에 생기는 NaN과 360°

부동소수점 계산에서는 수학적으로 불가능한 값이 나옵니다.

```cpp
// 하버사인: 반올림 오차로 a가 1을 살짝 넘으면 sqrt(1 - a)가 NaN이 된다.
const double c = 2 * std::atan2(std::sqrt(a), std::sqrt(std::fmax(0.0, 1 - a)));

// 방위를 [0, 360)으로: -1e-20 + 360처럼 반올림으로 360이 되는 경우.
inline double normalize_bearing(double degrees) noexcept {
    double r = std::fmod(degrees, 360.0);
    if (r < 0) r += 360.0;
    return r >= 360.0 ? 0.0 : r + 0.0;   // + 0.0은 -0.0을 0.0으로
}
```

API 문서에 "방위는 [0, 360)"이라고 적었다면, 360.0이나 -0.0이 나오지 않는다는 것까지 코드로 보장해야 합니다. 다른 언어로 넘어간 뒤에 `== 0` 비교나 `switch`가 어긋나면 원인을 찾기가 훨씬 어렵습니다.

### Linux에서 std::expected가 없다

CI는 Ubuntu에서 돌립니다. macOS의 Swift 툴체인은 libc++를 쓰지만 Linux의 Swift는 시스템 libstdc++를 씁니다. `std::expected`는 libstdc++ 12부터 들어왔기 때문에, 오래된 이미지에서는 C++ 타겟이 빌드되지 않습니다. 그래서 Ubuntu 24.04(libstdc++ 13) 기반 Swift 이미지를 씁니다.

```yaml
swift:
  runs-on: ubuntu-latest
  container: swift:6.2-noble  # Ubuntu 24.04: libstdc++ 13에 std::expected가 있다
```

### Swift에서 UBSan을 켜면 링크 오류

C++는 ASan + UBSan으로 돌리는데, Swift 테스트에서도 C++ 코드까지 검사하고 싶었습니다. 그런데 기본 빌드 시스템으로 `--sanitize=undefined`를 주면 UBSan 런타임이 링크되지 않아 링크 오류가 납니다. 빌드 시스템을 native로 바꾸면 됩니다.

```sh
swift test --build-system native --sanitize=address --sanitize=undefined
```

## 18. 다음 단계 - 상태 있는 객체

지금까지는 **상태 없는 계산**만 있어서 C 다리층이 쉬웠습니다. 값 구조체를 넘기고 값이나 상태 코드를 받으면 끝입니다.

로드맵의 다음 모듈들은 C 다리층에 새로운 모양을 하나씩 추가합니다.

| 버전 | 모듈 | 새로 생기는 C 다리층 모양 |
| --- | --- | --- |
| 0.1 | 기반 + 대권 거리 | 값 구조체 + 자유 함수 |
| 0.2 | `geodesy` 완성 | 실패를 알리는 `ma_status` |
| 0.3 | `collision` CPA/TCPA | 결과 구조체 |
| 0.4 | `motion` 운동 예측 | |
| 0.5 | `filter` 칼만 필터 | 불투명 핸들 + new/free |
| 0.6 | `interpolation` 위치 보간기 | |

0.5의 칼만 필터는 측정이 들어올 때마다 내부 상태가 바뀌는 **상태 있는 객체**입니다. 3장 표의 "클래스는 경계를 넘을 수 없다 → 불투명 핸들"이 처음 쓰입니다. 아직 구현 전이지만 설계 규칙대로라면 이런 모양이 됩니다.

<details class="notion-toggle-list" markdown="1">
<summary>계획: 불투명 핸들 - 코드 보기</summary>

```c
/* 계획: 구현 전 */
typedef struct ma_filter ma_filter;          /* 내용은 C++만 안다 */

ma_filter* ma_filter_new(void);
ma_status  ma_filter_update(ma_filter* f, /* 측정값 */ ...);
void       ma_filter_free(ma_filter* f);
```

```swift
// 계획: 네이티브 자원을 쥔 타입만 class + deinit
public final class KalmanFilter {
    private let handle: OpaquePointer
    init() { handle = ma_filter_new() }
    deinit { ma_filter_free(handle) }
}
```

</details>

C 쪽은 `ma_filter`가 무엇인지 모르고 포인터만 들고 다닙니다(Swift에서는 `OpaquePointer`). 메모리는 C++가 만들고 C++가 지우며, Swift는 `deinit`에서 해제를 부르기만 합니다. 값 타입(`struct`)을 쓰던 Swift 쪽이 여기서 처음으로 `class`를 씁니다. 구조체로 두면 복사될 때 같은 핸들을 두 번 해제하게 되니까요.

&nbsp;

---

&nbsp;

## 정리

- C++ 함수는 이름이 mangling되어 다른 언어가 찾을 수 없습니다. **`extern "C"`로 C 이름을 내보내고**, 시그니처에는 C 타입만 씁니다.
- Swift는 `publicHeadersPath`의 헤더를 **C로 읽습니다.** 공개 헤더에는 C만, C++는 `.cpp`와 `headerSearchPath` 쪽에만 둡니다.
- C++ interop으로 바로 부를 수도 있지만, interop은 **쓰는 쪽 앱까지 전염**됩니다. 배포하는 라이브러리라면 C 다리층이 쓰는 쪽을 편하게 합니다.
- 실패는 층마다 그 언어의 방식으로 바꿉니다. **C++ `std::expected` → C 상태 코드 + out 포인터 → Swift typed throws.** 예외는 경계를 넘지 않습니다.
- 테스트는 층마다 맡는 질문이 다릅니다. 정확도는 C++에서, 다리층은 코어와 같은지, Swift는 이어졌는지만 봅니다.
- 빌드 시스템이 둘이면 **결과에 영향을 주는 설정은 소스에** 둡니다.

| 에러 메시지 | 먼저 볼 곳 |
| --- | --- |
| `Undefined symbols ... "_xx_함수"` | `extern "C"`, `nm -gU`로 심볼 이름 |
| `'<C++ 헤더>' file not found`, `could not build module` | 공개 헤더의 `#include` |
| `module 'X' was built with C++ interoperability enabled` | 쓰는 쪽 타겟의 `interoperabilityMode` |

다음 글에서는 0.3의 CPA/TCPA를 구현하면서, 위경도를 국지 평면(ENU)으로 바꿔 상대 운동을 푸는 과정을 정리해 보겠습니다.

&nbsp;

## 참고

- [indextrown/marine-algorithms](https://github.com/indextrown/marine-algorithms)
- [Swift.org - Mixing Swift and C++](https://www.swift.org/documentation/cxx-interop/)
- [Swift Package Manager - PackageDescription (target, publicHeadersPath)](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)
- [Clang - Modules (module map)](https://clang.llvm.org/docs/Modules.html)
- [cppreference - std::expected](https://en.cppreference.com/w/cpp/utility/expected)
- [cppreference - Language linkage (extern "C")](https://en.cppreference.com/w/cpp/language/language_linkage)
- [Swift Evolution SE-0413 Typed throws](https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md)
- T. Vincenty, *Direct and inverse solutions of geodesics on the ellipsoid with application of nested equations*, Survey Review 23(176), 88-93 (1975)
- [GeographicLib - Test data for geodesics (GeodTest)](https://geographiclib.sourceforge.io/C++/doc/geodesic.html#testgeod)
