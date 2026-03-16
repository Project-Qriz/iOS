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
        │   ├── ViewController/
        │   ├── ViewModel/
        │   └── View/
        ├── Greeting/
        │   ├── ViewController/
        │   └── ViewModel/
        └── Components/
            ├── OnboardingButton.swift
            ├── OnboardingTitleLabel.swift
            └── OnboardingSubtitleLabel.swift
```

---

## Public API

모듈 외부에 노출되는 것은 다음 세 가지뿐이다.

```swift
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

`OnboardingCoordinatorImpl` 및 모든 ViewModel, ViewController, View는 `internal`.

---

## 의존성

```swift
// Package.swift
dependencies: [
    .package(path: "../Network"),
    .package(path: "../DesignSystem"),
    .package(path: "../QRIZUtils"),
    .package(path: "../ExamKit"),
]
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

**AppCoordinator.swift:**

```swift
// Before
import UIKit

OnboardingCoordinatorImpl(
    navigationController: navi,
    onboardingService: onboardingService,
    userInfoService: userInfoService
)

// After
import Onboarding

OnboardingCoordinator.make(
    navigationController: navi,
    onboardingService: onboardingService,
    userInfoService: userInfoService
)
```

- `import Onboarding` 추가
- `OnboardingCoordinatorImpl` 직접 참조 제거
- `OnboardingCoordinatorDelegate` 구현은 그대로 유지 (프로토콜이 public으로 모듈에서 노출됨)
- QRIZ.xcodeproj에 Onboarding 패키지 의존성 추가

---

## 적용하지 않는 것

- 테스트 코드 (구조 분리 후 별도 작업)
- Conceptbook 의존성
- 기존 내부 로직 변경 (파일 이동 + 접근 제어자 수정만)
