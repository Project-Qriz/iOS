# Onboarding 모듈화 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** QRIZ/Feature/Onboarding 피처를 독립적인 Onboarding Swift Package로 분리하고 팩토리 패턴으로 메인 앱과 연결한다.

**Architecture:** 기존 파일을 새 패키지로 이동하고 Coordinator 프로토콜을 public(OnboardingCoordinator)과 internal(OnboardingNavigating)로 분리한다. 메인 앱은 `OnboardingCoordinator.make(...)` 팩토리를 통해 Coordinator를 생성하며 `OnboardingCoordinatorImpl`을 직접 참조하지 않는다.

**Tech Stack:** Swift 6.0, Swift Package Manager, UIKit, Combine

---

## Chunk 1: 패키지 스캐폴딩

### Task 1: Package.swift 및 디렉토리 생성

**Files:**
- Create: `Onboarding/Package.swift`
- Create: `Onboarding/Sources/Onboarding/Coordinator/` (디렉토리)

- [ ] **Step 1: Package.swift 생성**

`/Users/hun/iOS/Onboarding/Package.swift` 생성:

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Onboarding", targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../ExamKit"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
            ]
        ),
    ]
)
```

- [ ] **Step 2: 디렉토리 구조 생성**

```bash
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/Coordinator
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginOnboarding/ViewController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginOnboarding/ViewModel
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/ViewController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/ViewModel
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/View
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginPreviewTest/ViewController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginPreviewTest/ViewModel
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewTest/ViewController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewTest/ViewModel
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/HostingController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/ViewController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/ViewModel
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/View
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/Greeting/ViewController
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/Greeting/ViewModel
mkdir -p /Users/hun/iOS/Onboarding/Sources/Onboarding/OnboardingComponents
```

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/
git commit -m "feat: Onboarding 패키지 스캐폴딩"
```

---

## Chunk 2: Coordinator 작성 (Public API)

### Task 2: OnboardingCoordinator.swift 작성

기존 `QRIZ/Feature/Onboarding/OnboardingCoordinator.swift`를 대체하는 새 파일을 패키지에 작성한다.
기존 단일 프로토콜을 **public** `OnboardingCoordinator` + **internal** `OnboardingNavigating`으로 분리한다.

**Files:**
- Create: `Onboarding/Sources/Onboarding/Coordinator/OnboardingCoordinator.swift`

- [ ] **Step 1: OnboardingCoordinator.swift 작성**

```swift
import UIKit
import Combine
import QRIZUtils
import Network

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol OnboardingCoordinator: Coordinator {
    var delegate: OnboardingCoordinatorDelegate? { get set }
}

@MainActor
public protocol OnboardingCoordinatorDelegate: AnyObject {
    func didFinishOnboarding(_ coordinator: any OnboardingCoordinator)
}

public extension OnboardingCoordinator {
    static func make(
        navigationController: UINavigationController,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService
    ) -> any OnboardingCoordinator {
        OnboardingCoordinatorImpl(
            navigationController: navigationController,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
    }
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol OnboardingNavigating: AnyObject {
    // show* 메서드: ViewController가 다음 화면으로 이동할 때 호출
    func showBeginOnboarding()
    func showCheckConcept()
    func showBeginPreviewTest()
    func showPreviewTest()
    func showPreviewResult()
    func showGreeting()
    // delegate: GreetingViewController, PreviewTestViewController가
    // 온보딩 완료 시 coordinator.delegate?.didFinishOnboarding(coordinator) 호출에 필요
    var delegate: OnboardingCoordinatorDelegate? { get }
}
```

### Task 3: OnboardingCoordinatorImpl 작성

기존 `OnboardingCoordinatorImpl`을 패키지로 이동하고 두 프로토콜 모두 채택하도록 수정한다.

**Files:**
- Create: `Onboarding/Sources/Onboarding/Coordinator/OnboardingCoordinatorImpl.swift`
- Delete: `QRIZ/Feature/Onboarding/OnboardingCoordinator.swift` (Task 11에서 처리)

> ⚠️ **빌드 주의:** Chunk 2 커밋 이후 Task 13 완료 전까지는 빌드가 실패한다. `HomeCoordinatorImpl.didFinishOnboarding`의 시그니처가 아직 수정되지 않았기 때문이다. Chunk 4 전체 완료 후 빌드 확인할 것.

