# SQLD 자격증 모의고사 프로젝트


# 📚 코딩 컨벤션 정의

## 📁 Foldering
```bash
📁 Networking
|--- 📁 APIs (API 요청 관련 파일)
|--- 📁 DTOs (Response 모델)
|--- 📁 Network (Network 객체)
|--- 📁 NetworkManager.swift (Network 요청/응답 관리)

📁 QRIZ
|--- 📁 App (AppDelegate, SceneDelegate)
|--- 📁 Feature (ViewController, ViewModel)
|--- 📁 Coordinator (화면 전환 및 네비게이션 관리)
|--- 📁 Utils
|    |--- 📁 Extensions (공통 확장 파일)
|    |--- 📁 Helper (유틸리티/헬퍼 클래스)
|    |--- 📁 Model (공통 데이터 모델)
|    |--- 📁 Types (상수, 열거형, 타입 정의)
|
|--- 📁 Resources (Assets, Color, Fonts)
|--- 📁 SupportingFiles (Info.plist)
```
---

## 📝 Commit

```bash
prefix: <Description>

ex. feat: 로그인 
```

| prefix      | 설명                                                            |
|:-----------:|:--------------------------------------------------------------:|
| **feat**    | 새로운 기능 구현                                               |
| **fix**     | 버그, 오류 해결                                               |
| **docs**    | README나 WIKI 등의 문서 개정                                    |
| **style**   | 코드 의미에 영향을 주지 않는 변경사항 (컨벤션 적용, 줄 바꿈, 공백 제거 등) |
| **refactor**| 코드 수정 (기능 변경, 로직 변경, 보완)                          |
| **add**     | `feat` 이외의 부수적인 코드 추가 (새로운 View, Activity 생성 등)  |
| **remove**  | 쓸모없는 코드 및 파일 삭제                                      |
| **config**  | 설정, 프로젝트 구성 관련                                        |
| **test**    | 테스트 코드 관련                                               |

---

## 🏷️ Labels

|   레이블      |      내용    | 헥사컬러    |
|:------------:|:------------:|:---------:|
| ✨Feat        | 기능 구현      | `#F1C40F` |
| 🛠️Fix        | 수정         | `#A6E75A` |
| ♻️Refactoring | 리팩토링      | `#83F659` |
| 🐛Hotfix      | 핫픽스        | `#DD633A` |
| ⚙️Config      | 세팅         | `#BDC3C7` |
| 🧪Test        | 테스트       | `#3498DB` |
