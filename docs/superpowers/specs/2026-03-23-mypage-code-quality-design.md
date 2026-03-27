# MyPage 코드 품질 리팩토링 설계

**날짜:** 2026-03-23
**브랜치:** feat/mypage-module
**대상:** `MyPage/Sources/MyPage/` 및 `QRIZ/Feature/TabBar/TabBarCoordinator.swift`

---

## 목표

MyPage 패키지의 테스트 가능성과 코드 품질을 개선한다. 기능 변경 없음.

두 가지 축:
1. **Coordinator UserInfoManager 의존성 제거** — `MyPageUserInfo` 값 타입 주입으로 교체
2. **코드 품질 정리** — `guard let self` 패턴 현대화, TermItem 하드코딩 추출, magic number 제거

---

## Section 1 — Coordinator UserInfoManager 의존성 제거

### 문제

`MyPageCoordinatorImpl`이 `UserInfoManager.shared`를 직접 참조한다.

```swift
// start()
let viewModel = MyPageViewModel(userName: UserInfoManager.shared.name, ...)

// showSettingsView()
let viewModel = SettingsViewModel(
    userName: UserInfoManager.shared.name,
    email: UserInfoManager.shared.email, ...
)
```

Coordinator를 테스트하거나 다른 컨텍스트에서 재사용할 때 singleton이 걸림돌이 된다.
나중에 유저 정보 필드가 추가될 경우 factory 함수 시그니처 변경 없이 `MyPageUserInfo`만 확장하면 된다.

### 변경 파일

- **수정:** `MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift`
- **수정:** `MyPage/Sources/MyPage/Coordinator/MyPageCoordinatorImpl.swift`
- **수정:** `QRIZ/Feature/TabBar/TabBarCoordinator.swift`

### 수정 내용

**`MyPageCoordinator.swift`** — `MyPageUserInfo` 추가, factory 시그니처 변경:

```swift
public struct MyPageUserInfo {
    public let name: String
    public let email: String

    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

public func makeMyPageCoordinator(
    userInfo: MyPageUserInfo,
    myPageService: any MyPageService,
    accountRecoveryService: any AccountRecoveryService,
    socialLoginService: any SocialLoginService
) -> any MyPageCoordinator
```

**`MyPageCoordinatorImpl.swift`** — `userInfo` 저장 프로퍼티 추가, init에 `userInfo` 파라미터 추가, `UserInfoManager.shared` 참조 제거:

```swift
private let userInfo: MyPageUserInfo

init(
    userInfo: MyPageUserInfo,
    myPageService: MyPageService,
    accountRecoveryService: AccountRecoveryService,
    socialLoginService: SocialLoginService
) {
    self.userInfo = userInfo
    // ...
}

func start() -> UIViewController {
    let viewModel = MyPageViewModel(userName: userInfo.name, myPageService: myPageService)
    // ...
}

func showSettingsView() {
    guardNavigation {
        let viewModel = SettingsViewModel(
            userName: userInfo.name,
            email: userInfo.email,
            myPageService: myPageService,
            socialLoginService: socialLoginService
        )
        // ...
    }
}
```

**`TabBarCoordinator.swift`** — `_myPageCoordinator` lazy var에서 `makeMyPageCoordinator` 호출 시 `MyPageUserInfo` 전달:

```swift
makeMyPageCoordinator(
    userInfo: MyPageUserInfo(
        name: UserInfoManager.shared.name,
        email: UserInfoManager.shared.email
    ),
    myPageService: dependency.myPageService,
    accountRecoveryService: dependency.accountRecoveryService,
    socialLoginService: dependency.socialLoginService
)
```

`UserInfoManager.shared` 참조는 패키지 외부인 `TabBarCoordinator`에만 남는다.

`UserInfoManager`는 `QRIZUtils` 모듈에 정의된 싱글턴이며 `public var name: String`, `public var email: String` 프로퍼티를 모두 제공한다 (`QRIZUtils/Sources/QRIZUtils/Manager/UserInfoManager.swift`). `TabBarCoordinator.swift`는 이미 `import QRIZUtils`를 포함하고 있으므로 추가 import 없이 컴파일된다.

