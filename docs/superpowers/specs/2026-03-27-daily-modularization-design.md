# Daily SPM 모듈화 설계

**날짜:** 2026-03-27
**브랜치:** feat/daily-module
**대상:** QRIZ/Feature/Daily → Features/Daily Swift Package 분리

---

## 목표

Daily 피처를 독립 Swift Package로 분리한다.
Onboarding/MyPage와 동일한 public/internal 프로토콜 분리 패턴을 적용한다.
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

### 의존성

```swift
.target(
    name: "Daily",
    dependencies: ["Network", "QRIZUtils", "ExamKit", "DesignSystem", "Conceptbook", "MistakeNote"]
)
```

---

## Public API

```swift
// DailyCoordinator.swift

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

@MainActor
public func makeDailyCoordinator(
    dailyService: any DailyService,
    day: Int,
    type: DailyLearnType
) -> any DailyCoordinator
```

---

## Internal API

```swift
// 패키지 내부 전용 — DailyCoordinator.swift 또는 DailyCoordinatorImpl.swift

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

// 구현체
@MainActor
final class DailyCoordinatorImpl: DailyNavigating, NavigationGuard { }
```

`start()`는 내부에서 `UINavigationController`를 생성해 반환한다 (MyPage 패턴).

---

## HomeCoordinator 연결

```swift
// HomeCoordinator.swift
import Daily

// Before
func showDaily(day: Int, type: DailyLearnType) {
    guardNavigation {
        let navi = UINavigationController()
        let daily = DailyCoordinatorImpl(navigationController: navi, dailyService: dailyService, day: day, type: type)
        daily.delegate = self
        childCoordinators.append(daily)
        _ = daily.start()
    }
}

// After
func showDaily(day: Int, type: DailyLearnType) {
    guardNavigation {
        let daily = makeDailyCoordinator(dailyService: dailyService, day: day, type: type)
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
3. `DailyCoordinator` public/internal 프로토콜 분리 및 팩토리 함수 작성
4. `DailyCoordinatorImpl` — `DailyNavigating` 채택, `start()` 내부 navigationController 생성으로 변경
5. `HomeCoordinator`에 `import Daily` 및 팩토리 패턴 적용
6. `QRIZ.xcodeproj`에 Daily 패키지 링크 추가, App 타겟 파일 제거
7. 빌드 확인

---

## 참고

- 기존 설계: `docs/superpowers/specs/2026-03-22-modularization-mypage-daily-exam-design.md`
- MyPage 패턴 참고: `Features/MyPage/Sources/MyPage/Coordinator/`
- Onboarding 패턴 참고: `Features/Onboarding/Sources/Onboarding/Coordinator/`
