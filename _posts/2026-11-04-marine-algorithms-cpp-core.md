---
title: "[C++] C++ 코어 하나로 Swift까지 - 해양 알고리즘 라이브러리 구조 잡기"
date: 2026-11-04 00:00:00 +0900
tags:
  - C++
  - Swift
---

## 왜 C++ 코어인가

선박 두 척 사이의 거리, 목적지까지의 방위, 가까워지는 시점(CPA/TCPA), 칼만 필터로 다듬은 위치. 해양 앱을 만들다 보면 이런 계산이 iOS에도, Android에도, 웹에도 똑같이 필요합니다.

플랫폼마다 Swift, Kotlin, JavaScript로 따로 구현하면 이런 일이 생깁니다.

- 같은 두 좌표인데 iOS와 Android가 서로 다른 거리를 보여줍니다. 공식이 같아도 반올림, 각도 정규화, 경계 처리가 조금씩 다르기 때문입니다.
- 버그를 고칠 때 세 군데를 고쳐야 하고, 정확도 테스트도 세 벌을 만들어야 합니다.

그래서 계산은 **C++ 한 곳에서 하고**, 각 플랫폼은 그 결과를 받아 쓰기만 하도록 [marine-algorithms](https://github.com/indextrown/marine-algorithms)라는 라이브러리를 만들고 있습니다. 지금은 측지 계산(하버사인, Vincenty)과 단위 변환까지 C++ 코어 → C 다리층 → Swift 바인딩으로 이어 놓았습니다.

이 글에서는 알고리즘 자체보다 **C++ 코어를 다른 언어에서 쓰게 만드는 구조**를 정리합니다.

1. 세 층으로 나눈 구조
2. C++ 코어 - `noexcept` 자유 함수와 `std::expected`
3. C 다리층 - 왜 굳이 C를 한 번 거치는가
4. Swift 바인딩 - C 값을 Swift 값으로
5. 실패가 층을 넘는 방식
6. 빌드 두 갈래 - CMake와 SwiftPM
7. 테스트는 층마다 맡는 것이 다르다
8. 실제로 걸렸던 함정들
9. 다음 단계 - 상태 있는 객체

&nbsp;

---

&nbsp;

## 1. 세 층으로 나눈 구조

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/layers.svg" alt="C++ 코어, C 다리층, 언어 바인딩의 세 층 구조" style="width: 100%;">

```text
include/marine/        C++ 공개 헤더 (marine::)
src/                   C++ 구현
bindings/c/            C 다리층 (ma_ 접두사, extern "C")
bindings/swift/        Swift 래퍼와 테스트
tests/cpp/             C++ 테스트 (Catch2)
tests/data/            테스트 기준값 (GeodTest 일부)
```

규칙은 하나입니다. **언어 바인딩은 C 헤더 `marine_c.h`만 봅니다.** C++ 헤더는 바인딩에 노출하지 않습니다.

| 층 | 하는 일 | 모르는 것 |
| --- | --- | --- |
| C++ 코어 | 계산 | 누가 자신을 부르는지 |
| C 다리층 | C 타입 ↔ C++ 타입 변환, 실패를 상태 코드로 | 계산 방법 |
| Swift 바인딩 | C 값을 Swift 값 타입과 `throws`로 | C++ 존재 자체 |

각 층이 아는 범위를 좁혀 두면, 나중에 Kotlin(JNI)이나 WASM 바인딩을 붙일 때 C++ 코어는 한 줄도 바뀌지 않습니다. 새 바인딩은 이미 있는 C 함수를 부르기만 하면 됩니다.

&nbsp;

---

&nbsp;

## 2. C++ 코어

### 설계 규칙

| 규칙 | 이유 |
| --- | --- |
| C++23 | `std::expected`를 쓰기 위해. Android NDK r26(clang 17, libc++ 17)과 Swift 패키지 양쪽에서 빌드됩니다 |
| 외부 의존성 없음 (테스트용 Catch2만) | 모바일 빌드에 끌고 갈 것이 없어야 합니다 |
| 공개 API는 SI 단위와 도(°) | 거리 m, 시간 s, 속도 m/s. 내부 계산만 라디안 |
| 순수 계산은 `noexcept` 자유 함수 | 상태가 없으니 클래스가 필요 없습니다. 필터처럼 상태가 필요한 것만 클래스로 |
| 실패는 `std::expected`로 반환 | 예외를 쓰지 않으니 C 경계에서 잡을 것도 없습니다 |

### 공개 헤더

공개 헤더는 값 구조체와 함수 선언만 있습니다.

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

함수가 두 종류로 나뉘는 게 보입니다.

- **하버사인**은 지구를 구로 보고 닫힌 식으로 바로 계산합니다. 실패할 일이 없으니 `double`을 그대로 돌려줍니다.
- **Vincenty**는 지구를 타원체(WGS84)로 보고 고정점 반복으로 답을 찾습니다. 두 점이 거의 지구 반대편(대척점)에 있으면 반복이 흔들리며 수렴하지 않습니다. 그래서 `std::expected<InverseSolution, GeodesyError>`를 돌려줍니다.

### std::expected

`std::expected<T, E>`는 "값 `T`가 들어 있거나, 오류 `E`가 들어 있는" 상자입니다. Swift의 `Result<T, E>`와 거의 같습니다.

```cpp
// vincenty.cpp 안쪽, 반복 루프
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

쓰는 쪽은 이렇게 확인합니다.

```cpp
const auto r = vincenty_inverse(busan, fukuoka);
if (!r) {
    // r.error() == GeodesyError::not_converged
    return;
}
std::println("{} m", r->distance);
```

예외를 던지면 C 경계에서 반드시 `try/catch`로 막아야 합니다. 막지 못하면 Swift나 JNI 쪽으로 넘어가 프로세스가 죽습니다. `std::expected`는 **실패가 함수 시그니처에 드러나고**, 그냥 반환값이라 C 다리층에서 `if` 하나로 상태 코드로 바꿀 수 있습니다.

&nbsp;

---

&nbsp;

## 3. C 다리층

### 왜 C를 한 번 거치는가

Swift 5.9부터는 C++ 헤더를 직접 가져오는 C++ interop이 있습니다. 그래도 C 층을 따로 둔 이유는 이렇습니다.

- **모든 언어가 C를 부를 수 있습니다.** Swift는 C 헤더를 그대로 import하고, Kotlin은 JNI로, WASM은 Emscripten export로 C 함수를 부릅니다. C++ 타입(`std::expected`, 템플릿, 네임스페이스)은 언어마다 받아들이는 방식이 다르거나 아예 못 받습니다.
- **C++ 타입이 바뀌어도 바인딩이 깨지지 않습니다.** C++ 쪽 구조체에 필드를 바꾸거나 내부 구현을 고쳐도, C 함수 시그니처만 그대로면 Swift 래퍼 코드는 고칠 필요가 없습니다.
- **경계가 눈에 보입니다.** 무엇이 공개 API인지 `marine_c.h` 한 파일만 보면 됩니다.

### 다리층 규칙

| 규칙 | 이유 |
| --- | --- |
| 값으로 넘길 수 있는 건 POD 구조체(`ma_coordinate`) | 수명 관리가 필요 없습니다 |
| 상태 있는 객체는 불투명 핸들 + `ma_*_new` / `ma_*_free` | C++ 타입을 숨기고, 누가 해제하는지 분명히 합니다 |
| 예외를 넘기지 않습니다. 실패할 수 있는 함수는 `ma_status`를 돌려주고 결과는 out 포인터에 씁니다. 실패하면 out은 건드리지 않습니다 | C·JNI·WASM은 C++ 예외를 받을 수 없습니다 |
| 실패하지 않는 함수는 결과를 값으로 돌려줍니다 | 쓰는 쪽이 상태를 확인할 필요가 없습니다 |
| 콜백을 두지 않습니다(pull 방식) | 거꾸로 넘어가는 콜백은 바인딩마다 가장 까다로운 부분입니다 |

### 헤더

```c
#ifdef __cplusplus
extern "C" {
#endif

typedef enum ma_status {
    MA_OK = 0,
    MA_NOT_CONVERGED = 1,     /* Vincenty 역문제의 대척점 근처 */
    MA_INVALID_ARGUMENT = 2,  /* out 포인터가 NULL */
} ma_status;

typedef struct ma_coordinate {
    double latitude;
    double longitude;
} ma_coordinate;

typedef struct ma_inverse {
    double distance;
    double initial_bearing;
    double final_bearing;
} ma_inverse;

/* 실패하지 않음: 값 반환 */
double ma_haversine_distance(ma_coordinate from, ma_coordinate to);

/* 실패할 수 있음: 상태 반환 + out 포인터 */
ma_status ma_vincenty_inverse(ma_coordinate from, ma_coordinate to,
                              ma_ellipsoid ellipsoid, ma_inverse* out);

#ifdef __cplusplus
}
#endif
```

몇 가지 포인트를 짚어보겠습니다.

- `extern "C"`는 C++ 컴파일러에게 **이름을 C 방식으로 내보내라**고 알려줍니다. C++는 오버로딩을 위해 함수 이름에 타입 정보를 섞어(name mangling) `_ZN6marine7geodesy18haversine_distance...` 같은 심볼을 만듭니다. C 방식이면 그냥 `ma_haversine_distance`입니다. 다른 언어는 이 이름으로 함수를 찾습니다.
- C에는 네임스페이스가 없으니 `ma_` 접두사가 그 역할을 합니다.
- `ma_coordinate`는 C++ `Coordinate`와 필드가 같지만 **일부러 다른 타입**입니다. 바인딩이 C++ 헤더를 몰라도 되게 하려는 것입니다.
- C++ 쪽은 `Ellipsoid` 기본값(`= kWGS84`)이 있지만 C에는 기본 인자가 없습니다. 그래서 `ma_wgs84()` 함수로 값을 꺼내 넘깁니다.

### 구현

구현은 "C 타입을 C++ 타입으로 → 코어 호출 → 결과를 C 타입으로"가 전부입니다.

```cpp
namespace {

namespace geo = marine::geodesy;

geo::Coordinate to_cpp(ma_coordinate c) noexcept { return {c.latitude, c.longitude}; }

ma_inverse to_c(const geo::InverseSolution& r) noexcept {
    return {r.distance, r.initial_bearing, r.final_bearing};
}

ma_status to_c(geo::GeodesyError error) noexcept {
    switch (error) {
    case geo::GeodesyError::not_converged: return MA_NOT_CONVERGED;
    }
    return MA_NOT_CONVERGED;
}

} // namespace

extern "C" {

double ma_haversine_distance(ma_coordinate from, ma_coordinate to) {
    return geo::haversine_distance(to_cpp(from), to_cpp(to));
}

ma_status ma_vincenty_inverse(ma_coordinate from, ma_coordinate to,
                              ma_ellipsoid ellipsoid, ma_inverse* out) {
    if (!out) return MA_INVALID_ARGUMENT;
    const auto r = geo::vincenty_inverse(to_cpp(from), to_cpp(to), to_cpp(ellipsoid));
    if (!r) return to_c(r.error());   // 실패: out을 건드리지 않고 돌아간다
    *out = to_c(*r);                   // 성공했을 때만 쓴다
    return MA_OK;
}

} // extern "C"
```

변환 함수는 익명 네임스페이스에 둬서 이 파일 밖으로 나가지 않습니다. `to_c(GeodesyError)`의 `switch`는 `enum class`에 값이 추가되면 `-Wall -Werror` 아래에서 "처리하지 않은 case" 경고가 에러로 바뀌어, 다리층을 고치지 않고는 빌드가 되지 않습니다.

"실패하면 out을 건드리지 않는다"는 규칙은 작아 보이지만, 쓰는 쪽이 out을 미리 초기화해 두고 실패해도 그 값을 믿을 수 있게 해줍니다. 이 규칙은 테스트로 고정해 두었습니다(7장).

&nbsp;

---

&nbsp;

## 4. Swift 바인딩

### 패키지 구성

SwiftPM 타겟은 두 개입니다.

```swift
// swift-tools-version: 6.0
let package = Package(
    name: "MarineAlgorithms",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "MarineAlgorithms", targets: ["MarineAlgorithms"]),
    ],
    targets: [
        // C++ 코어 + C 다리층. Swift에는 marine_c.h 하나만 보인다.
        .target(
            name: "CMarineAlgorithms",
            path: ".",
            sources: ["src", "bindings/c/marine_c.cpp"],
            publicHeadersPath: "bindings/c/include",
            cxxSettings: [.headerSearchPath("include")]
        ),
        .target(
            name: "MarineAlgorithms",
            dependencies: ["CMarineAlgorithms"],
            path: "bindings/swift/Sources/MarineAlgorithms"
        ),
    ],
    cxxLanguageStandard: .cxx2b
)
```

핵심은 두 설정입니다.

- `publicHeadersPath: "bindings/c/include"` - 이 폴더의 헤더(`marine_c.h`)만 Swift에 보입니다. SwiftPM이 이 헤더로 모듈맵을 만들어 줘서 `import CMarineAlgorithms`가 됩니다.
- `.headerSearchPath("include")` - C++ 헤더(`include/marine/`)는 이 타겟을 **컴파일할 때만** 쓰입니다. Swift 쪽에는 노출되지 않습니다.

앱은 C 모듈이 아니라 `MarineAlgorithms`만 의존합니다. `CMarineAlgorithms`는 product에 없어서 앱에서 직접 부를 일이 없습니다.

### C 값을 Swift 값으로

Swift 래퍼는 C 구조체를 Swift 값 타입으로 감쌉니다.

```swift
import CMarineAlgorithms

