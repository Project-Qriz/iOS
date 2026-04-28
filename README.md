# QRIZ - SQLD 자격증 모의고사 앱
<img width="1600" height="545" alt="Group 1597880808" src="https://github.com/user-attachments/assets/cf88475b-eb9a-404c-ae21-d6114c4d882a"/>
<br>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.0-F05138?style=flat&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/iOS-17.0+-000000?style=flat&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Xcode-16-147EFB?style=flat&logo=xcode&logoColor=white" />
  <a href="https://apps.apple.com/kr/app/qriz/id6755752454">
    <img src="https://img.shields.io/badge/App_Store-0D96F6?style=flat&logo=app-store&logoColor=white" alt="App Store"/>
  </a>
</p>

<br>

## 🎯 프로젝트 소개
<img width="1103" height="1294" alt="Container" src="https://github.com/user-attachments/assets/5047da04-21c0-4645-8d5f-6ccc42cf4ae3" />

<br>

> 📅 **개발 기간:** 2025.01 ~ 현재 &nbsp;|&nbsp;**팀 구성:** iOS 2명, Backend 1명, Design: 1명

<br>

## 🛠 기술 스택

| 분류 | 내용 |
|:---|:---|
| 언어 | Swift 5 |
| UI | UIKit / SwiftUI 혼용 |
| 반응형 | Combine |
| 아키텍처 | Coordinator + MVVM |
| 패키지 관리 | Swift Package Manager |
| 소셜 로그인 | Kakao, Google, Apple |
| 분석 | Firebase Analytics |
| 테스트 | XCTest, swift-snapshot-testing |

<br>

## 🏛 아키텍처

### MVVM + Coordinator
Coordinator가 화면 전환과 의존성 주입을 담당하고 ViewController는 UI 바인딩에 집중합니다. ViewModel은 Input/Output 패턴으로 단방향 데이터 흐름을 구성합니다.
<img width="818" height="448" alt="image" src="https://github.com/user-attachments/assets/b683719b-2f92-40ca-91ab-d0d3b0c2b3d1" />


### Coordinator 계층 구조
<img width="818" height="448" alt="image" src="https://github.com/user-attachments/assets/8c27d7c5-1c78-4a1a-b04b-43cc9077ed44" />


### SPM 모듈 구조
모듈은 Feature, Core, Base 세 레이어로 분리됩니다. Base는 모든 모듈이 공통으로 의존하는 기반 레이어이며 Core는 일부 Feature 간에 공유되는 모듈입니다. 의존성은 Feature → Core → Base 방향으로만 흐릅니다.
<img width="818" height="653" alt="image" src="https://github.com/user-attachments/assets/71eb30d6-9b82-40e6-ac9b-188b6c89d515" />

## 🌿 브랜치 전략
> Git Flow 기반의 브랜치 전략을 사용합니다.

```
main
├── develop
│   ├── feat/기능명
│   ├── fix/버그명
│   └── refactor/내용
```

| 브랜치 | 설명 |
|:---:|:---|
| **main** | 배포 브랜치 |
| **develop** | 개발 기본 브랜치, PR의 기본 타겟 |
| **feat/** | 새로운 기능 개발 |
| **fix/** | 버그 수정 |
| **refactor/** | 리팩토링 |

---

## 📝 Commit

```
prefix: <Description>
ex. feat: 로그인
```

| prefix | 설명 |
|:-----------:|:--------------------------------------------------------------:|
| **feat** | 새로운 기능 구현 |
| **fix** | 버그, 오류 해결 |
| **docs** | README나 WIKI 등의 문서 개정 |
| **style** | 코드 의미에 영향을 주지 않는 변경사항 (컨벤션 적용, 줄 바꿈, 공백 제거 등) |
| **refactor** | 코드 수정 (기능 변경, 로직 변경, 보완) |
| **add** | `feat` 이외의 부수적인 코드 추가 (새로운 View, Activity 생성 등) |
| **remove** | 쓸모없는 코드 및 파일 삭제 |
| **config** | 설정, 프로젝트 구성 관련 |
| **test** | 테스트 코드 관련 |

---

## 🏷️ Labels

| 레이블 | 내용 | 헥사컬러 |
|:------------:|:------------:|:---------:|
| ✨Feat | 기능 구현 | `#F1C40F` |
| 🛠️Fix | 수정 | `#A6E75A` |
| ♻️Refactoring | 리팩토링 | `#83F659` |
| 🐛Hotfix | 핫픽스 | `#DD633A` |
| ⚙️Config | 세팅 | `#BDC3C7` |
| 🧪Test | 테스트 | `#3498DB` |