> **참고:** `TabBarCoordinator.swift` 261번째 줄 `moveFromMistakeNoteToExam` 클로저 내부에도 `guard let self = self else { return }` 패턴이 존재하지만, 이 파일은 `MyPage` 패키지 외부이므로 본 스펙 범위에서 제외한다.

---

## Section 2 — 코드 품질

### 2-1. `guard let self = self` → `guard let self`

Swift 5.3부터 `guard let self` 단축 표현이 지원된다. 패키지 전체에 구버전 패턴이 혼재한다.

**대상 파일 및 위치:**

| 파일 | 줄 | 메서드 |
|---|---|---|
| `MyPage/ViewModel/MyPageViewModel.swift` | 30 | `transform(input:)` — input sink 클로저 |
| `MyPage/ViewModel/MyPageViewModel.swift` | 67 | `fetchVersion()` — Task 클로저 |
| `Settings/ViewModel/SettingsViewModel.swift` | 44 | `transform(input:)` — input sink 클로저 |
| `DeleteAccount/ViewModel/DeleteAccountViewModel.swift` | 32 | `transform(input:)` — input sink 클로저 |
| `DeleteAccount/ViewController/DeleteAccountViewController.swift` | 61 | `bind()` — output sink 클로저 |

```swift
// 기존
guard let self = self else { return }

// 변경
guard let self else { return }
```

### 2-2. `MyPageViewModel` TermItem 하드코딩 → 상수 추출

`TermItem`은 `Account` 모듈에 정의된 public 타입으로, `MyPageViewModel.swift` 상단에 `import Account`가 이미 선언되어 있다.

약관 메타데이터(제목, PDF 파일명)가 `transform(input:)` 내부에 인라인으로 작성되어 있다.

```swift
// 기존 — ViewModel 로직 내부에 데이터 혼재
case .didTapTermsOfService:
    self.outputSubject.send(.showTermsDetail(termItem: TermItem(
        title: "서비스 이용약관",
        pdfName: "TermsOfService",
        isAgreed: false)))

case .didTapPrivacyPolicy:
    self.outputSubject.send(.showTermsDetail(termItem: TermItem(
        title: "개인정보 처리방침",
        pdfName: "PrivacyPolicy",
        isAgreed: false)))
```

```swift
// 변경 — MyPageViewModel.swift 파일 하단 private extension으로 추출
private extension TermItem {
    static let termsOfService = TermItem(
        title: "서비스 이용약관",
        pdfName: "TermsOfService",
        isAgreed: false
    )
    static let privacyPolicy = TermItem(
        title: "개인정보 처리방침",
        pdfName: "PrivacyPolicy",
        isAgreed: false
    )
}

// transform(input:) 내부
case .didTapTermsOfService:
    outputSubject.send(.showTermsDetail(termItem: .termsOfService))
case .didTapPrivacyPolicy:
    outputSubject.send(.showTermsDetail(termItem: .privacyPolicy))
```

**변경 파일:** `MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift`

### 2-3. `SupportMenuCell` magic number `25` → `Metric`

`SupportMenuCell.setupConstraints()`에 `constant: 25`, `constant: -25`가 `Metric` 없이 인라인으로 사용된다.

```swift
// 기존
titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),

// 변경 — SupportMenuCell.Metric에 추가
private enum Metric {
    static let horizontalSpacing: CGFloat = 24.0
    static let verticalSpacing: CGFloat = 25.0
}

titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.verticalSpacing),
titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.verticalSpacing),
```

**변경 파일:** `MyPage/Sources/MyPage/MyPage/View/Components/SupportMenuCell.swift`

---

## 변경 요약

| 구분 | 파일 수 | 주요 변경 |
|---|---|---|
| Coordinator UserInfo 주입 | 수정 3 | `MyPageUserInfo` 타입 추가, factory 시그니처 변경, TabBar 호출 업데이트 |
| guard let self 현대화 | 수정 4 | `guard let self = self else` → `guard let self` |
| TermItem 상수 추출 | 수정 1 | private extension으로 이동 |
| magic number 제거 | 수정 1 | `SupportMenuCell.Metric.verticalSpacing` 추가 |
