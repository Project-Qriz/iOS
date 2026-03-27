# MyPage Modularization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `QRIZ/Feature/MyPage`를 독립적인 Swift Package(`MyPage`)로 분리한다.

**Architecture:** Onboarding 패키지와 동일한 패턴 — public 프로토콜(외부 노출) + internal Navigating 프로토콜(패키지 내부) + 팩토리 함수. `ExamSelectionSheet` 의존성은 delegate callback으로 해결해 `examService`를 MyPage 패키지에서 제거한다.

**Tech Stack:** Swift Package Manager, UIKit, Combine, 의존성: Network · DesignSystem · QRIZUtils · Auth · Account

---

## 핵심 제약 및 설계 결정

### ExamSelectionSheet 의존성 — spec 대비 변경 사항

설계 문서(`specs/2026-03-22-modularization-mypage-daily-exam-design.md`)는 `ExamSelectionDelegate`, `ExamScheduleSelectionViewController/ViewModel`을 `QRIZUtils`로 이동하도록 제안했다.

**이 방법은 불가능하다:**
- `Network` → `QRIZUtils` 의존
- `DesignSystem` → `QRIZUtils` 의존
- `ExamScheduleSelectionViewModel`은 `Network`(`ExamScheduleService`), `ExamScheduleSelectionMainView`는 `DesignSystem`을 사용
- → `QRIZUtils`가 `Network`/`DesignSystem`에 의존하면 **순환 의존성** 발생

**채택한 해결책: delegate callback 패턴**
- `MyPageCoordinatorImpl.showExamSelectionSheet()` → `delegate?.myPageCoordinatorDidRequestExamScheduleSelection(self)` 호출
- `TabBarCoordinatorImpl`이 delegate 구현 — `ExamScheduleSelectionViewModel`+VC를 생성하고 현재 탭의 `UINavigationController`에서 present
- `ExamScheduleSelectionViewController/ViewModel`은 **Home 폴더(App 타겟)에 그대로 유지** — 이동 불필요
- `MyPage` 패키지에서 `examService` 불필요 → factory 파라미터에서 제거

### 기타 제약
- `TabBarCoordinatorImpl`의 `myPageCoordinator as? MyPageCoordinatorImpl` concrete cast는 패키지 이동 전에 제거해야 함
- `TwoButtonCustomAlertViewController`는 `DesignSystem`에 있음 — MyPage 패키지에서 정상 참조 가능

---

## Task 1: ExamSelectionSheet 의존성 정리 (App 타겟)

**Files:**
- Modify: `QRIZ/Feature/MyPage/MyPageCoordinator.swift`
- Modify: `QRIZ/Feature/TabBar/TabBarCoordinator.swift`

- [ ] **Step 1: `MyPageCoordinatorDelegate`에 메서드 추가**

`QRIZ/Feature/MyPage/MyPageCoordinator.swift`의 delegate 프로토콜을 수정한다:

```swift
@MainActor
protocol MyPageCoordinatorDelegate: AnyObject {
    func myPageCoordinatorDidLogout(_ coordinator: MyPageCoordinator)
    func myPageCoordinatorDidRequestExamScheduleSelection(_ coordinator: MyPageCoordinator)
}
```

- [ ] **Step 2: `MyPageCoordinatorImpl`에서 `examService`·`examDelegate` 제거**

```swift
// 삭제
weak var examDelegate: ExamSelectionDelegate?
private let examService: ExamScheduleService

// init 파라미터에서도 제거
init(
    myPageService: MyPageService,
    accountRecoveryService: AccountRecoveryService,
    socialLoginService: SocialLoginService
) {
    self.myPageService = myPageService
    self.accountRecoveryService = accountRecoveryService
    self.socialLoginService = socialLoginService
}
```

- [ ] **Step 3: `showExamSelectionSheet()`를 delegate 호출로 교체**

```swift
func showExamSelectionSheet() {
    delegate?.myPageCoordinatorDidRequestExamScheduleSelection(self)
}
```

> `guardNavigation` 래퍼 제거 — 표시 로직이 TabBar로 이동하므로 guard는 TabBar 쪽에서 처리한다.

- [ ] **Step 4: `TabBarCoordinatorDependency`에 `examScheduleService` 추가**

`QRIZ/Feature/TabBar/TabBarCoordinator.swift`:

