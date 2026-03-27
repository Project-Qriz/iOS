# MyPage 코드 품질 리팩토링 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MyPage 패키지에서 `UserInfoManager.shared` 직접 참조를 값 타입 주입으로 교체하고, Swift 5.3+ `guard let self` 패턴 현대화, TermItem 인라인 데이터 상수 추출, magic number 제거를 통해 코드 품질을 개선한다.

**Architecture:** Coordinator가 `UserInfoManager.shared`를 직접 참조하는 대신 `MyPageUserInfo` 값 타입을 외부에서 주입받는다. 코드 품질 변경은 기능을 바꾸지 않는 순수 리팩토링이다.

**Tech Stack:** Swift 5.9, UIKit, Combine, SPM 로컬 패키지 (`MyPage`)

---

## 파일 구조

| 파일 | 변경 유형 | 내용 |
|---|---|---|
| `MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift` | 수정 | `MyPageUserInfo` struct 추가, factory 시그니처에 `userInfo:` 파라미터 추가 |
| `MyPage/Sources/MyPage/Coordinator/MyPageCoordinatorImpl.swift` | 수정 | `private let userInfo: MyPageUserInfo` 추가, init 파라미터 추가, `UserInfoManager.shared` 참조 제거 |
| `QRIZ/Feature/TabBar/TabBarCoordinator.swift` | 수정 | `_myPageCoordinator` lazy var에서 `MyPageUserInfo` 전달 |
| `MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift` | 수정 | `guard let self` 현대화 (line 30, 67), TermItem 인라인 → private extension 상수 추출 |
| `MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift` | 수정 | `guard let self` 현대화 (line 44) |
| `MyPage/Sources/MyPage/DeleteAccount/ViewModel/DeleteAccountViewModel.swift` | 수정 | `guard let self` 현대화 (line 32) |
| `MyPage/Sources/MyPage/DeleteAccount/ViewController/DeleteAccountViewController.swift` | 수정 | `guard let self` 현대화 (line 61) |
| `MyPage/Sources/MyPage/MyPage/View/Components/SupportMenuCell.swift` | 수정 | `Metric.verticalSpacing` 추가, magic number `25` 교체 |

---

## Task 1: MyPageUserInfo 타입 추가 및 Coordinator DI 적용

**Spec:** Section 1 — `MyPageCoordinator.swift` + `MyPageCoordinatorImpl.swift`

**Files:**
- Modify: `MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift`
- Modify: `MyPage/Sources/MyPage/Coordinator/MyPageCoordinatorImpl.swift`

> 이 태스크는 순수 리팩토링이다. 빌드가 깨지는 것을 먼저 확인하고, 수정 후 빌드 성공을 검증한다.

- [ ] **Step 1: `MyPageCoordinator.swift`에 `MyPageUserInfo` struct 추가 및 factory 시그니처 변경**

  `MyPageCoordinator.swift`의 `makeMyPageCoordinator` 함수 위에 struct를 추가하고, 함수 시그니처에 `userInfo: MyPageUserInfo` 첫 번째 파라미터를 추가한다.

  ```swift
  // MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift
  // 기존 makeMyPageCoordinator 함수 위에 추가
  public struct MyPageUserInfo {
      public let name: String
      public let email: String

      public init(name: String, email: String) {
          self.name = name
          self.email = email
      }
  }

  // makeMyPageCoordinator 함수 교체
  @MainActor
  public func makeMyPageCoordinator(
      userInfo: MyPageUserInfo,
      myPageService: any MyPageService,
      accountRecoveryService: any AccountRecoveryService,
      socialLoginService: any SocialLoginService
  ) -> any MyPageCoordinator {
      MyPageCoordinatorImpl(
          userInfo: userInfo,
          myPageService: myPageService,
          accountRecoveryService: accountRecoveryService,
          socialLoginService: socialLoginService
      )
  }
  ```