- [ ] **Step 1: OnboardingCoordinatorImpl.swift 작성**

기존 `QRIZ/Feature/Onboarding/OnboardingCoordinator.swift`의 `OnboardingCoordinatorImpl` 구현을 복사하되 다음만 수정한다:
- 파일 상단 주석 헤더 제거
- `import UIKit`, `import Combine`, `import QRIZUtils`, `import Network` import 추가 (기존과 동일하게)
- 클래스 선언을 `final class OnboardingCoordinatorImpl: OnboardingCoordinator, OnboardingNavigating, NavigationGuard {`로 변경 (OnboardingNavigating 추가)
- `show*` 메서드 내부 코드는 기존 그대로 유지 (self. 접두사 추가 불필요)

```swift
import UIKit
import Combine
import QRIZUtils
import Network

@MainActor
final class OnboardingCoordinatorImpl: OnboardingCoordinator, OnboardingNavigating, NavigationGuard {

    weak var delegate: OnboardingCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService

    var previewTestStatus: PreviewTestStatus {
        UserInfoManager.shared.previewTestStatus
    }

    var isNavigating: Bool = false

    init(navigationController: UINavigationController, onboardingService: OnboardingService, userInfoService: UserInfoService) {
        self.navigationController = navigationController
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
    }

    func start() -> UIViewController {
        switch previewTestStatus {
        case .notStarted:
            showBeginOnboarding()
        case .surveyCompleted:
            showBeginPreviewTest()
        default:
            break
        }
        return navigationController
    }

    func showBeginOnboarding() {
        guardNavigation {
            let vm = BeginOnboardingViewModel()
            let vc = BeginOnboardingViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showCheckConcept() {
        guardNavigation {
            let vm = CheckConceptViewModel(onboardingService: onboardingService)
            let vc = CheckConceptViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showBeginPreviewTest() {
        guardNavigation {
            let vm = BeginPreviewTestViewModel()
            let vc = BeginPreviewTestViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewTest() {
        guardNavigation {
            let vm = PreviewTestViewModel(onboardingService: onboardingService)
            let vc = PreviewTestViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewResult() {
        guardNavigation {
            let vm = PreviewResultViewModel(onboardingService: onboardingService)
            let vc = PreviewResultViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showGreeting() {
        guardNavigation {
            let vm = GreetingViewModel(userInfoService: userInfoService)
            let vc = GreetingViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
```

- [ ] **Step 2: 커밋**

```bash
git add Onboarding/Sources/Onboarding/Coordinator/
git commit -m "feat: OnboardingCoordinator public API 및 Impl 작성"
```

---

## Chunk 3: 화면 파일 이동

각 화면 파일을 QRIZ 앱에서 패키지로 이동한다. 이동 시 적용 규칙:
- 파일 상단 주석 헤더 제거
- `weak var coordinator: OnboardingCoordinator?` → `weak var coordinator: (any OnboardingNavigating)?`
  - **이유:** `OnboardingCoordinator` (public)는 `delegate`만 갖는다. ViewController가 `showCheckConcept()` 등 내비게이션 메서드를 호출하려면 6개 `show*` 메서드를 가진 `OnboardingNavigating` (internal)이 필요하다.
- 필요한 import 확인 (DesignSystem, QRIZUtils, ExamKit 등)
- 접근 제어자는 기본값(internal) 유지

### Task 4: OnboardingComponents 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/OnboardingComponents/OnboardingButton.swift` → `Onboarding/Sources/Onboarding/OnboardingComponents/OnboardingButton.swift`
- Move: `QRIZ/Feature/Onboarding/OnboardingComponents/OnboardingTitleLabel.swift` → `Onboarding/Sources/Onboarding/OnboardingComponents/OnboardingTitleLabel.swift`
- Move: `QRIZ/Feature/Onboarding/OnboardingComponents/OnboardingSubtitleLabel.swift` → `Onboarding/Sources/Onboarding/OnboardingComponents/OnboardingSubtitleLabel.swift`

- [ ] **Step 1: 3개 컴포넌트 파일 복사 후 헤더 제거**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/OnboardingComponents/OnboardingButton.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/OnboardingComponents/OnboardingButton.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/OnboardingComponents/OnboardingTitleLabel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/OnboardingComponents/OnboardingTitleLabel.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/OnboardingComponents/OnboardingSubtitleLabel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/OnboardingComponents/OnboardingSubtitleLabel.swift
```

각 파일에서 상단 `//\n//  파일명\n// ... Created by` 형태의 주석 헤더 제거.

