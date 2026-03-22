# MyPage 리팩토링 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MyPage 패키지의 코드 품질 개선 — View-ViewModel 커플링 해소, dead code 제거, 버그 수정, 컴포넌트 추출 (기능 변경 없음)

**Architecture:** Coordinator + MVVM + Combine (Input/Output 패턴). 3개 서브피처(MyPage, Settings, DeleteAccount) 순서로 독립적으로 처리. Phase 4 Coordinator는 변경 없음.

**Tech Stack:** Swift 5, UIKit, Combine, SPM (MyPage 로컬 패키지 at `/Users/hun/iOS/MyPage/`)

---

## File Map

### Phase 1 — MyPage 서브피처
- **Modify:** `MyPage/Sources/MyPage/MyPage/View/MyPageMainView.swift`
  - `quickActionTappedSubject/Publisher` (타입: `MyPageViewModel.Input`) → `resetPlanTappedSubject/Publisher` + `registerExamTappedSubject/Publisher` (타입: `Void`)
  - `quickActionRegistration` 클로저에서 ViewModel.Input 직접 참조 제거
  - `setupUI()` 내 lazy 강제 초기화 패턴 제거
- **Modify:** `MyPage/Sources/MyPage/MyPage/ViewController/MyPageViewController.swift`
  - `bind()`에서 `quickActionTap` 단일 publisher → `resetPlan` + `registerExam` 두 publisher로 교체

### Phase 2 — Settings 서브피처
- **Delete:** `MyPage/Sources/MyPage/Settings/ViewController/ChangePasswordViewController.swift`
- **Delete:** `MyPage/Sources/MyPage/Settings/ViewModel/ChangePasswordViewModel.swift`
- **Delete:** `MyPage/Sources/MyPage/Settings/View/ChangePasswordMainView.swift`
- **Delete:** `MyPage/Sources/MyPage/Settings/View/Components/ChangePasswordInputView.swift`
- **Modify:** `MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift`
  - Logger 추가 (`MyPageViewModel`, `DeleteAccountViewModel`과 일관성)

### Phase 3 — DeleteAccount 서브피처
- **Modify:** `MyPage/Sources/MyPage/DeleteAccount/View/DeleteAccountMainView.swift`
  - trailing constraint 버그 수정
  - `delteButtonTopOffset` → `deleteButtonTopOffset` 오타 수정
  - `infoContainerView` + `bulletLabel1` + `bulletLabel2` → `DeleteAccountInfoView` 교체
- **Create:** `MyPage/Sources/MyPage/DeleteAccount/View/Components/DeleteAccountInfoView.swift`
  - 경고 카드 컴포넌트 (bullet 2개, 테두리·그림자 스타일)

---

## Task 1: MyPage — quickAction publisher 분리 + lazy 초기화 정리

**Files:**
- Modify: `MyPage/Sources/MyPage/MyPage/View/MyPageMainView.swift`
- Modify: `MyPage/Sources/MyPage/MyPage/ViewController/MyPageViewController.swift`

**Background:** `MyPageMainView`의 `quickActionTappedPublisher`가 `AnyPublisher<MyPageViewModel.Input, Never>` 타입이다. View 레이어가 ViewModel의 Input enum을 알아서는 안 된다. `QuickActionsCell`은 이미 `AnyPublisher<Void, Never>`를 노출하므로 View는 이를 그대로 forwarding하면 된다. ViewModel.Input 매핑은 ViewController.bind()에서 처리한다.

- [ ] **Step 1: `MyPageMainView` — subject/publisher 교체**

`MyPage/Sources/MyPage/MyPage/View/MyPageMainView.swift` 17~28줄을 교체:

```swift
// 삭제
private let quickActionTappedSubject = PassthroughSubject<MyPageViewModel.Input, Never>()

var quickActionTappedPublisher: AnyPublisher<MyPageViewModel.Input, Never> {
    quickActionTappedSubject.eraseToAnyPublisher()
}

// 교체
private let resetPlanTappedSubject = PassthroughSubject<Void, Never>()
private let registerExamTappedSubject = PassthroughSubject<Void, Never>()

var resetPlanTappedPublisher: AnyPublisher<Void, Never> {
    resetPlanTappedSubject.eraseToAnyPublisher()
}

var registerExamTappedPublisher: AnyPublisher<Void, Never> {
    registerExamTappedSubject.eraseToAnyPublisher()
}
```