- [ ] **Step 2: `MyPageCoordinatorImpl.swift`에 `userInfo` 프로퍼티 및 init 파라미터 추가, `UserInfoManager.shared` 제거**

  `MyPageCoordinatorImpl.swift`에서:
  1. `private let userInfo: MyPageUserInfo` 프로퍼티를 기존 프로퍼티 목록에 추가한다 (첫 번째 줄로 추가).
  2. `init`에 `userInfo: MyPageUserInfo` 첫 번째 파라미터를 추가하고, `self.userInfo = userInfo`를 추가한다.
  3. `start()`의 `UserInfoManager.shared.name` → `userInfo.name`으로 교체한다.
  4. `showSettingsView()`의 `UserInfoManager.shared.name` → `userInfo.name`, `UserInfoManager.shared.email` → `userInfo.email`로 교체한다.

  수정 후 전체 파일 상태:

  ```swift
  // 프로퍼티 선언부 (기존 선언 유지하면서 맨 위에 추가)
  private let userInfo: MyPageUserInfo
  private weak var navigationController: UINavigationController?
  weak var delegate: MyPageCoordinatorDelegate?
  private let myPageService: MyPageService
  private let accountRecoveryService: AccountRecoveryService
  private let socialLoginService: SocialLoginService
  var childCoordinators: [Coordinator] = []
  var isNavigating: Bool = false

  // init 교체
  init(
      userInfo: MyPageUserInfo,
      myPageService: MyPageService,
      accountRecoveryService: AccountRecoveryService,
      socialLoginService: SocialLoginService
  ) {
      self.userInfo = userInfo
      self.myPageService = myPageService
      self.accountRecoveryService = accountRecoveryService
      self.socialLoginService = socialLoginService
  }

  // start() 내 수정
  let viewModel = MyPageViewModel(
      userName: userInfo.name,
      myPageService: myPageService
  )

  // showSettingsView() 내 수정
  let viewModel = SettingsViewModel(
      userName: userInfo.name,
      email: userInfo.email,
      myPageService: myPageService,
      socialLoginService: socialLoginService
  )
  ```

- [ ] **Step 3: 빌드 확인 (에러 예상)**

  이 시점에서 `TabBarCoordinator.swift`가 아직 업데이트되지 않아 컴파일 에러가 발생해야 정상이다. 에러 없이 빌드된다면 변경이 제대로 적용되지 않은 것이다.

  ```bash
  xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
  ```

  Expected: `error: extra argument 'myPageService' in call` 또는 `error: missing argument for parameter 'userInfo'` — `TabBarCoordinator.swift` 관련 에러

- [ ] **Step 4: 빌드 에러가 없으면 Task 1 변경 재확인**

  Step 3에서 에러가 없으면 파일이 올바르게 수정되지 않은 것이다. `MyPageCoordinator.swift`와 `MyPageCoordinatorImpl.swift`를 다시 읽어 Step 1, 2 변경 사항이 실제로 적용되었는지 확인하고, 누락된 부분을 수정한 뒤 Step 3을 재실행한다. 빌드 에러가 확인되었으면 Task 2로 진행한다.

- [ ] **Step 5: 커밋**

  ```bash
  git -C /Users/hun/iOS add MyPage/Sources/MyPage/Coordinator/MyPageCoordinator.swift \
          MyPage/Sources/MyPage/Coordinator/MyPageCoordinatorImpl.swift
  git -C /Users/hun/iOS commit -m "refactor: MyPageCoordinatorImpl UserInfoManager 의존성 제거, MyPageUserInfo 값 타입 주입"
  ```

---

## Task 2: TabBarCoordinator callsite 업데이트 및 빌드 검증

**Spec:** Section 1 — `TabBarCoordinator.swift` `_myPageCoordinator` lazy var 업데이트

**Files:**
- Modify: `QRIZ/Feature/TabBar/TabBarCoordinator.swift`

> `TabBarCoordinator.swift`는 이미 `import QRIZUtils`를 포함하고 있으므로 추가 import 없이 `UserInfoManager.shared`를 참조할 수 있다. `import MyPage`도 이미 있으므로 `MyPageUserInfo` 타입도 바로 사용 가능하다.

- [ ] **Step 1: `_myPageCoordinator` lazy var 수정**

  `TabBarCoordinator.swift`에서 `_myPageCoordinator` lazy var를 찾아 `makeMyPageCoordinator` 호출에 `userInfo:` 첫 번째 파라미터를 추가한다.

  ```swift
  // 기존 (line 74~78)
  private lazy var _myPageCoordinator = makeMyPageCoordinator(
      myPageService: myPageService,
      accountRecoveryService: accountRecoveryService,
      socialLoginService: socialLoginService
  )

  // 변경 후
  private lazy var _myPageCoordinator = makeMyPageCoordinator(
      userInfo: MyPageUserInfo(
          name: UserInfoManager.shared.name,
          email: UserInfoManager.shared.email
      ),
      myPageService: myPageService,
      accountRecoveryService: accountRecoveryService,
      socialLoginService: socialLoginService
  )
  ```

- [ ] **Step 2: 빌드 성공 확인**

  ```bash
  xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
  ```

  Expected: `Build succeeded`

  빌드 에러가 있으면 에러 메시지를 읽고 원인을 파악한다. `UserInfoManager` 또는 `MyPageUserInfo` 관련 에러라면 import 누락을 확인한다.

- [ ] **Step 3: 커밋**

  ```bash
  git -C /Users/hun/iOS add QRIZ/Feature/TabBar/TabBarCoordinator.swift
  git -C /Users/hun/iOS commit -m "refactor: TabBarCoordinator에서 MyPageUserInfo 전달로 변경"
  ```

---

## Task 3: 코드 품질 정리

**Spec:** Section 2-1 (`guard let self`), Section 2-2 (TermItem 상수), Section 2-3 (magic number)

