# Daily SPM 모듈화 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `QRIZ/Feature/Daily/`를 `Features/Daily` Swift Package로 분리하고 HomeCoordinator에서 팩토리 함수로 연결한다.

**Architecture:** Onboarding 패턴과 동일하게 public/internal 프로토콜을 분리한다. `DailyCoordinator`(public)는 delegate만 노출하고, `DailyNavigating`(internal)이 모든 show* 메서드를 가진다. `DailyCoordinatorImpl`은 `DailyNavigating`과 `ProblemDetailCoordinating`을 채택한다.

**Tech Stack:** Swift Package Manager, UIKit, Combine, Swift 5 (language mode)

---

## File Map

| 작업 | 경로 |
|------|------|
| 생성 | `Features/Daily/Package.swift` |
| 생성 | `Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift` |
| 이동+수정 | `Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift` |
| 이동+수정 | `Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift` |
| 이동+수정 | `Features/Daily/Sources/Daily/DailyLearn/ViewModel/DailyLearnViewModel.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnSectionTitleLabel.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyLearn/View/StudyContentCell.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyLearn/View/StudyContentView.swift` |
| 이동+수정 | `Features/Daily/Sources/Daily/DailyTest/ViewController/DailyTestViewController.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyTest/ViewModel/DailyTestViewModel.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyTest/View/DailyTestFooterView.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyTest/View/DailyTestTimerLabel.swift` |
| 이동+수정 | `Features/Daily/Sources/Daily/DailyResult/ViewController/DailyResultViewController.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyResult/ViewModel/DailyResultViewModel.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyResult/HostingController/DailyResultHostingController.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyResult/View/DailyResultView.swift` |
| 이동 | `Features/Daily/Sources/Daily/DailyResult/View/DailyResultScoreView.swift` |
| 수정 | `QRIZ/Feature/Home/HomeCoordinator.swift` |

---

## Task 1: Package.swift 생성

**Files:**
- Create: `Features/Daily/Package.swift`

