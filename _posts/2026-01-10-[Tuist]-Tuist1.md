---
title: "Tuist 세팅"
tags:
- Tuist
header:
  teaser:
typora-root-url: ../
---

<!-- <img src="{{ '이미지경로' | relative_url }}" alt="이미지" width="30%"> -->

## 프로젝트 생성
```bash
# 현재 디렉토리를 Tuist 프로젝트로 초기화
# - Project.swift, Tuist/Config.swift 등이 생성됨
tuist init

# Tuist 프로젝트 루트로 이동
cd 프로젝트

# tuist 편집(선택)
tuist edit

# Xcode 프로젝트(.xcodeproj) 생성
tuist generate
```

## 프로젝트 루트에 Workspace.swift 생성
```swift
// Workspace.swift
import ProjectDescription

let workspace = Workspace(
    name: "SwiftUIApp",
    projects: [
        "Project/App",
        "Project/Feature/*"
    ]
)
```
- Workspace는 여러 Project를 하나의 Xcode Workspace로 묶는 역할을 합니다.
- `Project.swift` -> 하나의 모듈(앱, 프레임워크 등)
- `Workspace.swift` -> 여러 Project를 묶는 컨테이너
- Xcode에서 .xcworkspace가 생성되는 구조입나다.