**Files:**
- Modify: `MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift`
- Modify: `MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift`
- Modify: `MyPage/Sources/MyPage/DeleteAccount/ViewModel/DeleteAccountViewModel.swift`
- Modify: `MyPage/Sources/MyPage/DeleteAccount/ViewController/DeleteAccountViewController.swift`
- Modify: `MyPage/Sources/MyPage/MyPage/View/Components/SupportMenuCell.swift`

### 2-1: `guard let self` 현대화

- [ ] **Step 1: MyPageViewModel.swift 2곳 수정**

  ```
  파일: MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift
  ```

  - Line 30 (`transform(input:)` input sink 클로저):
    ```swift
    // 기존
    guard let self = self else { return }
    // 변경
    guard let self else { return }
    ```

  - Line 67 (`fetchVersion()` Task 클로저):
    ```swift
    // 기존
    guard let self = self else { return }
    // 변경
    guard let self else { return }
    ```

    > **주의:** line 66의 `Task { [weak self] in` — `[weak self]` 캡처 리스트는 그대로 유지한다. `guard let self` 한 줄만 수정한다.

- [ ] **Step 2: SettingsViewModel.swift 1곳 수정**

  ```
  파일: MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift
  ```

  - Line 44 (`transform(input:)` input sink 클로저):
    ```swift
    // 기존
    guard let self = self else { return }
    // 변경
    guard let self else { return }
    ```

- [ ] **Step 3: DeleteAccountViewModel.swift 1곳 수정**

  ```
  파일: MyPage/Sources/MyPage/DeleteAccount/ViewModel/DeleteAccountViewModel.swift
  ```

  - Line 32 (`transform(input:)` input sink 클로저):
    ```swift
    // 기존
    guard let self = self else { return }
    // 변경
    guard let self else { return }
    ```

- [ ] **Step 4: DeleteAccountViewController.swift 1곳 수정**

  ```
  파일: MyPage/Sources/MyPage/DeleteAccount/ViewController/DeleteAccountViewController.swift
  ```

  - Line 61 (`bind()` output sink 클로저):
    ```swift
    // 기존
    guard let self = self else { return }
    // 변경
    guard let self else { return }
    ```

### 2-2: TermItem 상수 추출

- [ ] **Step 5: MyPageViewModel.swift TermItem 인라인 교체 및 private extension 추가**

  `transform(input:)` 내부의 `didTapTermsOfService`, `didTapPrivacyPolicy` 케이스를 교체하고, 파일 맨 아래에 `private extension TermItem`을 추가한다.

  ```
  파일: MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift
  ```

  `transform(input:)` 내부 교체 (기존 lines 47~57). 기존 코드에는 `self.outputSubject.send(...)` 형태이고 `TermItem(...)` 인라인이 있다. 교체 후에는 `self.` 접두사를 제거하고 정적 상수를 사용한다:
  ```swift
  case .didTapTermsOfService:
      outputSubject.send(.showTermsDetail(termItem: .termsOfService))

  case .didTapPrivacyPolicy:
      outputSubject.send(.showTermsDetail(termItem: .privacyPolicy))
  ```

  파일 맨 아래 (`extension MyPageViewModel { ... }` 블록 이후) 추가:
  ```swift
  // MARK: - TermItem Constants

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
  ```

### 2-3: SupportMenuCell magic number 제거

- [ ] **Step 6: SupportMenuCell.swift Metric.verticalSpacing 추가 및 magic number 교체**

  ```
  파일: MyPage/Sources/MyPage/MyPage/View/Components/SupportMenuCell.swift
  ```

  `SupportMenuCell`의 `private enum Metric`에 `verticalSpacing` 추가:
  ```swift
  private enum Metric {
      static let horizontalSpacing: CGFloat = 24.0
      static let verticalSpacing: CGFloat = 25.0
  }
  ```

  `setupConstraints()` 내 교체 (lines 169, 171):
  ```swift
  // 기존
  titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
  titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),

  // 변경
  titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.verticalSpacing),
  titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.verticalSpacing),
  ```

### 검증 및 커밋

- [ ] **Step 7: 빌드 성공 확인**

  ```bash
  xcodebuild -project /Users/hun/iOS/QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
  ```

  Expected: `Build succeeded`

- [ ] **Step 8: 커밋**

  ```bash
  git -C /Users/hun/iOS add \
      MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift \
      MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift \
      MyPage/Sources/MyPage/DeleteAccount/ViewModel/DeleteAccountViewModel.swift \
      MyPage/Sources/MyPage/DeleteAccount/ViewController/DeleteAccountViewController.swift \
      MyPage/Sources/MyPage/MyPage/View/Components/SupportMenuCell.swift
  git -C /Users/hun/iOS commit -m "refactor: guard let self 현대화, TermItem 상수 추출, SupportMenuCell magic number 제거"
  ```
