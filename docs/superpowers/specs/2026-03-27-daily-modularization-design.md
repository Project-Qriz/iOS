# Daily SPM 모듈화 설계

**날짜:** 2026-03-27
**브랜치:** feat/daily-module
**대상:** QRIZ/Feature/Daily → Features/Daily Swift Package 분리

---

## 목표

Daily 피처를 독립 Swift Package로 분리한다.
Onboarding과 동일한 public/internal 프로토콜 분리 패턴을 적용한다.
Daily는 Home nav stack에 push하는 흐름이므로 `navigationController`를 외부에서 주입한다 (Onboarding 패턴).
테스트는 코드 리팩토링 및 코드 리뷰 이후 별도 작업으로 진행한다.

---

## 패키지 구조

```
Features/Daily/
├── Package.swift
└── Sources/Daily/
    ├── Coordinator/
    │   ├── DailyCoordinator.swift       ← public 프로토콜 + 팩토리
    │   └── DailyCoordinatorImpl.swift   ← internal 구현체
    ├── DailyLearn/
    │   ├── View/
    │   ├── ViewController/
    │   └── ViewModel/
    ├── DailyTest/
    │   ├── View/
    │   ├── ViewController/
    │   └── ViewModel/
    └── DailyResult/
        ├── HostingController/
        ├── View/
        ├── ViewController/
        └── ViewModel/
```

### Package.swift

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

---

## Public API

```swift
// DailyCoordinator.swift

@MainActor
public protocol DailyCoordinator: Coordinator {
    var delegate: DailyCoordinatorDelegate? { get set }
}

@MainActor
public protocol DailyCoordinatorDelegate: AnyObject {
    func didQuitDaily(_ coordinator: any DailyCoordinator)
    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator)
}

// Onboarding 패턴 — navigationController를 외부에서 주입
@MainActor
public func makeDailyCoordinator(
    navigationController: UINavigationController,
    dailyService: any DailyService,
    day: Int,
    type: DailyLearnType
) -> any DailyCoordinator
```

---

## Internal API

```swift
// DailyCoordinator.swift (internal)

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

// DailyCoordinatorImpl.swift
@MainActor
final class DailyCoordinatorImpl: DailyNavigating, NavigationGuard { }
```

각 ViewController의 `coordinator` 프로퍼티는 `(any DailyNavigating)?` 타입으로 선언한다.
`DailyCoordinator`(public)에는 show* 메서드가 없으므로 내부 전용인 `DailyNavigating`을 참조해야 한다.

`DailyCoordinatorImpl`은 `MistakeNote` 모듈의 `ProblemDetailCoordinating` 프로토콜도 채택한다.
`showProblemExplanation(questionId:)` 구현에 필요하며, 이 conformance를 누락하면 빌드 오류가 발생한다.

---

## HomeCoordinator 연결

```swift
// HomeCoordinator.swift
import Daily

// Before
func showDaily(day: Int, type: DailyLearnType) {
    guard let navi = navigationController else { return }
    guardNavigation {
        let daily = DailyCoordinatorImpl(navigationController: navi, dailyService: dailyService, day: day, type: type)
        daily.delegate = self
        childCoordinators.append(daily)
        _ = daily.start()
    }
}

// After
func showDaily(day: Int, type: DailyLearnType) {
    guard let navi = navigationController else { return }
    guardNavigation {
        var daily = makeDailyCoordinator(navigationController: navi, dailyService: dailyService, day: day, type: type)
        daily.delegate = self
        childCoordinators.append(daily)
        _ = daily.start()
    }
}

extension HomeCoordinatorImpl: DailyCoordinatorDelegate {
    func didQuitDaily(_ coordinator: any DailyCoordinator) { ... }
    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator) { ... }
}
```

---

## 작업 순서

1. `Features/Daily/Package.swift` 작성
2. 파일 이동 (QRIZ App 타겟 → Daily 패키지 서브피처 폴더)
   - `Conceptbook` import가 실제로 필요한지 확인 (`ConceptItem`, `Chapter` 타입 출처 검증)
3. `DailyCoordinator` public/internal 프로토콜 분리 및 팩토리 함수 작성
4. 접근 제어 확인 — 각 ViewController의 `coordinator` 프로퍼티가 `(any DailyNavigating)?` 타입인지 확인
5. `DailyCoordinatorImpl` — `DailyNavigating` 채택
6. `HomeCoordinator`에 `import Daily` 및 팩토리 패턴 적용
7. `QRIZ.xcodeproj`에 Daily 패키지 링크 추가, App 타겟 파일 제거
8. 빌드 확인

---

## 참고

- 기존 설계: `docs/superpowers/specs/2026-03-22-modularization-mypage-daily-exam-design.md`
- Onboarding 패턴 참고: `Features/Onboarding/Sources/Onboarding/Coordinator/`
- MyPage 패턴 참고: `Features/MyPage/Sources/MyPage/Coordinator/`
