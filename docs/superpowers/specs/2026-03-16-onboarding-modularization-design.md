# Onboarding 모듈화 설계

**날짜:** 2026-03-16
**브랜치:** refactor/mistake-note-module → 다음 작업
**대상:** QRIZ/Feature/Onboarding → Onboarding Swift Package

---

## 목표

Onboarding 피처를 독립적인 Swift Package로 분리하고, 팩토리 함수 패턴을 통해 메인 앱과의 결합도를 최소화한다.

---

## 패키지 구조

```
Onboarding/
├── Package.swift
└── Sources/
    └── Onboarding/
        ├── Coordinator/
        │   └── OnboardingCoordinator.swift   ← public
        ├── BeginOnboarding/
        │   ├── ViewController/
        │   └── ViewModel/
        ├── CheckConcept/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── BeginPreviewTest/
        │   ├── ViewController/
        │   └── ViewModel/
        ├── PreviewTest/
        │   ├── ViewController/
        │   └── ViewModel/
        ├── PreviewResult/
        │   ├── HostingController/
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── Greeting/
        │   ├── ViewController/
        │   └── ViewModel/
        └── OnboardingComponents/
            ├── OnboardingButton.swift
            ├── OnboardingTitleLabel.swift
            └── OnboardingSubtitleLabel.swift
```

---

## Public API

모듈 외부에 노출되는 것은 다음 세 가지뿐이다.

```swift
// 외부 공개 (public)
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
```

### 프로토콜 분리 전략

기존 `OnboardingCoordinator` 프로토콜에는 ViewController가 호출하는 6개의 내부 내비게이션 메서드(`showBeginOnboarding`, `showCheckConcept` 등)가 있다. 이를 다음과 같이 분리한다.

```swift
// internal — ViewController가 coordinator를 참조할 때 사용
@MainActor
protocol OnboardingNavigating: AnyObject {
    func showBeginOnboarding()
    func showCheckConcept()
    func showBeginPreviewTest()
    func showPreviewTest()
    func showPreviewResult()
    func showGreeting()
}

// OnboardingCoordinatorImpl은 두 프로토콜 모두 채택
final class OnboardingCoordinatorImpl: OnboardingCoordinator, OnboardingNavigating { ... }
```

각 ViewController의 `weak var coordinator` 타입을 `OnboardingCoordinator` → `OnboardingNavigating`으로 변경한다.

`OnboardingCoordinatorImpl` 및 모든 ViewModel, ViewController, View는 `internal`.

---

## 의존성

```swift
// Package.swift (swift-tools-version: 6.0)
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
            dependencies: ["Network", "DesignSystem", "QRIZUtils", "ExamKit"]
        ),
    ]
)
```

**의존성 그래프:**
```
QRIZ (메인앱)
└── Onboarding ──→ Network
                ──→ DesignSystem
                ──→ QRIZUtils
                ──→ ExamKit
```

- Conceptbook 의존 없음
- 테스트 타겟 없음 (구조 분리 집중)

---

## 메인 앱 변경사항

변경이 필요한 파일: **AppCoordinator.swift**, **HomeCoordinator.swift**

### AppCoordinator.swift

`AppCoordinatorDependency` 프로토콜은 `var onboardingCoordinator: OnboardingCoordinator { get }`를 선언하고, `AppCoordinatorDependencyImpl`이 이를 구현한다. `AppCoordinatorImpl.showOnboarding()`은 `dependency.onboardingCoordinator`를 통해 Coordinator를 가져온다.