- [ ] **Step 2: `MyPageMainView` — `quickActionRegistration` 클로저 수정**

42~58줄의 `quickActionRegistration` 클로저 내부를 교체:

```swift
// 기존 (ViewModel.Input을 직접 send)
cell.resetPlanTappedPublisher
    .sink { [weak self] _ in
        self?.quickActionTappedSubject.send(.didTapResetPlan)
    }
    .store(in: &cell.cancellables)

cell.registerExamTappedPublisher
    .sink { [weak self] _ in
        self?.quickActionTappedSubject.send(.didTapRegisterExam)
    }
    .store(in: &cell.cancellables)

// 교체 (Void 그대로 forwarding)
cell.resetPlanTappedPublisher
    .sink { [weak self] in
        self?.resetPlanTappedSubject.send()
    }
    .store(in: &cell.cancellables)

cell.registerExamTappedPublisher
    .sink { [weak self] in
        self?.registerExamTappedSubject.send()
    }
    .store(in: &cell.cancellables)
```

- [ ] **Step 3: `MyPageMainView` — `setupUI()` lazy 강제 초기화 제거**

`setupUI()` 132~136줄에서 `_ =` 강제 초기화 라인 삭제:

```swift
// 기존
private func setupUI() {
    _ = quickActionRegistration
    _ = profileRegistration
    backgroundColor = .customBlue50
}

// 교체
private func setupUI() {
    backgroundColor = .customBlue50
}
```

> **Note:** `profileRegistration`, `quickActionRegistration`은 `self`를 캡처하므로 `lazy` 유지 필요. `dataSource` 클로저가 이들을 사용할 때 자동으로 lazy 초기화되므로 강제 초기화가 불필요하다.

- [ ] **Step 4: `MyPageViewController` — `bind()` 수정**

`bind()` 50~67줄에서 `quickActionTap` 단일 publisher → 두 publisher로 교체:

```swift
// 기존
let quickActionTap = rootView.quickActionTappedPublisher

let input = viewDidLoad
    .merge(with: profileTap)
    .merge(with: menuTap)
    .merge(with: quickActionTap)
    .eraseToAnyPublisher()

// 교체
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

- [ ] **Step 5: 빌드 확인**

```bash
xcodebuild build \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E 'error:|BUILD'
```

Expected: `BUILD SUCCEEDED`, `error:` 없음

- [ ] **Step 6: 커밋**

```bash
git add MyPage/Sources/MyPage/MyPage/View/MyPageMainView.swift \
        MyPage/Sources/MyPage/MyPage/ViewController/MyPageViewController.swift
git commit -m "refactor: MyPageMainView quickAction publisher를 Void 타입으로 분리"
```

---

## Task 2: Settings — ChangePassword dead code 삭제 + Logger 추가

**Files:**
- Delete: `MyPage/Sources/MyPage/Settings/ViewController/ChangePasswordViewController.swift`
- Delete: `MyPage/Sources/MyPage/Settings/ViewModel/ChangePasswordViewModel.swift`
- Delete: `MyPage/Sources/MyPage/Settings/View/ChangePasswordMainView.swift`
- Delete: `MyPage/Sources/MyPage/Settings/View/Components/ChangePasswordInputView.swift`
- Modify: `MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift`

**Background:** `ChangePassword` 4개 파일은 coordinator에 진입 경로가 없는 dead code다. `ChangePasswordViewModel` 상단 TODO 주석에도 재구현 필요라고 명시되어 있다. `SettingsViewModel`에는 `MyPageViewModel`, `DeleteAccountViewModel`과 달리 Logger가 없다.

- [ ] **Step 1: ChangePassword 4개 파일 삭제**

```bash
rm MyPage/Sources/MyPage/Settings/ViewController/ChangePasswordViewController.swift
rm MyPage/Sources/MyPage/Settings/ViewModel/ChangePasswordViewModel.swift
rm MyPage/Sources/MyPage/Settings/View/ChangePasswordMainView.swift
rm MyPage/Sources/MyPage/Settings/View/Components/ChangePasswordInputView.swift
```

- [ ] **Step 2: `SettingsViewModel` — Logger 추가**

`MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift`에서:

2줄: `import Foundation` 아래에 `import os` 추가:
```swift
import Foundation
import os
import Combine
import QRIZUtils
import Network
```

Properties 영역 (`outputSubject` 선언 아래)에 logger 추가:
```swift
private let outputSubject = PassthroughSubject<Output, Never>()
private let logger = Logger.make(category: "SettingsViewModel")
private var cancellables = Set<AnyCancellable>()
```

`performLogout()` catch 블록 수정:
```swift
// 기존
} catch {
    outputSubject.send(.showErrorAlert("로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요."))
}