public struct Coordinate: Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) { ... }

    init(_ c: ma_coordinate) {                       // C → Swift (internal)
        self.init(latitude: c.latitude, longitude: c.longitude)
    }

    var c: ma_coordinate {                           // Swift → C (internal)
        ma_coordinate(latitude: latitude, longitude: longitude)
    }
}
```

C 쪽으로 가는 변환(`init(_:)`, `c`)은 `internal`이라 라이브러리 밖에서는 `ma_coordinate`를 볼 일이 없습니다. 쓰는 쪽은 그냥 Swift 구조체를 씁니다. `Hashable`, `Sendable`도 붙일 수 있습니다.

### 상태 코드를 typed throws로

```swift
public enum GeodesyError: Error, Hashable, Sendable {
    case notConverged
}

public enum Geodesy {
    public static func haversineDistance(from: Coordinate, to: Coordinate) -> Double {
        ma_haversine_distance(from.c, to.c)
    }

    public static func vincentyInverse(
        from: Coordinate, to: Coordinate, ellipsoid: Ellipsoid = .wgs84
    ) throws(GeodesyError) -> InverseSolution {
        var out = ma_inverse()
        let status = ma_vincenty_inverse(from.c, to.c, ellipsoid.c, &out)
        guard status == MA_OK else { throw GeodesyError(status) }
        return InverseSolution(out)
    }
}
```

- `&out`으로 Swift 변수를 C의 out 포인터에 넘깁니다. 포인터는 항상 유효하니 `MA_INVALID_ARGUMENT`는 여기까지 올 수 없고, `GeodesyError(status)` 안에서 `precondition`으로 막아 둡니다.
- Swift 6의 **typed throws**(`throws(GeodesyError)`) 덕분에 쓰는 쪽은 오류 타입을 정확히 압니다. `catch .notConverged`처럼 바로 패턴 매칭할 수 있습니다.
- C에서 사라졌던 기본 인자(`ellipsoid = .wgs84`)도 Swift에서 되살립니다.

쓰는 쪽에서는 C++가 있다는 걸 전혀 모릅니다.

```swift
import MarineAlgorithms