```swift
@MainActor
protocol TabBarCoordinatorDependency {
    var homeCoordinator: HomeCoordinator { get }
    var conceptBookCoordinator: ConceptBookCoordinator { get }
    var mistakeNoteCoordinator: MistakeNoteCoordinatorImpl { get }  // 기존 유지
    var myPageCoordinator: MyPageCoordinator { get }
    var examScheduleService: ExamScheduleService { get }  // 추가
}
```

- [ ] **Step 5: `TabBarCoordinatorDependencyImpl`에 `examScheduleService` 노출**

```swift
final class TabBarCoordinatorDependencyImpl: TabBarCoordinatorDependency {
    // 기존 private let examService: ExamScheduleService 유지

    var examScheduleService: ExamScheduleService { examService }  // 추가

    // _myPageCoordinator의 init에서 examService 파라미터 제거
    private lazy var _myPageCoordinator = MyPageCoordinatorImpl(
        myPageService: myPageService,
        accountRecoveryService: accountRecoveryService,
        socialLoginService: socialLoginService
    )
}
```

- [ ] **Step 6: `TabBarCoordinatorImpl`에서 concrete cast 제거 및 delegate 구현**

`TabBarCoordinatorImpl` 상단 프로퍼티:
```swift
// 변경 전
private let myPageCoordinator: MyPageCoordinatorImpl

// 변경 후 (concrete cast 제거, 프로토콜 타입으로)
// → 별도 저장 대신 start()에서 dependency.myPageCoordinator 직접 사용
```

`init` 수정 — `myPageCoordinator` 항목 제거:
```swift
init(dependency: TabBarCoordinatorDependency) {
    self.dependency = dependency
    guard
        let home = dependency.homeCoordinator as? HomeCoordinatorImpl,
        let mistakeNote = dependency.mistakeNoteCoordinator as? MistakeNoteCoordinatorImpl
    else {
        fatalError("TabBar 의존성 주입 오류: 예상한 Coordinator 타입이 아닙니다‼️")
    }
    self.homeCoordinator = home
    self.mistakeNoteCoordinator = mistakeNote
}
```

`start()` 수정 — `myPageCoordinator` 참조를 `dependency.myPageCoordinator`로 교체하고 `examDelegate` 라인 제거:
```swift
func start() -> UIViewController {
    homeCoordinator.examDelegate = self
    homeCoordinator.delegate = self
    mistakeNoteCoordinator.delegate = self
    // myPageCoordinator.examDelegate = self  ← 삭제
    dependency.myPageCoordinator.delegate = self

    var viewControllers: [UIViewController] = [
        homeCoordinator.start(),
        dependency.conceptBookCoordinator.start(),
        dependency.mistakeNoteCoordinator.start(),
        dependency.myPageCoordinator.start()
    ]
    setupTabBarItems(for: &viewControllers)

    let tabBar = UITabBarController()
    configureTabBarController(tabBar)
    tabBar.viewControllers = viewControllers
    self.tabBarController = tabBar

    childCoordinators = [
        homeCoordinator,
        dependency.conceptBookCoordinator,
        dependency.mistakeNoteCoordinator,
        dependency.myPageCoordinator
    ]
    return tabBar
}
```

`TabBarCoordinatorImpl` 클래스 선언에서 `private let myPageCoordinator: MyPageCoordinatorImpl` 삭제.

`MyPageCoordinatorDelegate` extension에 새 메서드 추가:
```swift
extension TabBarCoordinatorImpl: MyPageCoordinatorDelegate {
    func myPageCoordinatorDidLogout(_ coordinator: MyPageCoordinator) {
        logout()
    }

    func myPageCoordinatorDidRequestExamScheduleSelection(_ coordinator: MyPageCoordinator) {
        let viewModel = ExamScheduleSelectionViewModel(examScheduleService: dependency.examScheduleService)
        viewModel.delegate = self  // ExamSelectionDelegate

        let vc = ExamScheduleSelectionViewController(examScheduleSelectionVM: viewModel)
        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            let fit = UISheetPresentationController.Detent.custom(identifier: .init("fit")) { context in
                min(540, context.maximumDetentValue)
            }
            sheet.detents = [fit]
            sheet.selectedDetentIdentifier = .init("fit")
        }

        let presentingNC = tabBarController?.selectedViewController as? UINavigationController
        presentingNC?.present(vc, animated: true)
    }
}
```

