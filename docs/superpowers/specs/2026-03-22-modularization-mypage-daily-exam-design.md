# MyPage / Daily / Exam 모듈화 설계

**날짜:** 2026-03-22
**브랜치:** feat/onboarding-module → 다음 작업
**대상:** QRIZ/Feature/{MyPage, Daily, Exam} → 각각 Swift Package 분리

---

## 목표

MyPage, Daily, Exam 피처를 독립적인 Swift Package로 분리한다.
Splash와 TabBar는 앱 진입점 및 최상위 라우터 역할이라 App 타겟에 잔류한다.
Home은 Daily/Exam 분리 후 의존 관계를 보고 별도 작업으로 처리한다.

---

## 분리 순서

```
Phase 1: MyPage  (독립적, 의존성 단순)
Phase 2: Daily   (ExamKit 의존, Conceptbook/MistakeNote 연동)
Phase 3: Exam    (Daily와 동일한 의존성 구조)
```

---

## 프로토콜 분리 전략 (공통)

Onboarding 패키지와 동일한 패턴을 적용한다.

- **public 프로토콜**: 외부(TabBarCoordinator, HomeCoordinator)가 coordinator를 생성·참조할 때 사용. start() + delegate만 노출.
- **internal 프로토콜**: 패키지 내부 ViewController가 coordinator를 통해 화면 전환을 요청할 때 사용. 모든 show/navigate 메서드 포함.

```swift
// public — 외부 노출
public protocol XxxCoordinator: Coordinator {
    var delegate: XxxCoordinatorDelegate? { get set }
}

// internal — 패키지 내부 전용
protocol XxxNavigating: AnyObject {
    func showSomething()
    // ...
}

// Impl이 둘 다 채택
final class XxxCoordinatorImpl: XxxCoordinator, XxxNavigating, NavigationGuard { }
```

---

## Phase 1 — MyPage 패키지

### 패키지 구조

```
MyPage/
├── Package.swift
└── Sources/
    └── MyPage/
        ├── Coordinator/
        │   └── MyPageCoordinator.swift        ← public
        ├── MyPage/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── Settings/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── ChangePassword/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        └── DeleteAccount/
            ├── ViewController/
            ├── ViewModel/
            └── View/
```

> 파일 이동 시 현재 공통 폴더 구조(ViewController/, ViewModel/, View/)를 서브피처별 폴더 구조로 재편성한다.

### 의존성

```swift
.target(
    name: "MyPage",
    dependencies: ["Network", "DesignSystem", "QRIZUtils", "Auth", "Account"]
)
```

### Public API

```swift
// 외부 노출
@MainActor
public protocol MyPageCoordinator: Coordinator {
    var delegate: MyPageCoordinatorDelegate? { get set }
}

@MainActor
public protocol MyPageCoordinatorDelegate: AnyObject {
    func myPageCoordinatorDidLogout(_ coordinator: MyPageCoordinator)
}

public func makeMyPageCoordinator(
    examService: ExamScheduleService,
    myPageService: MyPageService,
    accountRecoveryService: AccountRecoveryService,
    socialLoginService: SocialLoginService
) -> any MyPageCoordinator

// 패키지 내부 전용
protocol MyPageNavigating: AnyObject {
    func showSettingsView()
    func showFindPassword()
    func showResetAlert(confirm: @escaping () -> Void)
    func showExamSelectionSheet()
    func showTermsDetail(for term: TermItem)
    func showLogoutAlert(confirm: @escaping () -> Void)
    func showDeleteAccount()
    func showConfirmDeleteAlert(confirm: @escaping () -> Void)
}
```

### ExamSelectionDelegate 처리

`MyPageCoordinatorImpl`이 `showExamSelectionSheet()`에서 `ExamScheduleSelectionViewController/ViewModel`을 직접 생성한다. 이 타입들은 현재 Home 피처에 있고, `ExamSelectionDelegate`는 `HomeCoordinator.swift` 내부에 선언되어 있다.

Home이 아직 App 타겟에 잔류하므로 MyPage 패키지에서 참조하면 순환 의존성이 된다.

**해결 방향**: `ExamSelectionDelegate`, `ExamScheduleSelectionViewController`, `ExamScheduleSelectionViewModel`을 `QRIZUtils`로 이동한다. 두 곳(Home, MyPage)에서 모두 사용하는 공유 타입이므로 공통 유틸 패키지에 두는 것이 적합하다.

---

## Phase 2 — Daily 패키지

### 패키지 구조

```
Daily/
├── Package.swift
└── Sources/
    └── Daily/
        ├── Coordinator/
        │   └── DailyCoordinator.swift         ← public
        ├── DailyLearn/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── DailyTest/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        └── DailyResult/
            ├── HostingController/
            ├── ViewController/
            ├── ViewModel/
            └── View/
```