- [ ] `Features/Daily/` 디렉토리 생성 후 `Package.swift` 작성

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Daily",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Daily", targets: ["Daily"]),
    ],
    dependencies: [
        .package(path: "../../Core/Network"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ExamKit"),
        .package(path: "../Conceptbook"),
        .package(path: "../MistakeNote"),
    ],
    targets: [
        .target(
            name: "Daily",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
                "Conceptbook",
                "MistakeNote",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
```

- [ ] 커밋

```bash
git add Features/Daily/Package.swift
git commit -m "feat: Daily SPM Package.swift 생성"
```

---

## Task 2: 소스 파일 디렉토리 구조 생성 및 파일 이동

**Files:**
- Create: `Features/Daily/Sources/Daily/` 하위 디렉토리 구조
- Move: `QRIZ/Feature/Daily/` 전체 파일

- [ ] Sources 디렉토리 구조 생성

```bash
mkdir -p Features/Daily/Sources/Daily/Coordinator
mkdir -p Features/Daily/Sources/Daily/DailyLearn/View
mkdir -p Features/Daily/Sources/Daily/DailyLearn/ViewController
mkdir -p Features/Daily/Sources/Daily/DailyLearn/ViewModel
mkdir -p Features/Daily/Sources/Daily/DailyTest/View
mkdir -p Features/Daily/Sources/Daily/DailyTest/ViewController
mkdir -p Features/Daily/Sources/Daily/DailyTest/ViewModel
mkdir -p Features/Daily/Sources/Daily/DailyResult/HostingController
mkdir -p Features/Daily/Sources/Daily/DailyResult/View
mkdir -p Features/Daily/Sources/Daily/DailyResult/ViewController
mkdir -p Features/Daily/Sources/Daily/DailyResult/ViewModel
```

- [ ] 파일 이동 (DailyCoordinator.swift는 Task 3에서 재작성하므로 제외)

```bash
# DailyLearn
cp QRIZ/Feature/Daily/DailyLearn/View/DailyLearnSectionTitleLabel.swift Features/Daily/Sources/Daily/DailyLearn/View/
cp QRIZ/Feature/Daily/DailyLearn/View/StudyContentCell.swift Features/Daily/Sources/Daily/DailyLearn/View/
cp QRIZ/Feature/Daily/DailyLearn/View/StudyContentView.swift Features/Daily/Sources/Daily/DailyLearn/View/
cp QRIZ/Feature/Daily/DailyLearn/ViewController/DailyLearnViewController.swift Features/Daily/Sources/Daily/DailyLearn/ViewController/
cp QRIZ/Feature/Daily/DailyLearn/ViewModel/DailyLearnViewModel.swift Features/Daily/Sources/Daily/DailyLearn/ViewModel/

# DailyTest
cp QRIZ/Feature/Daily/DailyTest/View/DailyTestFooterView.swift Features/Daily/Sources/Daily/DailyTest/View/
cp QRIZ/Feature/Daily/DailyTest/View/DailyTestTimerLabel.swift Features/Daily/Sources/Daily/DailyTest/View/
cp QRIZ/Feature/Daily/DailyTest/ViewController/DailyTestViewController.swift Features/Daily/Sources/Daily/DailyTest/ViewController/
cp QRIZ/Feature/Daily/DailyTest/ViewModel/DailyTestViewModel.swift Features/Daily/Sources/Daily/DailyTest/ViewModel/

# DailyResult
cp QRIZ/Feature/Daily/DailyResult/HostingController/DailyResultHostingController.swift Features/Daily/Sources/Daily/DailyResult/HostingController/
cp QRIZ/Feature/Daily/DailyResult/View/DailyResultView.swift Features/Daily/Sources/Daily/DailyResult/View/
cp QRIZ/Feature/Daily/DailyResult/View/DailyResultScoreView.swift Features/Daily/Sources/Daily/DailyResult/View/
cp QRIZ/Feature/Daily/DailyResult/ViewController/DailyResultViewController.swift Features/Daily/Sources/Daily/DailyResult/ViewController/
cp QRIZ/Feature/Daily/DailyResult/ViewModel/DailyResultViewModel.swift Features/Daily/Sources/Daily/DailyResult/ViewModel/
```

- [ ] 커밋

```bash
git add Features/Daily/Sources/
git commit -m "feat: Daily 소스 파일 패키지로 이동"
```

---

## Task 3: DailyCoordinator.swift 작성 (public + internal 프로토콜)

**Files:**
- Create: `Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift`

기존 `QRIZ/Feature/Daily/DailyCoordinator.swift`를 public/internal로 분리한 새 파일을 작성한다.

- [ ] `Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift` 작성

```swift
import UIKit
import QRIZUtils
import Network
import Conceptbook
import MistakeNote

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol DailyCoordinator: Coordinator {
    var delegate: DailyCoordinatorDelegate? { get set }
}

@MainActor
public protocol DailyCoordinatorDelegate: AnyObject {
    func didQuitDaily(_ coordinator: any DailyCoordinator)
    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator)
}

@MainActor
public func makeDailyCoordinator(
    navigationController: UINavigationController,
    dailyService: any DailyService,
    day: Int,
    type: DailyLearnType
) -> any DailyCoordinator {
    DailyCoordinatorImpl(
        navigationController: navigationController,
        dailyService: dailyService,
        day: day,
        type: type
    )
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol DailyNavigating: DailyCoordinator {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()
}
```

- [ ] 커밋

```bash
git add Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift
git commit -m "feat: DailyCoordinator public/internal 프로토콜 분리"
```

---

## Task 4: DailyCoordinatorImpl.swift 작성

**Files:**
- Create: `Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift`

기존 `QRIZ/Feature/Daily/DailyCoordinator.swift`의 `DailyCoordinatorImpl` 구현을 가져와 다음을 수정한다.
- `DailyCoordinator` → `DailyNavigating` 채택으로 변경
- `ProblemDetailCoordinating` conformance 유지
- 기존 프로토콜 선언 제거 (Task 3에서 별도 파일로 작성함)

- [ ] `Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift` 작성

```swift
import UIKit
import QRIZUtils
import Network
import ExamKit
import Conceptbook
import MistakeNote

@MainActor
final class DailyCoordinatorImpl: DailyNavigating, NavigationGuard {

    // MARK: - Properties
    weak var delegate: DailyCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var dailyLearnViewController: DailyLearnViewController?
    private var dailyLearnViewModel: DailyLearnViewModel?
    private let service: any DailyService
    private let day: Int
    private let type: DailyLearnType

    // NavigationGuard
    var isNavigating: Bool = false

    // MARK: - Initializer
    init(
        navigationController: UINavigationController,
        dailyService: any DailyService,
        day: Int,
        type: DailyLearnType
    ) {
        self.navigationController = navigationController
        self.service = dailyService
        self.day = day
        self.type = type
    }

    // MARK: - Coordinator
    func start() -> UIViewController {
        showDailyLearn()
        return navigationController
    }

    // MARK: - DailyNavigating
    func showDailyLearn() {
        guardNavigation {
            let vm = DailyLearnViewModel(day: day, type: type, dailyService: service)
            let vc = DailyLearnViewController(dailyLearnViewModel: vm)
            dailyLearnViewController = vc
            dailyLearnViewModel = vm
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        guardNavigation {
            let vc = makeConceptPDFViewController(chapter: chapter, conceptItem: conceptItem)
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showDailyTest() {
        guardNavigation {
            let vm = DailyTestViewModel(dailyTestType: type, day: day, dailyService: service)
            let vc = DailyTestViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showDailyResult() {
        guardNavigation {
            let vm = DailyResultViewModel(dailyTestType: type, day: day, dailyService: service)
            let vc = DailyResultViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showResultDetail(resultDetailData: ResultDetailData) {
        guardNavigation {
            let vm = TestResultDetailViewModel(resultDetailData: resultDetailData)
            let vc = TestResultDetailViewController(viewModel: vm)
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showProblemExplanation(questionId: Int) {
        guardNavigation { [service, day] in
            let viewModel = ProblemDetailViewModel {
                let response = try await service.getDailyResultDetail(
                    dayNumber: day,
                    questionId: questionId
                )
                return response.data.toEntity()
            }
            let vc = ProblemDetailViewController(viewModel: viewModel)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func quitDaily() {
        if let dailyLearnVC = dailyLearnViewController, let dailyLearnVM = dailyLearnViewModel {
            _ = navigationController.popToViewController(dailyLearnVC, animated: true)
            dailyLearnVM.reloadData()
        }
    }
}

// MARK: - ProblemDetailCoordinating
extension DailyCoordinatorImpl: ProblemDetailCoordinating {
    func navigateToConceptTab() {
        delegate?.moveFromDailyToConcept(self)
    }

    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem) {
        showConcept(chapter: chapter, conceptItem: conceptItem)
    }
}
```

- [ ] 커밋

```bash
git add Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift
git commit -m "feat: DailyCoordinatorImpl DailyNavigating 채택"
```

---

## Task 5: ViewController coordinator 타입 수정

**Files:**
- Modify: `Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift`
- Modify: `Features/Daily/Sources/Daily/DailyTest/ViewController/DailyTestViewController.swift`
- Modify: `Features/Daily/Sources/Daily/DailyResult/ViewController/DailyResultViewController.swift`

`DailyCoordinator`(public)에는 show* 메서드가 없으므로, 각 VC의 `coordinator` 프로퍼티를 `DailyNavigating`으로 변경한다.

- [ ] `DailyLearnViewController.swift` — coordinator 타입 변경

```swift
// Before
weak var coordinator: DailyCoordinator?

// After
weak var coordinator: (any DailyNavigating)?
```

- [ ] `DailyTestViewController.swift` — coordinator 타입 변경

```swift
// Before
weak var coordinator: DailyCoordinator?

// After
weak var coordinator: (any DailyNavigating)?
```

- [ ] `DailyResultViewController.swift` — coordinator 타입 변경

```swift
// Before
weak var coordinator: DailyCoordinator?

// After
weak var coordinator: (any DailyNavigating)?
```

- [ ] 커밋

```bash
git add Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift
git add Features/Daily/Sources/Daily/DailyTest/ViewController/DailyTestViewController.swift
git add Features/Daily/Sources/Daily/DailyResult/ViewController/DailyResultViewController.swift
git commit -m "refactor: ViewController coordinator 타입을 DailyNavigating으로 변경"
```

---

## Task 6: HomeCoordinator 팩토리 패턴 적용

**Files:**
- Modify: `QRIZ/Feature/Home/HomeCoordinator.swift`

- [ ] `import Daily` 추가 및 `showDaily` 메서드를 팩토리 함수로 교체

```swift
// 파일 상단에 추가
import Daily

// showDaily 메서드 교체
func showDaily(day: Int, type: DailyLearnType) {
    guard let navi = navigationController else { return }
    guardNavigation {
        var daily = makeDailyCoordinator(
            navigationController: navi,
            dailyService: dailyService,
            day: day,
            type: type
        )
        daily.delegate = self
        childCoordinators.append(daily)
        _ = daily.start()
    }
}
```

- [ ] `DailyCoordinatorDelegate` extension의 타입 시그니처 확인

`HomeCoordinatorImpl: DailyCoordinatorDelegate` extension의 메서드 시그니처가 Daily 모듈의 public protocol과 일치하는지 확인한다.

```swift
extension HomeCoordinatorImpl: DailyCoordinatorDelegate {
    func didQuitDaily(_ coordinator: any DailyCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
    }

    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator) {
        delegate?.moveToConcept()
    }
}
```

- [ ] 커밋

```bash
git add QRIZ/Feature/Home/HomeCoordinator.swift
git commit -m "refactor: HomeCoordinator Daily 팩토리 패턴 적용"
```

---

## Task 7: Xcode 프로젝트 연결 및 구 파일 제거

**Files:**
- Modify: `QRIZ.xcodeproj` (Xcode에서 작업)
- Delete: `QRIZ/Feature/Daily/` 전체

- [ ] Xcode에서 Daily 패키지 링크 추가
  1. Xcode에서 `QRIZ.xcodeproj` 열기
  2. Project Navigator에서 `QRIZ` 프로젝트 선택
  3. `Package Dependencies` 탭 → `+` 버튼 → `Add Local...`
  4. `Features/Daily` 폴더 선택
  5. `QRIZ` 타겟 → `Frameworks, Libraries, and Embedded Content` → `+` → `Daily` 추가

- [ ] 구 파일 App 타겟에서 제거
  1. Project Navigator에서 `QRIZ/Feature/Daily/` 폴더 선택
  2. 모든 파일 선택 후 Delete (Move to Trash)

- [ ] 커밋

```bash
git add QRIZ.xcodeproj
git rm -r QRIZ/Feature/Daily/
git commit -m "refactor: Daily App 타겟 파일 제거 및 SPM 패키지 연결"
```

---

## Task 8: 빌드 확인

- [ ] 빌드 실행

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -20
```

Expected: `** BUILD SUCCEEDED **`

- [ ] 빌드 실패 시 — 에러 메시지 확인 후 수정
  - `'DailyCoordinator' is not a member of module` → HomeCoordinator에 `import Daily` 누락 확인
  - `type has no member 'showDailyTest'` → VC의 coordinator 타입이 `DailyNavigating`인지 확인
  - `does not conform to protocol 'ProblemDetailCoordinating'` → DailyCoordinatorImpl extension 확인

---

## 참고

- 설계 문서: `docs/superpowers/specs/2026-03-27-daily-modularization-design.md`
- Onboarding 패턴: `Features/Onboarding/Sources/Onboarding/Coordinator/`