let busan = Coordinate(latitude: 35.1028, longitude: 129.0403)
let fukuoka = Coordinate(latitude: 33.5902, longitude: 130.4017)

Geodesy.haversineDistance(from: busan, to: fukuoka)   // 구면 근사, 약 208 km
Units.metersToNauticalMiles(208_000)                  // 약 112.3 해리

do {
    let r = try Geodesy.vincentyInverse(from: busan, to: fukuoka)   // WGS84
    print(r.distance, r.initialBearing)
} catch .notConverged {
    // 대척점 근처. 하버사인으로 대신한다.
}
```

&nbsp;

---

&nbsp;

## 5. 실패가 층을 넘는 방식

지금까지 본 내용을 실패 하나로 따라가 보겠습니다.

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/error-flow.svg" alt="not_converged가 C++, C, Swift를 넘는 과정" style="width: 100%;">

| 층 | 성공 | 실패 |
| --- | --- | --- |
| C++ | `std::expected`에 값 | `std::unexpected(GeodesyError::not_converged)` |
| C | `MA_OK`, 결과는 `out`에 | `MA_NOT_CONVERGED`, `out`은 그대로 |
| Swift | 값을 반환 | `throw GeodesyError.notConverged` |

실패는 층을 넘을 때마다 **그 언어에서 자연스러운 방식**으로 바뀝니다. C++ 개발자는 `expected`를, C 개발자는 상태 코드를, Swift 개발자는 `throws`를 봅니다. 어느 층에서도 예외가 경계를 넘지 않습니다.

&nbsp;

---

&nbsp;

## 6. 빌드 두 갈래 - CMake와 SwiftPM

<img src="/assets/img/2026-11-04-marine-algorithms-cpp-core/build-paths.svg" alt="같은 소스를 CMake와 SwiftPM으로 빌드" style="width: 100%;">

소스는 한 벌인데 빌드 시스템은 두 개입니다.

- **CMake**는 C++ 테스트를 돌리는 길이고, 나중에 Android NDK가 쓸 길입니다. 코어(`marine`)와 다리층(`marine_c`)을 각각 정적 라이브러리로 만들고, 테스트에서만 Catch2를 받아 옵니다.
- **SwiftPM**은 iOS·macOS 앱이 실제로 가져다 쓰는 길입니다. `Package.swift`가 같은 `src/`와 `bindings/c/marine_c.cpp`를 직접 컴파일합니다.

<details class="notion-toggle-list" markdown="1">
<summary>CMakeLists.txt 보기</summary>

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

`marine_c`가 `marine`을 `PRIVATE`로 링크하는 점을 보면, 다리층을 쓰는 쪽에는 C++ 헤더 경로가 전파되지 않습니다. CMake에서도 "바인딩은 C 헤더만 본다"는 규칙이 그대로 지켜집니다.

&nbsp;

---

&nbsp;

## 7. 테스트는 층마다 맡는 것이 다르다

같은 내용을 세 층에서 반복해서 테스트하지 않습니다. 층마다 맡는 질문이 다릅니다.

| 층 | 묻는 것 | 도구 |
| --- | --- | --- |
| C++ | 알고리즘이 **정확한가** | Catch2, 공개 기준값(GeodTest) |
| C API | 코어와 **같은 값을** 돌려주는가 | Catch2 |
| Swift | 바인딩이 **제대로 이어졌는가** | Swift Testing(`@Test`) |

### C++ - 공개 기준값과 비교

정확도 기준값은 GeographicLib이 공개한 측지선 테스트 데이터 GeodTest에서 400쌍을 가져왔습니다.

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

이 테스트는 "정확하다"만 보지 않고 **"실패는 대척점 근처에서만 난다"**도 같이 확인합니다. 실패를 허용하는 함수라면, 실패가 엉뚱한 곳에서 나지 않는다는 것까지 테스트해야 합니다.

ASan + UBSan을 켜고 실제로 돌린 결과는 이렇습니다.

```text
vincenty_inverse: failures=66, min failed a12=179.542755, worst distance error=7.813e-05 m
vincenty_direct: worst position error=9.034e-05 m
===============================================================================
All tests passed (539 assertions in 13 test cases)
```

- 역문제: 400쌍 중 66쌍이 수렴하지 않았고, 모두 보조 구 위 호가 179.54° 이상인 대척점 근처였습니다. 수렴한 쌍의 최대 오차는 **0.078mm**입니다.
- 정문제: 400쌍 모두 수렴했고 최대 위치 오차는 **0.090mm**입니다.

### C API - 코어와 같은지만

```cpp
SECTION("수렴하지 않으면 MA_NOT_CONVERGED, out은 그대로") {
    ma_inverse out{-1, -1, -1};
    CHECK(ma_vincenty_inverse({0, 0}, {0.5, 179.7}, ma_wgs84(), &out) == MA_NOT_CONVERGED);
    CHECK(out.distance == -1);
}
SECTION("out이 NULL이면 MA_INVALID_ARGUMENT") {
    CHECK(ma_vincenty_inverse(kBusan, kFukuoka, ma_wgs84(), nullptr) == MA_INVALID_ARGUMENT);
}
```

다리층 테스트는 정확도를 다시 재지 않고 `ma_haversine_distance(...) == geo::haversine_distance(...)`처럼 **코어 결과와 비트 단위로 같은지**만 봅니다. 그리고 3장의 "실패하면 out은 그대로" 규칙을 여기서 고정합니다.

### Swift - 이어졌는지만

```swift
// 바인딩이 제대로 이어졌는지만 본다. 정확도는 C++ 테스트에서 본다.
@Test func vincentyThrowsNearAntipode() {
    #expect(throws: GeodesyError.notConverged) {
        try Geodesy.vincentyInverse(
            from: Coordinate(latitude: 0, longitude: 0),
            to: Coordinate(latitude: 0.5, longitude: 179.7))
    }
}
```

Swift 쪽 11개 테스트는 "부산-후쿠오카가 대략 208km인가", "대척점에서 throw가 나오는가" 정도만 봅니다. 정확도는 이미 C++에서 0.1mm 단위로 확인했으니까요.

&nbsp;

---

&nbsp;

## 8. 실제로 걸렸던 함정들

### FMA가 같은 점의 거리를 0이 아니게 만든다

컴파일러는 `a * b + c`를 FMA(fused multiply-add) 명령 하나로 합칠 수 있습니다. 반올림을 한 번만 하니 보통은 더 정확하지만, **두 값이 서로 지워지도록 짠 식**에서는 오히려 결과가 어긋납니다. 같은 점 사이의 거리가 정확히 0이 아니게 되는 식입니다.

CMake에는 `-ffp-contract=off`를 줬는데, SwiftPM에는 같은 플래그를 줄 마땅한 방법이 없습니다. `unsafeFlags`가 있지만 이걸 쓰면 다른 패키지가 이 패키지를 원격 의존성으로 가져올 수 없습니다. 그래서 소스 파일에 직접 적었습니다.

```cpp
// 곱셈·덧셈을 FMA 하나로 합치지 않는다. 합치면 같은 점의 거리가 0이 아니게 되는 등
// 상쇄를 노린 식이 어긋난다. SwiftPM은 컴파일 플래그를 줄 수 없어 소스에 둔다.
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
  steps:
    - uses: actions/checkout@v4
    - run: swift test