```swift
// Before — AppCoordinatorDependencyImpl
var onboardingCoordinator: OnboardingCoordinator {
    let navi = UINavigationController()
    return OnboardingCoordinatorImpl(
        navigationController: navi,
        onboardingService: onboardingService,
        userInfoService: userInfoService
    )
}

// Before — AppCoordinatorImpl.showOnboarding()
let onboardingCoordinator = dependency.onboardingCoordinator
(onboardingCoordinator as? OnboardingCoordinatorImpl)?.delegate = self  // forced downcast
childCoordinators.append(onboardingCoordinator)

// After — AppCoordinatorDependencyImpl (factory 호출로 교체)
import Onboarding

var onboardingCoordinator: any OnboardingCoordinator {
    let navi = UINavigationController()
    return OnboardingCoordinator.make(
        navigationController: navi,
        onboardingService: onboardingService,
        userInfoService: userInfoService
    )
}

// After — AppCoordinatorImpl.showOnboarding() (forced downcast 제거)
var onboardingCoordinator = dependency.onboardingCoordinator
onboardingCoordinator.delegate = self  // 직접 할당
childCoordinators.append(onboardingCoordinator)
```

`AppCoordinatorDependency` 프로토콜의 반환 타입도 `OnboardingCoordinator` → `any OnboardingCoordinator`로 변경한다.

### HomeCoordinator.swift

`HomeCoordinator`도 `OnboardingCoordinatorImpl`을 직접 참조하고 `OnboardingCoordinatorDelegate`를 구현한다.

현재 `HomeCoordinatorImpl`에는 `private var onboardingCoordinator: OnboardingCoordinator?` 프로퍼티가 선언되어 있으나 `showOnboarding()` 내부에서 할당되지 않은 상태다. 모듈화 시 이 프로퍼티를 활용해 identity를 보존한다.

```swift
// Before
import UIKit

// showOnboarding() — OnboardingCoordinatorImpl 직접 참조, typed property 미사용
func showOnboarding() {
    guard let navi = navigationController else { return }
    guardNavigation {
        let onboarding = OnboardingCoordinatorImpl(
            navigationController: navi,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
        onboarding.delegate = self
        childCoordinators.append(onboarding)  // typed property 할당 없음
        _ = onboarding.start()
    }
}

// delegate 시그니처 (bare, any 없음)
func didFinishOnboarding(_ coordinator: OnboardingCoordinator) {
    childCoordinators.removeAll { $0 === coordinator }
    ...
}

// After
import Onboarding

// showOnboarding() — factory + typed property 할당
func showOnboarding() {
    guard let navi = navigationController else { return }
    guardNavigation {
        var onboarding = OnboardingCoordinator.make(
            navigationController: navi,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
        onboarding.delegate = self
        onboardingCoordinator = onboarding   // typed property에 저장 (identity 보존)
        childCoordinators.append(onboarding)
        _ = onboarding.start()
    }
}

// delegate 시그니처 — any 키워드 추가 (패키지 정의에 맞춤)
func didFinishOnboarding(_ coordinator: any OnboardingCoordinator) {
    childCoordinators.removeAll { $0 === coordinator }
    ...
}
```

`private var onboardingCoordinator: OnboardingCoordinator?` 프로퍼티 타입을 `(any OnboardingCoordinator)?`로 변경한다.

### 공통 작업

- `import Onboarding` 추가
- `OnboardingCoordinatorImpl` 직접 참조 제거
- QRIZ.xcodeproj에 Onboarding 패키지 의존성 추가

---

## 주의사항

`AppCoordinatorDependencyImpl.onboardingCoordinator`는 non-isolated 컨텍스트에서 `@MainActor` 타입을 생성한다. 이는 기존 코드의 pre-existing 이슈로, Swift 6 strict concurrency 환경에서 컴파일 에러가 될 수 있다. 모듈화 작업 중 컴파일 에러 발생 시 `AppCoordinatorDependencyImpl`에 `@MainActor` 어노테이션 추가로 해결한다.

---

## 적용하지 않는 것

- 테스트 코드 (구조 분리 후 별도 작업)
- Conceptbook 의존성
- 기존 내부 로직 변경 (파일 이동 + 접근 제어자 수정, 프로토콜 분리만)