- [ ] **Step 2: 커밋**

```bash
git add Onboarding/Sources/Onboarding/OnboardingComponents/
git commit -m "feat: OnboardingComponents 파일 이동"
```

### Task 5: BeginOnboarding 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/BeginOnboarding/ViewModel/BeginOnboardingViewModel.swift`
- Move: `QRIZ/Feature/Onboarding/BeginOnboarding/ViewController/BeginOnboardingViewController.swift`

- [ ] **Step 1: ViewModel 복사**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/BeginOnboarding/ViewModel/BeginOnboardingViewModel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginOnboarding/ViewModel/BeginOnboardingViewModel.swift
```

헤더 제거. import 확인 (Combine이면 충분).

- [ ] **Step 2: ViewController 복사 및 coordinator 타입 변경**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/BeginOnboarding/ViewController/BeginOnboardingViewController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginOnboarding/ViewController/BeginOnboardingViewController.swift
```

헤더 제거. 다음 변경 적용:
```swift
// Before
weak var coordinator: OnboardingCoordinator?

// After
weak var coordinator: (any OnboardingNavigating)?
```

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/Sources/Onboarding/BeginOnboarding/
git commit -m "feat: BeginOnboarding 파일 이동"
```

### Task 6: CheckConcept 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/CheckConcept/ViewModel/CheckConceptViewModel.swift`
- Move: `QRIZ/Feature/Onboarding/CheckConcept/ViewController/CheckConceptViewController.swift`
- Move: `QRIZ/Feature/Onboarding/CheckConcept/View/CheckAllOrNoneButton.swift`
- Move: `QRIZ/Feature/Onboarding/CheckConcept/View/CheckListCell.swift`
- Move: `QRIZ/Feature/Onboarding/CheckConcept/View/CheckListFoldButton.swift`

- [ ] **Step 1: 5개 파일 복사**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/CheckConcept/ViewModel/CheckConceptViewModel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/ViewModel/CheckConceptViewModel.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/CheckConcept/ViewController/CheckConceptViewController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/ViewController/CheckConceptViewController.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/CheckConcept/View/CheckAllOrNoneButton.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/View/CheckAllOrNoneButton.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/CheckConcept/View/CheckListCell.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/View/CheckListCell.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/CheckConcept/View/CheckListFoldButton.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/CheckConcept/View/CheckListFoldButton.swift
```

- [ ] **Step 2: CheckConceptViewController coordinator 타입 변경**

`CheckConceptViewController.swift`에서:
```swift
// Before
weak var coordinator: OnboardingCoordinator?

// After
weak var coordinator: (any OnboardingNavigating)?
```

헤더 제거, import 확인 (Network 필요 — CheckConceptViewModel이 OnboardingService 사용).

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/Sources/Onboarding/CheckConcept/
git commit -m "feat: CheckConcept 파일 이동"
```

### Task 7: BeginPreviewTest 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/BeginPreviewTest/ViewModel/BeginPreviewTestViewModel.swift`
- Move: `QRIZ/Feature/Onboarding/BeginPreviewTest/ViewController/BeginPreviewTestViewController.swift`

- [ ] **Step 1: 2개 파일 복사**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/BeginPreviewTest/ViewModel/BeginPreviewTestViewModel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginPreviewTest/ViewModel/BeginPreviewTestViewModel.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/BeginPreviewTest/ViewController/BeginPreviewTestViewController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/BeginPreviewTest/ViewController/BeginPreviewTestViewController.swift
```

- [ ] **Step 2: ViewController coordinator 타입 변경**

```swift
// Before
weak var coordinator: OnboardingCoordinator?

// After
weak var coordinator: (any OnboardingNavigating)?
```

헤더 제거.

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/Sources/Onboarding/BeginPreviewTest/
git commit -m "feat: BeginPreviewTest 파일 이동"
```

### Task 8: PreviewTest 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift`
- Move: `QRIZ/Feature/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift`

- [ ] **Step 1: 2개 파일 복사**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift
```

- [ ] **Step 2: ViewController coordinator 타입 변경 및 import 확인**

`PreviewTestViewController.swift`는 `import ExamKit`을 사용한다. 헤더 제거 후:
```swift
// Before
weak var coordinator: OnboardingCoordinator?

