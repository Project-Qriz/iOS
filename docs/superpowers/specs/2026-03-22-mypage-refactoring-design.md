# MyPage 패키지 리팩토링 설계

**날짜:** 2026-03-22
**브랜치:** feat/mypage-module
**대상:** `MyPage/Sources/MyPage/` 전체

---

## 목표

MyPage 패키지의 코드 품질을 개선한다. 버그 수정, dead code 제거, View-ViewModel 커플링 해소, 컴포넌트 분리를 포함한다. 기능 변경은 없다.

---

## Phase 1 — MyPage 서브피처

### 변경 파일
- `MyPage/View/MyPageMainView.swift`
- `MyPage/ViewController/MyPageViewController.swift`

### 문제: View가 ViewModel.Input 타입을 직접 노출

`MyPageMainView`의 `quickActionTappedPublisher`가 `AnyPublisher<MyPageViewModel.Input, Never>` 타입이다. View 레이어가 ViewModel의 Input enum을 알면 안 된다.

```swift
// 현재 (커플링) — MyPageMainView의 subject 타입과 registration 클로저에서 발생
var quickActionTappedPublisher: AnyPublisher<MyPageViewModel.Input, Never>
// quickActionTappedSubject: PassthroughSubject<MyPageViewModel.Input, Never>
// registration 클로저에서 .didTapResetPlan, .didTapRegisterExam을 직접 send
```

`QuickActionsCell` 자체는 이미 `AnyPublisher<Void, Never>`를 노출하고 있어 변경 불필요.

### 수정

**MyPageMainView:** subject 타입과 registration 클로저를 분리:

```swift
// 두 개의 Void publisher로 교체
var resetPlanTappedPublisher: AnyPublisher<Void, Never>
var registerExamTappedPublisher: AnyPublisher<Void, Never>

// registration 클로저에서 QuickActionsCell의 기존 publisher를 그대로 forwarding
```

**MyPageViewController:** `bind()`에서 ViewModel.Input으로 매핑하고 기존 `quickActionTap` merge 교체:

```swift
// 기존 quickActionTap 제거
// let quickActionTap = rootView.quickActionTappedPublisher  ← 삭제

let resetPlan = rootView.resetPlanTappedPublisher
    .map { MyPageViewModel.Input.didTapResetPlan }
let registerExam = rootView.registerExamTappedPublisher
    .map { MyPageViewModel.Input.didTapRegisterExam }

let input = viewDidLoad
    .merge(with: profileTap)
    .merge(with: resetPlan)
    .merge(with: registerExam)
    .merge(with: menuTap)
    .eraseToAnyPublisher()
```

### 문제: lazy 강제 초기화 패턴

`setupUI()` 안에 `_ = quickActionRegistration`, `_ = profileRegistration`이 있어 lazy 프로퍼티를 강제 초기화한다. `init`에서 직접 초기화하거나 lazy를 제거하는 방식으로 정리한다.

---

## Phase 2 — Settings 서브피처

### 변경 파일
- 삭제: `Settings/ViewController/ChangePasswordViewController.swift`
- 삭제: `Settings/ViewModel/ChangePasswordViewModel.swift`
- 삭제: `Settings/View/ChangePasswordMainView.swift`
- 삭제: `Settings/View/Components/ChangePasswordInputView.swift`
- 수정: `Settings/ViewModel/SettingsViewModel.swift`

### Dead code 제거

`ChangePasswordViewController/ViewModel/View`는 coordinator에 진입 경로가 없는 dead code다. `ChangePasswordViewModel` 상단 TODO 주석에도 "UI와 API 로직의 차이로 추후 재구현 필요"라고 명시되어 있다. 4개 파일을 삭제한다.

`SettingsViewController`, `SettingsViewModel`은 이 파일들을 참조하지 않으므로 추가 수정 불필요.

### Logger 추가

`SettingsViewModel`에 Logger 추가 — `MyPageViewModel`, `DeleteAccountViewModel`과 일관성을 맞춘다.

```swift
private let logger = Logger.make(category: "SettingsViewModel")

// performLogout의 catch 블록에서 사용 — privacy: .public 패턴 준수
} catch {
    logger.error("Logout failed: \(error.localizedDescription, privacy: .public)")
    outputSubject.send(.showErrorAlert("로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요."))
}
```

---

## Phase 3 — DeleteAccount 서브피처

### 변경 파일
- 수정: `DeleteAccount/View/DeleteAccountMainView.swift`
- 신규: `DeleteAccount/View/Components/DeleteAccountInfoView.swift`

### 버그 수정: trailing constraint

`DeleteAccountMainView` 내 `infoContainerView` trailing constraint의 constant 부호가 잘못되어 있다:

```swift
// 현재 (버그) — infoContainerView 오른쪽이 화면 밖으로 나감
infoContainerView.trailingAnchor.constraint(
    equalTo: trailingAnchor,
    constant: Metric.horizontalSpacing   // +18.0
)

// 수정
infoContainerView.trailingAnchor.constraint(
    equalTo: trailingAnchor,
    constant: -Metric.horizontalSpacing  // -18.0
)
```

### 오타 수정

`Metric` 내 상수 선언과 `setupConstraints()` 내 사용처 모두 수정:

```swift
// 현재 (선언)
static let delteButtonTopOffset: CGFloat = 14.0
// 현재 (사용처, setupConstraints() 내)
constant: Metric.delteButtonTopOffset

// 수정 (선언 + 사용처 동시)
static let deleteButtonTopOffset: CGFloat = 14.0
constant: Metric.deleteButtonTopOffset
```

### 컴포넌트 추출: `DeleteAccountInfoView`

`DeleteAccountMainView`(246줄)에서 경고 카드 부분을 추출한다.

```
DeleteAccount/
└── View/
    ├── DeleteAccountMainView.swift   ← 전체 레이아웃 담당
    └── Components/
        └── DeleteAccountInfoView.swift  ← 경고 카드 (bullet 2개)
```

`DeleteAccountInfoView`:
- `bulletLabel1`: "회원 탈퇴 시 계정 정보는 모두 삭제됩니다."
- `bulletLabel2`: "진행 중인 '오늘의 공부'를 포함해..."
- 테두리, 그림자 스타일 포함
- 외부 인터페이스 없음 (표시 전용)

`DeleteAccountMainView`는 `DeleteAccountInfoView()`를 생성해 레이아웃에 배치한다.

---

## Phase 4 — Coordinator

변경 없음. `MyPageCoordinatorImpl`의 alert 메서드는 명확하고 읽기 쉬운 현재 구조를 유지한다.

---

## 변경 요약

| 서브피처 | 파일 수 | 주요 변경 |
|---|---|---|
| MyPage | 수정 2 | quickAction publisher 분리, lazy 초기화 정리 |
| Settings | 삭제 4, 수정 1 | ChangePassword dead code 제거, Logger 추가 |
| DeleteAccount | 수정 1, 신규 1 | 버그 수정 2개, 컴포넌트 추출 |
| Coordinator | 없음 | — |