- [ ] **Step 7: 빌드 확인**

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 8: 커밋**

```bash
git add QRIZ/Feature/MyPage/MyPageCoordinator.swift QRIZ/Feature/TabBar/TabBarCoordinator.swift
git commit -m "refactor: ExamSelectionSheet를 delegate 패턴으로 전환, concrete cast 제거"
```

---

## Task 2: MyPage 패키지 스캐폴딩

**Files:**
- Create: `MyPage/Package.swift`
- Create: `MyPage/Sources/MyPage/` 하위 디렉토리 구조

- [ ] **Step 1: 디렉토리 구조 생성**

```bash
mkdir -p MyPage/Sources/MyPage/Coordinator
mkdir -p MyPage/Sources/MyPage/MyPage/ViewController
mkdir -p MyPage/Sources/MyPage/MyPage/ViewModel
mkdir -p MyPage/Sources/MyPage/MyPage/View/Components
mkdir -p MyPage/Sources/MyPage/Settings/ViewController
mkdir -p MyPage/Sources/MyPage/Settings/ViewModel
mkdir -p MyPage/Sources/MyPage/Settings/View/Components
mkdir -p MyPage/Sources/MyPage/DeleteAccount/ViewController
mkdir -p MyPage/Sources/MyPage/DeleteAccount/ViewModel
mkdir -p MyPage/Sources/MyPage/DeleteAccount/View
mkdir -p MyPage/Tests/MyPageTests
```