// After
weak var coordinator: (any OnboardingNavigating)?
```

> 이 파일은 `coordinator.delegate?.didFinishOnboarding(coordinator)` 호출을 포함한다. `OnboardingNavigating`에 `delegate` 프로퍼티가 선언되어 있으므로 컴파일 가능하다.

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/Sources/Onboarding/PreviewTest/
git commit -m "feat: PreviewTest 파일 이동"
```

### Task 9: PreviewResult 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/PreviewResult/ViewModel/PreviewResultViewModel.swift`
- Move: `QRIZ/Feature/Onboarding/PreviewResult/ViewController/PreviewResultViewController.swift`
- Move: `QRIZ/Feature/Onboarding/PreviewResult/HostingController/PreviewResultViewHostingController.swift`
- Move: `QRIZ/Feature/Onboarding/PreviewResult/View/` (7개 파일 전체)

- [ ] **Step 1: View 파일 7개 복사**

```bash
for f in PreviewResultBarGraphsView PreviewResultConceptView PreviewResultIncorrectConceptsRankView \
          PreviewResultIncorrectRankView PreviewResultInfoView PreviewResultScoreView PreviewResultView; do
  cp /Users/hun/iOS/QRIZ/Feature/Onboarding/PreviewResult/View/${f}.swift \
     /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/View/${f}.swift
done
```

- [ ] **Step 2: HostingController 복사**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/PreviewResult/HostingController/PreviewResultViewHostingController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/HostingController/PreviewResultViewHostingController.swift
```

- [ ] **Step 3: ViewModel, ViewController 복사 및 coordinator 타입 변경**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/PreviewResult/ViewModel/PreviewResultViewModel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/ViewModel/PreviewResultViewModel.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/PreviewResult/ViewController/PreviewResultViewController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/PreviewResult/ViewController/PreviewResultViewController.swift
```

`PreviewResultViewController.swift`에서:
```swift
// Before
weak var coordinator: OnboardingCoordinator?

// After
weak var coordinator: (any OnboardingNavigating)?
```

`PreviewResultScoreView.swift`는 `import ExamKit` 사용 중 — 유지.

모든 파일 헤더 제거.

- [ ] **Step 4: 커밋**

```bash
git add Onboarding/Sources/Onboarding/PreviewResult/
git commit -m "feat: PreviewResult 파일 이동"
```

### Task 10: Greeting 이동

**Files:**
- Move: `QRIZ/Feature/Onboarding/Greeting/ViewModel/GreetingViewModel.swift`
- Move: `QRIZ/Feature/Onboarding/Greeting/ViewController/GreetingViewController.swift`

- [ ] **Step 1: 2개 파일 복사**

```bash
cp /Users/hun/iOS/QRIZ/Feature/Onboarding/Greeting/ViewModel/GreetingViewModel.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/Greeting/ViewModel/GreetingViewModel.swift

cp /Users/hun/iOS/QRIZ/Feature/Onboarding/Greeting/ViewController/GreetingViewController.swift \
   /Users/hun/iOS/Onboarding/Sources/Onboarding/Greeting/ViewController/GreetingViewController.swift
```

- [ ] **Step 2: ViewController coordinator 타입 변경**

```swift
// Before
weak var coordinator: OnboardingCoordinator?

// After
weak var coordinator: (any OnboardingNavigating)?
```

헤더 제거.

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/Sources/Onboarding/Greeting/
git commit -m "feat: Greeting 파일 이동"
```

> `GreetingViewController`도 `coordinator.delegate?.didFinishOnboarding(coordinator)` 호출을 포함한다. `OnboardingNavigating`에 `delegate` 선언이 있으므로 컴파일 가능하다.

---

## Chunk 4: 메인 앱 연결

### Task 11: QRIZ.xcodeproj에 Onboarding 패키지 추가

- [ ] **Step 1: Xcode에서 패키지 추가**

Xcode → QRIZ 프로젝트 → Package Dependencies 탭 → `+` 버튼 → Add Local → `/Users/hun/iOS/Onboarding` 선택 → QRIZ 타겟에 Onboarding 라이브러리 추가.

- [ ] **Step 2: QRIZ 앱에서 기존 Onboarding 파일 제거**

Xcode에서 `QRIZ/Feature/Onboarding/` 폴더 전체를 타겟에서 제거 (파일은 디스크에 유지하거나 삭제).

> 실제 파일 삭제:
> ```bash
> rm -rf /Users/hun/iOS/QRIZ/Feature/Onboarding/
> ```

### Task 12: AppCoordinator.swift 수정

**Files:**
- Modify: `QRIZ/Coordinator/AppCoordinator.swift`

- [ ] **Step 1: import Onboarding 추가**

`AppCoordinator.swift` 상단에 추가:
```swift
import Onboarding
```

- [ ] **Step 2: AppCoordinatorDependency 프로토콜 반환 타입 변경**

```swift
// Before
var onboardingCoordinator: OnboardingCoordinator { get }

