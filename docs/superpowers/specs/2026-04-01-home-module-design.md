# Home 모듈화 설계

**날짜:** 2026-04-01
**브랜치:** develop
**목표:** `QRIZ/Feature/Home/`을 `Features/Home/` Swift Package로 분리하고, `TabBarCoordinator`의 `HomeCoordinatorImpl` 직접 downcast를 제거한다.

---

## 배경

현재 Home 피처는 메인 앱 타깃(`QRIZ/Feature/Home/`)에 남아있는 유일한 주요 피처다. Daily, Exam, Onboarding, Conceptbook 등 나머지 피처는 이미 `Features/` 하위 Swift Package로 분리되어 있다.

`TabBarCoordinatorImpl`이 `HomeCoordinatorImpl`로 직접 downcast하여 내부 프로퍼티(`homeVM`, `examDelegate`, `navigationController`)에 접근하고 있어, 모듈화 전에 이 경계를 먼저 정리해야 한다.

---

## 접근 방식

Daily/Exam과 동일한 패턴을 따른다:

- **Public:** `HomeCoordinator` 프로토콜, `HomeCoordinatorDelegate`, `ExamSelectionDelegate`, `makeHomeCoordinator()` 팩토리 함수
- **Internal:** `HomeCoordinatorImpl`, 모든 ViewController, ViewModel, View

---

## 모듈 구조

```
Features/Home/
├── Package.swift
├── Sources/Home/
│   ├── Coordinator/
│   │   ├── HomeCoordinator.swift       ← public protocol + factory
│   │   └── HomeCoordinatorImpl.swift   ← internal 구현
│   ├── ViewController/
│   │   ├── HomeViewController.swift
│   │   ├── DaySelectSheetViewController.swift
│   │   └── ExamScheduleSelectionViewController.swift
│   ├── ViewModel/
│   │   ├── HomeViewModel.swift
│   │   ├── DaySelectBottomSheetViewModel.swift
│   │   └── ExamScheduleSelectionViewModel.swift
│   └── View/
│       └── (기존 View 파일 전체)
└── Tests/HomeTests/
```

---

## Package.swift 의존성

```swift
dependencies: [
    .package(path: "../../Core/Network"),
    .package(path: "../../Core/DesignSystem"),
    .package(path: "../../Core/QRIZUtils"),
    .package(path: "../Daily"),
    .package(path: "../Exam"),
    .package(path: "../Onboarding"),
    .package(path: "../Conceptbook"),
]
```

---

## HomeCoordinator public protocol 변경

기존 대비 추가되는 항목:

| 추가 항목 | 이유 |
|-----------|------|
| `var examDelegate: (any ExamSelectionDelegate)? { get set }` | TabBar가 직접 impl에 설정하던 것을 protocol로 |
| `func handleExamScheduleUpdate()` | `homeVM?.reloadExamSchedule()` + `needsRefresh` 분기 로직 캡슐화 |
| `func showExamScheduleSelectionSheet(from: UIViewController)` | MyPage에서 시험 일정 선택 시트를 띄울 때 TabBar가 VC를 직접 생성하던 것을 위임 |

최종 protocol:

```swift
public protocol HomeCoordinator: Coordinator {
    var delegate: HomeCoordinatorDelegate? { get set }
    var examDelegate: (any ExamSelectionDelegate)? { get set }
    var needsRefresh: Bool { get set }
    func handleExamScheduleUpdate()
    func showExamScheduleSelectionSheet(from viewController: UIViewController)
    func showExamSelectionSheet()
    func showOnboarding()
    func showExam()
    func showDaily(day: Int, type: DailyLearnType)
    func showResetAlert(confirm: @escaping () -> Void)
    func showDaySelectAlert(totalDays: Int, selectedDay: Int, todayIndex: Int?)
    func showConceptPDF(chapter: Chapter, conceptItem: ConceptItem)
}
```

`ExamSelectionDelegate`는 `HomeCoordinator.swift`로 이동 (현재 `HomeCoordinator.swift` 내에 이미 정의되어 있음).

팩토리 함수 시그니처:

```swift
public func makeHomeCoordinator(
    examService: any ExamScheduleService,
    examTestService: any ExamService,
    dailyService: any DailyService,
    onboardingService: any OnboardingService,
    userInfoService: any UserInfoService,
    weeklyService: any WeeklyRecommendService
) -> any HomeCoordinator {
    HomeCoordinatorImpl(
        examService: examService,
        examTestService: examTestService,
        dailyService: dailyService,
        onboardingService: onboardingService,
        userInfoService: userInfoService,
        weeklyService: weeklyService
    )
}
```

---

## TabBarCoordinator 변경

### 타입 변경

```swift
// Before
private let homeCoordinator: HomeCoordinatorImpl

// After
import Home
private var homeCoordinator: any HomeCoordinator
```

### init downcast 제거

```swift
// Before
guard let home = dependency.homeCoordinator as? HomeCoordinatorImpl else { fatalError(...) }
self.homeCoordinator = home

// After
self.homeCoordinator = dependency.homeCoordinator
```

### ExamSelectionDelegate

```swift
// Before
func didUpdateExamSchedule() {
    if let tabBar = homeCoordinator.navigationController?.tabBarController,
       tabBar.selectedIndex == 0 {
        homeCoordinator.homeVM?.reloadExamSchedule()
    } else {
        homeCoordinator.needsRefresh = true
    }
}

// After
func didUpdateExamSchedule() {
    homeCoordinator.handleExamScheduleUpdate()
}
```

### MyPageCoordinatorDelegate

```swift
// Before
func myPageCoordinatorDidRequestExamScheduleSelection(...) {
    let viewModel = ExamScheduleSelectionViewModel(...)
    let vc = ExamScheduleSelectionViewController(...)
    presentingNC.present(vc, animated: true)
}

// After
func myPageCoordinatorDidRequestExamScheduleSelection(...) {
    let presentingVC = tabBarController?.selectedViewController ?? tabBarController
    homeCoordinator.showExamScheduleSelectionSheet(from: presentingVC!)
}
```

---

## 마이그레이션

1. `Features/Home/` 패키지 생성 및 `Package.swift` 작성
2. `QRIZ/Feature/Home/` 파일 전체를 `Features/Home/Sources/Home/`으로 이동
3. 모든 타입에 접근 제어자 적용 (`public` / `internal`)
4. `QRIZ.xcodeproj`에 `Features/Home` 패키지 추가
5. `TabBarCoordinator.swift` 수정 (import Home, downcast 제거, delegate 정리)
6. `QRIZ/Feature/Home/` 디렉토리 삭제

---

## 기타

- `QRIZ/Feature/Daily/DailyLearn/View/StudyContentView.swift`: Daily 모듈화 당시 남은 파일로 추정. 구현 중 확인 후 삭제 여부 결정.
- `MistakeNoteCoordinatorImpl` downcast는 이번 스코프 외. 별도 작업으로 처리.