- [ ] **Step 2: `Package.swift` 작성**

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyPage",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MyPage", targets: ["MyPage"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../Auth"),
        .package(path: "../Account"),
    ],
    targets: [
        .target(
            name: "MyPage",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "Auth",
                "Account",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
```

- [ ] **Step 3: Package 인식 확인 (SPM resolve)**

```bash
cd MyPage && swift package resolve && cd ..
```

Expected: 정상 종료 (exit 0)

---

## Task 3: 파일 이동 및 public/internal 분리

**Files:**
- Move: `QRIZ/Feature/MyPage/**/*.swift` → `MyPage/Sources/MyPage/`
- Create: `MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift` (재작성)

### 3-A: Coordinator 파일 재작성

- [ ] **Step 1: `MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift` 작성**

```swift
import UIKit
import QRIZUtils
import Network
import Auth
import Account

// MARK: - Public (외부 노출)

@MainActor
public protocol MyPageCoordinator: Coordinator {
    var delegate: MyPageCoordinatorDelegate? { get set }
}

@MainActor
public protocol MyPageCoordinatorDelegate: AnyObject {
    func myPageCoordinatorDidLogout(_ coordinator: MyPageCoordinator)
    func myPageCoordinatorDidRequestExamScheduleSelection(_ coordinator: MyPageCoordinator)
}

@MainActor
public func makeMyPageCoordinator(
    myPageService: MyPageService,
    accountRecoveryService: AccountRecoveryService,
    socialLoginService: SocialLoginService
) -> any MyPageCoordinator {
    MyPageCoordinatorImpl(
        myPageService: myPageService,
        accountRecoveryService: accountRecoveryService,
        socialLoginService: socialLoginService
    )
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
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

- [ ] **Step 2: `MyPageCoordinatorImpl`을 별도 파일로 분리**

`MyPage/Sources/MyPage/Coordinator/MyPageCoordinatorImpl.swift`:

Task 1 수정 후의 `MyPageCoordinatorImpl` 구현부를 그대로 복사한다. 이 파일은 `internal` (access modifier 없음).

```swift
import UIKit
import DesignSystem
import QRIZUtils
import Network
import Auth
import Account

@MainActor
final class MyPageCoordinatorImpl: MyPageCoordinator, MyPageNavigating, NavigationGuard {

    private weak var navigationController: UINavigationController?
    weak var delegate: MyPageCoordinatorDelegate?
    private let myPageService: MyPageService
    private let accountRecoveryService: AccountRecoveryService
    private let socialLoginService: SocialLoginService
    var childCoordinators: [Coordinator] = []
    var isNavigating: Bool = false

    init(
        myPageService: MyPageService,
        accountRecoveryService: AccountRecoveryService,
        socialLoginService: SocialLoginService
    ) {
        self.myPageService = myPageService
        self.accountRecoveryService = accountRecoveryService
        self.socialLoginService = socialLoginService
    }

    func start() -> UIViewController { /* 기존 구현 그대로 */ }

    // showExamSelectionSheet()는 delegate에게 위임
    func showExamSelectionSheet() {
        delegate?.myPageCoordinatorDidRequestExamScheduleSelection(self)
    }

    // 나머지 showSettingsView(), showFindPassword() 등 기존 구현 그대로
    // (examService, examDelegate 관련 코드는 Task 1에서 이미 제거됨)
}

// MARK: - TermsDetailDismissible
extension MyPageCoordinatorImpl: TermsDetailDismissible { /* 기존 그대로 */ }

// MARK: - AccountRecoveryCoordinatorDelegate
extension MyPageCoordinatorImpl: AccountRecoveryCoordinatorDelegate { /* 기존 그대로 */ }
```

> `ExamScheduleSelectionViewController/ViewModel`은 Home 폴더(App 타겟)에 그대로 남는다. MyPage 패키지에서 이 타입들을 참조하지 않으므로 순환 의존성 없음.

### 3-B: 나머지 파일 이동

- [ ] **Step 3: MyPage 서브피처 파일 이동**

아래 대응표대로 `cp` 후 기존 파일은 나중에 삭제(Task 4):

| 기존 경로 | 새 경로 |
|---|---|
| `QRIZ/Feature/MyPage/ViewModel/MyPageViewModel.swift` | `MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift` |
| `QRIZ/Feature/MyPage/ViewController/MyPageViewController.swift` | `MyPage/Sources/MyPage/MyPage/ViewController/MyPageViewController.swift` |
| `QRIZ/Feature/MyPage/View/MyPageMainView.swift` | `MyPage/Sources/MyPage/MyPage/View/MyPageMainView.swift` |
| `QRIZ/Feature/MyPage/View/Components/MyPage/MyPageSection.swift` | `MyPage/Sources/MyPage/MyPage/View/Components/MyPageSection.swift` |
| `QRIZ/Feature/MyPage/View/Components/MyPage/ProfileCell.swift` | `MyPage/Sources/MyPage/MyPage/View/Components/ProfileCell.swift` |
| `QRIZ/Feature/MyPage/View/Components/MyPage/QuickActionsCell.swift` | `MyPage/Sources/MyPage/MyPage/View/Components/QuickActionsCell.swift` |
| `QRIZ/Feature/MyPage/View/Components/MyPage/SupportMenuCell.swift` | `MyPage/Sources/MyPage/MyPage/View/Components/SupportMenuCell.swift` |
| `QRIZ/Feature/MyPage/ViewModel/SettingsViewModel.swift` | `MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift` |
| `QRIZ/Feature/MyPage/ViewController/SettingsViewController.swift` | `MyPage/Sources/MyPage/Settings/ViewController/SettingsViewController.swift` |
| `QRIZ/Feature/MyPage/View/SettingsMainView.swift` | `MyPage/Sources/MyPage/Settings/View/SettingsMainView.swift` |
| `QRIZ/Feature/MyPage/View/Components/Settings/ChangePasswordInputView.swift` | `MyPage/Sources/MyPage/Settings/View/Components/ChangePasswordInputView.swift` |
| `QRIZ/Feature/MyPage/View/Components/Settings/ProfileHeaderView.swift` | `MyPage/Sources/MyPage/Settings/View/Components/ProfileHeaderView.swift` |
| `QRIZ/Feature/MyPage/View/Components/Settings/SettingsOptionView.swift` | `MyPage/Sources/MyPage/Settings/View/Components/SettingsOptionView.swift` |
| `QRIZ/Feature/MyPage/ViewController/ChangePasswordViewController.swift` | `MyPage/Sources/MyPage/Settings/ViewController/ChangePasswordViewController.swift` |
| `QRIZ/Feature/MyPage/ViewModel/ChangePasswordViewModel.swift` | `MyPage/Sources/MyPage/Settings/ViewModel/ChangePasswordViewModel.swift` |
| `QRIZ/Feature/MyPage/View/ChangePasswordMainView.swift` | `MyPage/Sources/MyPage/Settings/View/ChangePasswordMainView.swift` |
| `QRIZ/Feature/MyPage/ViewController/DeleteAccountViewController.swift` | `MyPage/Sources/MyPage/DeleteAccount/ViewController/DeleteAccountViewController.swift` |
| `QRIZ/Feature/MyPage/ViewModel/DeleteAccountViewModel.swift` | `MyPage/Sources/MyPage/DeleteAccount/ViewModel/DeleteAccountViewModel.swift` |
| `QRIZ/Feature/MyPage/View/DeleteAccountMainView.swift` | `MyPage/Sources/MyPage/DeleteAccount/View/DeleteAccountMainView.swift` |

- [ ] **Step 4: 이동한 각 파일에 `public` 접근 제어자 추가**

ViewController, ViewModel, View 타입 모두 외부(App 타겟)에서 직접 접근하지 않으므로 `internal`(기본값)로 두어도 된다. 패키지 외부에 노출할 타입은 없다.

확인 사항:
- 각 파일의 `import` 구문이 패키지 내 의존성(`Network`, `DesignSystem`, `QRIZUtils`, `Auth`, `Account`)만 사용하는지 검토
- `TwoButtonCustomAlertViewController`처럼 DesignSystem에 있으면 정상. App 타겟 전용 타입이면 이동 또는 대체 필요

- [ ] **Step 5: `swift package build` 확인**

```bash
cd MyPage && swift build 2>&1 | tail -20
```

빌드 에러 발생 시: import 경로 오류, `public` 누락, App 타겟 전용 타입 참조 등을 수정하고 다시 실행.

---

## Task 4: Xcode 연결 및 App 타겟 정리

**Files:**
- Modify: `QRIZ.xcodeproj` (Xcode GUI)
- Modify: `QRIZ/Feature/TabBar/TabBarCoordinator.swift`
- Delete: `QRIZ/Feature/MyPage/` 디렉토리 전체

- [ ] **Step 1: Xcode에서 MyPage 패키지 추가**

1. `QRIZ.xcodeproj` 열기
2. Project Navigator → QRIZ 프로젝트 선택 → Package Dependencies 탭
3. `+` → "Add Local..." → `MyPage/` 폴더 선택
4. QRIZ App target → Build Phases → Link Binary With Libraries → `MyPage` 추가

- [ ] **Step 2: `TabBarCoordinator.swift` 업데이트**

```swift
import MyPage  // 추가
```

`TabBarCoordinatorDependency`의 `myPageCoordinator` 타입이 이미 `MyPageCoordinator` 프로토콜을 쓰고 있으므로, `import MyPage` 추가 후 기존 코드가 그대로 작동해야 함.

`makeMyPageCoordinator` 팩토리 함수 사용으로 변경 (선택):
```swift
// TabBarCoordinatorDependencyImpl 안에서
private lazy var _myPageCoordinator = makeMyPageCoordinator(
    myPageService: myPageService,
    accountRecoveryService: accountRecoveryService,
    socialLoginService: socialLoginService
)
```

- [ ] **Step 3: App 타겟에서 MyPage 파일 제거**

Xcode Project Navigator에서 `QRIZ/Feature/MyPage/` 그룹 선택 → Delete → "Move to Trash"

(파일시스템에서도 삭제됨)

- [ ] **Step 4: 빌드 확인**

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

---

## Task 5: 커밋

- [ ] **Step 1: 변경 사항 확인**

```bash
git status
git diff --stat
```

- [ ] **Step 2: 커밋**

```bash
git add MyPage/ QRIZ/Feature/TabBar/TabBarCoordinator.swift QRIZ.xcodeproj
# QRIZ/Feature/MyPage/ 는 이미 삭제됨
git commit -m "feat: MyPage를 독립 Swift Package로 분리"
```

---

## 주요 체크리스트

- [ ] `ExamSelectionSheet`가 MyPage 탭에서 정상 표시되는지 시뮬레이터로 확인
- [ ] 시험 일정 등록·변경 후 Home 탭의 시험 정보가 갱신되는지 확인 (`didUpdateExamSchedule` 흐름)
- [ ] 로그아웃 후 Login 화면으로 이동하는지 확인
- [ ] 비밀번호 찾기(AccountRecovery) 플로우가 정상 동작하는지 확인
- [ ] 회원탈퇴 플로우가 정상 동작하는지 확인