// After
var onboardingCoordinator: any OnboardingCoordinator { get }
```

- [ ] **Step 3: AppCoordinatorDependencyImpl.onboardingCoordinator 변경**

```swift
// Before
var onboardingCoordinator: OnboardingCoordinator {
    let navi = UINavigationController()
    return OnboardingCoordinatorImpl(
        navigationController: navi,
        onboardingService: onboardingService,
        userInfoService: userInfoService
    )
}

// After
var onboardingCoordinator: any OnboardingCoordinator {
    let navi = UINavigationController()
    return OnboardingCoordinator.make(
        navigationController: navi,
        onboardingService: onboardingService,
        userInfoService: userInfoService
    )
}
```

- [ ] **Step 4: AppCoordinatorImpl.showOnboarding() forced downcast 제거**

```swift
// Before
let onboardingCoordinator = dependency.onboardingCoordinator
(onboardingCoordinator as? OnboardingCoordinatorImpl)?.delegate = self
childCoordinators.append(onboardingCoordinator)

// After
var onboardingCoordinator = dependency.onboardingCoordinator
onboardingCoordinator.delegate = self
childCoordinators.append(onboardingCoordinator)
```

- [ ] **Step 5: 커밋**

```bash
git add QRIZ/Coordinator/AppCoordinator.swift
git commit -m "refactor: AppCoordinator Onboarding 패키지 연결"
```

### Task 13: HomeCoordinator.swift 수정

**Files:**
- Modify: `QRIZ/Feature/Home/HomeCoordinator.swift`

- [ ] **Step 1: import Onboarding 추가**

```swift
import Onboarding
```

- [ ] **Step 2: onboardingCoordinator 프로퍼티 타입 변경**

```swift
// Before
private var onboardingCoordinator: OnboardingCoordinator?

// After
private var onboardingCoordinator: (any OnboardingCoordinator)?
```

- [ ] **Step 3: showOnboarding() 수정**

```swift
// Before
func showOnboarding() {
    guard let navi = navigationController else { return }
    guardNavigation {
        let onboarding = OnboardingCoordinatorImpl(
            navigationController: navi,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
        onboarding.delegate = self
        childCoordinators.append(onboarding)
        _ = onboarding.start()
    }
}

// After
func showOnboarding() {
    guard let navi = navigationController else { return }
    guardNavigation {
        var onboarding = OnboardingCoordinator.make(
            navigationController: navi,
            onboardingService: self.onboardingService,
            userInfoService: self.userInfoService
        )
        onboarding.delegate = self
        self.onboardingCoordinator = onboarding
        self.childCoordinators.append(onboarding)
        _ = onboarding.start()
    }
}
```

- [ ] **Step 4: didFinishOnboarding 시그니처 변경**

```swift
// Before
func didFinishOnboarding(_ coordinator: OnboardingCoordinator) {

// After
func didFinishOnboarding(_ coordinator: any OnboardingCoordinator) {
```

- [ ] **Step 5: 커밋**

```bash
git add QRIZ/Feature/Home/HomeCoordinator.swift
git commit -m "refactor: HomeCoordinator Onboarding 패키지 연결"
```

### Task 14: 빌드 확인

- [ ] **Step 1: 빌드 실행**

```bash
xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj \
           -scheme QRIZ \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build 2>&1 | tail -20
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 2: 컴파일 에러 대응**

에러 발생 시 체크리스트:
- `OnboardingCoordinatorImpl` 참조가 남아 있는 파일 → `OnboardingCoordinator.make(...)` 또는 `any OnboardingCoordinator`로 교체
- `@MainActor` 격리 에러 → `AppCoordinatorDependencyImpl`에 `@MainActor` 추가
- missing import → 해당 파일에 import 추가

- [ ] **Step 3: 최종 커밋**

```bash
git add -A
git commit -m "feat: Onboarding 모듈화 완료"
```