### 의존성

```swift
.target(
    name: "Daily",
    dependencies: ["Network", "QRIZUtils", "ExamKit", "DesignSystem", "Conceptbook", "MistakeNote"]
)
```

> Conceptbook, MistakeNote는 결과 화면에서 개념서/오답노트로 이동하는 네비게이션에 사용된다.

### Public API

```swift
// 외부 노출
@MainActor
public protocol DailyCoordinator: Coordinator {
    var delegate: DailyCoordinatorDelegate? { get set }
}

@MainActor
public protocol DailyCoordinatorDelegate: AnyObject {
    func didQuitDaily(_ coordinator: any DailyCoordinator)
    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator)
}

public func makeDailyCoordinator(
    navigationController: UINavigationController,
    dailyService: DailyService,
    day: Int,
    type: DailyLearnType
) -> any DailyCoordinator

// 패키지 내부 전용
protocol DailyNavigating: AnyObject {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()
}
```

---

## Phase 3 — Exam 패키지

### 패키지 구조

```
Exam/
├── Package.swift
└── Sources/
    └── Exam/
        ├── Coordinator/
        │   └── ExamCoordinator.swift          ← public
        ├── ExamList/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── ExamSummary/
        │   ├── ViewController/
        │   └── ViewModel/
        ├── ExamTest/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        └── ExamResult/
            ├── HostingController/
            ├── ViewController/
            ├── ViewModel/
            └── View/
```

### 의존성

```swift
.target(
    name: "Exam",
    dependencies: ["Network", "QRIZUtils", "ExamKit", "DesignSystem", "Conceptbook", "MistakeNote"]
)
```

### Public API

```swift
// 외부 노출
@MainActor
public protocol ExamCoordinator: Coordinator {
    var delegate: ExamCoordinatorDelegate? { get set }
}

@MainActor
public protocol ExamCoordinatorDelegate: AnyObject {
    func didQuitExam(_ coordinator: any ExamCoordinator)
    func moveFromExamToConcept(_ coordinator: any ExamCoordinator)
}

public func makeExamCoordinator(
    navigationController: UINavigationController,
    examService: ExamService
) -> any ExamCoordinator

// 패키지 내부 전용
protocol ExamNavigating: AnyObject {
    func showExamList()
    func showExamSummary(examId: Int)
    func showExamTest(examId: Int)
    func showExamResult(examId: Int)
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func quitExam()
}
```

---

## Daily / Exam 공유 컴포넌트 분석

코드 확인 결과, Daily와 Exam이 직접 공유하는 파일은 없다.
공유 로직은 이미 하위 패키지에 추출되어 있다.

| 공유 요소 | 현재 위치 |
|---|---|
| `TestContentsView` (풀이 화면 콘텐츠) | ExamKit |
| `ResultScoresData`, `ResultGradeListData` (결과 데이터 모델) | QRIZUtils |
| `TestButton`, `TestPageIndicatorLabel` (UI 컴포넌트) | ExamKit |

→ Daily와 Exam은 별도 패키지로 분리해도 중복 없이 깔끔하게 분리된다.

---

## App 타겟 잔류 항목

| 항목 | 이유 |
|---|---|
| Splash | 앱 진입점, 로고 표시 후 라우팅만 담당. 분리 이점 없음 |
| TabBar | 최상위 탭 컨테이너, 앱 레벨 관심사 |
| Home | Daily/Exam 분리 후 의존 관계 파악해서 별도 결정 |

---

## 전체 의존성 그래프 (분리 완료 후)

```
App Target (QRIZ)
├── Splash
├── TabBar
├── Home (잠정 잔류)
├── MyPage ──── Network, QRIZUtils, DesignSystem, Auth, Account
├── Daily ───── Network, QRIZUtils, ExamKit, DesignSystem, Conceptbook, MistakeNote
└── Exam ─────── Network, QRIZUtils, ExamKit, DesignSystem, Conceptbook, MistakeNote
```

---

## 각 Phase 작업 순서 (공통)

1. 패키지 스캐폴딩 (Package.swift 작성)
2. 파일 이동 (App 타겟 → 패키지 Sources, 서브피처별 폴더로 재편성)
3. public/internal 프로토콜 분리 및 팩토리 함수 작성
4. App 타겟에서 import 및 기존 파일 제거
5. TabBarCoordinator / HomeCoordinator에서 패키지 연결
6. 빌드 확인

> MyPage Phase에서는 `ExamSelectionDelegate`, `ExamScheduleSelectionViewController/ViewModel`을 QRIZUtils로 선이동한 뒤 패키지 분리를 진행한다.