// 교체
} catch {
    logger.error("Logout failed: \(error.localizedDescription, privacy: .public)")
    outputSubject.send(.showErrorAlert("로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요."))
}
```

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild build \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E 'error:|BUILD'
```

Expected: `BUILD SUCCEEDED`, `error:` 없음

> **Note:** `SettingsViewController`와 `SettingsViewModel`은 ChangePassword 파일들을 참조하지 않으므로 삭제 후 추가 수정 불필요.

- [ ] **Step 4: 커밋**

```bash
git add -u MyPage/Sources/MyPage/Settings/
git commit -m "refactor: ChangePassword dead code 제거 및 SettingsViewModel Logger 추가"
```

---

## Task 3: DeleteAccount — 버그 수정 + DeleteAccountInfoView 컴포넌트 추출

**Files:**
- Modify: `MyPage/Sources/MyPage/DeleteAccount/View/DeleteAccountMainView.swift`
- Create: `MyPage/Sources/MyPage/DeleteAccount/View/Components/DeleteAccountInfoView.swift`

**Background:** `DeleteAccountMainView`에 두 가지 버그 존재. 또한 경고 카드 영역(bulletLabel 2개, infoContainerView)을 별도 컴포넌트로 추출해 파일 크기를 줄인다.

### 버그 수정 먼저

- [ ] **Step 1: trailing constraint 부호 수정**

`DeleteAccountMainView.swift` 179~182줄 (infoContainerView trailing):

```swift
// 기존 (버그 — infoContainerView 오른쪽이 화면 밖으로 나감)
infoContainerView.trailingAnchor.constraint(
    equalTo: trailingAnchor,
    constant: Metric.horizontalSpacing   // +18.0
),

// 수정
infoContainerView.trailingAnchor.constraint(
    equalTo: trailingAnchor,
    constant: -Metric.horizontalSpacing  // -18.0
),
```

- [ ] **Step 2: `delteButtonTopOffset` 오타 수정**

`Metric` enum 내 선언 (line 16):
```swift
// 기존
static let delteButtonTopOffset: CGFloat = 14.0

// 수정
static let deleteButtonTopOffset: CGFloat = 14.0
```

`setupConstraints()` 내 사용처 (line 229):
```swift
// 기존
constant: Metric.delteButtonTopOffset

// 수정
constant: Metric.deleteButtonTopOffset
```

### DeleteAccountInfoView 컴포넌트 추출

- [ ] **Step 3: `DeleteAccountInfoView.swift` 생성**

`MyPage/Sources/MyPage/DeleteAccount/View/Components/DeleteAccountInfoView.swift`를 생성:

```swift
import UIKit
import DesignSystem
import QRIZUtils

final class DeleteAccountInfoView: UIView {

    // MARK: - Enums

    private enum Metric {
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 20.0
        static let bulletLabel2TopOffset: CGFloat = 8.0
    }

    private enum Attributes {
        static let bullet1Text: String = "•  회원 탈퇴 시 계정 정보는 모두 삭제됩니다."
        static let bullet2Text: String = "•  진행 중인 '오늘의 공부'를 포함해, 모든 데이터가 삭\n    제되며 복구할 수 없습니다."
    }

    // MARK: - UI

    private let bulletLabel1: UILabel = {
        let label = UILabel()
        label.text = Attributes.bullet1Text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        return label
    }()

    private let bulletLabel2: UILabel = {
        let label = UILabel()
        label.text = Attributes.bullet2Text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func setupStyle() {
        backgroundColor = .white
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.coolNeutral100.cgColor
        layer.cornerRadius = 8.0
        applyQRIZShadow(radius: 8.0, color: .coolNeutral300)
    }
}

// MARK: - Layout Setup

extension DeleteAccountInfoView {
    private func addSubviews() {
        [bulletLabel1, bulletLabel2].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        bulletLabel1.translatesAutoresizingMaskIntoConstraints = false
        bulletLabel2.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bulletLabel1.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Metric.verticalSpacing
            ),
            bulletLabel1.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            bulletLabel1.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),

            bulletLabel2.topAnchor.constraint(
                equalTo: bulletLabel1.bottomAnchor,
                constant: Metric.bulletLabel2TopOffset
            ),
            bulletLabel2.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            bulletLabel2.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            bulletLabel2.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Metric.verticalSpacing
            )
        ])
    }
}
```

- [ ] **Step 4: `DeleteAccountMainView` — infoContainerView 제거 후 DeleteAccountInfoView로 교체**

`DeleteAccountMainView.swift` 전체를 아래와 같이 수정:

**제거:**
- `Metric.bulletLabel2TopOffset` 상수 (Step 3에서 DeleteAccountInfoView로 이동)
- `Attributes.bullet1Text`, `Attributes.bullet2Text` (Step 3에서 DeleteAccountInfoView로 이동)
- `private let infoContainerView: UIView` 프로퍼티 전체
- `private let bulletLabel1: UILabel` 프로퍼티 전체
- `private let bulletLabel2: UILabel` 프로퍼티 전체

**추가:**
```swift
private let infoView = DeleteAccountInfoView()
```

**`addSubviews()` 수정:**
```swift
// 기존
[
    separator,
    titleLabel,
    infoContainerView,
    questionLabel,
    deleteButton
].forEach(addSubview(_:))

[
    bulletLabel1,
    bulletLabel2
].forEach(infoContainerView.addSubview(_:))

// 교체
[
    separator,
    titleLabel,
    infoView,
    questionLabel,
    deleteButton
].forEach(addSubview(_:))
```

**`setupConstraints()` 수정:**

translatesAutoresizingMaskIntoConstraints 설정: `infoContainerView` → `infoView`로 교체, `bulletLabel1`, `bulletLabel2` 라인 삭제

제약 조건: `infoContainerView`에 관한 제약 4개 → `infoView` 3개로 교체 (bulletLabel 제약 전체 삭제):
```swift
// infoContainerView 기존 제약 4개 삭제 후 아래로 교체
infoView.topAnchor.constraint(
    equalTo: titleLabel.bottomAnchor,
    constant: Metric.verticalSpacing
),
infoView.leadingAnchor.constraint(
    equalTo: leadingAnchor,
    constant: Metric.horizontalSpacing
),
infoView.trailingAnchor.constraint(
    equalTo: trailingAnchor,
    constant: -Metric.horizontalSpacing
),
```

그리고 `questionLabel.topAnchor`의 참조를 `infoContainerView.bottomAnchor` → `infoView.bottomAnchor`로 교체:
```swift
questionLabel.topAnchor.constraint(
    equalTo: infoView.bottomAnchor,
    constant: Metric.verticalSpacing
),
```

- [ ] **Step 5: 빌드 확인**

```bash
xcodebuild build \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E 'error:|BUILD'
```

Expected: `BUILD SUCCEEDED`, `error:` 없음

- [ ] **Step 6: 커밋**

```bash
git add MyPage/Sources/MyPage/DeleteAccount/
git commit -m "refactor: DeleteAccount trailing constraint 버그·오타 수정 및 InfoView 컴포넌트 추출"
```