```

### Swift에서 UBSan을 켜면 링크 오류

C++는 ASan + UBSan으로 돌리는데, Swift 테스트에서도 C++ 코드까지 검사하고 싶었습니다. 그런데 기본 빌드 시스템으로 `--sanitize=undefined`를 주면 UBSan 런타임이 링크되지 않아 링크 오류가 납니다. 빌드 시스템을 native로 바꾸면 됩니다.

```sh
swift test --build-system native --sanitize=address --sanitize=undefined
```

&nbsp;

---

&nbsp;

## 9. 다음 단계 - 상태 있는 객체

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

0.5의 칼만 필터는 측정이 들어올 때마다 내부 상태가 바뀌는 **상태 있는 객체**입니다. 이때 다리층 규칙의 "불투명 핸들 + `ma_*_new` / `ma_*_free`"가 처음 쓰입니다. 아직 구현 전이지만 설계 규칙대로라면 이런 모양이 됩니다.

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

C 쪽은 `ma_filter`가 무엇인지 모르고 포인터만 들고 다닙니다. 메모리는 C++가 만들고 C++가 지우며, Swift는 `deinit`에서 해제를 부르기만 합니다. 값 타입(`struct`)을 쓰던 Swift 쪽이 여기서 처음으로 `class`를 쓰게 됩니다. 복사되면 같은 핸들을 두 번 해제하게 되니까요.

&nbsp;

---

&nbsp;

## 정리

- 계산은 **C++ 코어 한 곳**에서 하고, 각 언어는 결과를 받아 쓰기만 합니다.
- 코어는 `noexcept` 자유 함수와 `std::expected`로, **예외 없이 실패를 반환값으로** 드러냅니다.
- 그 사이에 **C 다리층**을 둬서 모든 언어 바인딩이 `marine_c.h` 하나만 보게 합니다. 실패는 `ma_status` + out 포인터로, 실패하면 out은 건드리지 않습니다.
- Swift 바인딩은 C 값을 Swift 값 타입으로, 상태 코드를 **typed throws**로 바꿉니다. 쓰는 쪽은 C++가 있다는 걸 모릅니다.
- 테스트는 층마다 맡는 질문이 다릅니다. 정확도는 C++에서, 다리층은 코어와 같은지, Swift는 이어졌는지만 봅니다.
- 빌드 시스템이 둘이면 **결과에 영향을 주는 설정은 소스에** 둡니다.

다음 글에서는 0.3의 CPA/TCPA를 구현하면서, 위경도를 국지 평면(ENU)으로 바꿔 상대 운동을 푸는 과정을 정리해 보겠습니다.

&nbsp;

## 참고

- [indextrown/marine-algorithms](https://github.com/indextrown/marine-algorithms)
- T. Vincenty, *Direct and inverse solutions of geodesics on the ellipsoid with application of nested equations*, Survey Review 23(176), 88-93 (1975)
- [GeographicLib - Test data for geodesics (GeodTest)](https://geographiclib.sourceforge.io/C++/doc/geodesic.html#testgeod)
- [cppreference - std::expected](https://en.cppreference.com/w/cpp/utility/expected)
- [Swift Evolution SE-0413 Typed throws](https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md)
