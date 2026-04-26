# QRIZ - SQLD 자격증 모의고사 앱
<img width="1600" height="545" alt="Group 1597880808" src="https://github.com/user-attachments/assets/cf88475b-eb9a-404c-ae21-d6114c4d882a"/>
<br>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.0-F05138?style=flat&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/iOS-17.0+-000000?style=flat&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Xcode-16-147EFB?style=flat&logo=xcode&logoColor=white" />
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
