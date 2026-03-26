# SettingsViewModel & DeleteAccountViewModel Unit Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `MyPageTests` 타겟에 `MockSocialLoginService`를 추가하고 `SettingsViewModel`(9개)과 `DeleteAccountViewModel`(7개) 유닛 테스트를 모두 작성한다.

**Architecture:** 기존 `MyPageViewModelTests` 패턴을 그대로 따른다 — `@MainActor @Suite(.serialized)`, `PassthroughSubject` + `Task.sleep`, `guard let first` + `guard case` assertion 패턴. `MockSocialLoginService`는 `MockMyPageService`와 동일한 `Result` 프로퍼티 방식으로 구현한다.

**Tech Stack:** Swift Testing (`@Suite`/`@Test`/`#expect`), Combine (`PassthroughSubject`, `sink`), `@unchecked Sendable` mock 패턴

---

## 파일 목록

| 작업 | 파일 |
|------|------|
| 생성 | `MyPage/Tests/MyPageTests/Mocks/MockSocialLoginService.swift` |
| 생성 | `MyPage/Tests/MyPageTests/UnitTests/SettingsViewModelTests.swift` |
| 생성 | `MyPage/Tests/MyPageTests/UnitTests/DeleteAccountViewModelTests.swift` |

**참고 파일:**
- `MyPage/Sources/MyPage/Settings/ViewModel/SettingsViewModel.swift` — 테스트 대상
- `MyPage/Sources/MyPage/DeleteAccount/ViewModel/DeleteAccountViewModel.swift` — 테스트 대상
- `Network/Sources/Network/Service/Auth/SocialLoginService.swift` — mock 대상 프로토콜
- `Network/Sources/Network/Base/NetworkError.swift` — 에러 케이스
- `QRIZUtils/Sources/QRIZUtils/Types/SocialLoginType.swift` — SocialLogin(from:) 매핑 확인
- `MyPage/Tests/MyPageTests/Mocks/MockMyPageService.swift` — mock 패턴 참고
- `MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift` — 테스트 패턴 참고
- `MyPage/Tests/MyPageTests/TestHelpers.swift` — asyncSleepNanoseconds

---

## Task 1: MockSocialLoginService 작성

**Files:**
- Create: `MyPage/Tests/MyPageTests/Mocks/MockSocialLoginService.swift`

- [ ] **Step 1: 파일 생성**

```swift
import Foundation
import UIKit
import Network
import QRIZUtils

final class MockSocialLoginService: SocialLoginService, @unchecked Sendable {

    enum MockError: Error { case notExpected }

    var logoutKakaoResult:  Result<Void, Error> = .success(())
    var logoutGoogleResult: Result<Void, Error> = .success(())
    var logoutAppleResult:  Result<Void, Error> = .success(())
    var unlinkKakaoResult:  Result<Void, Error> = .success(())

    func loginWithKakao() async throws -> SocialLoginResponse { throw MockError.notExpected }
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse { throw MockError.notExpected }
    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse { throw MockError.notExpected }

    func logoutKakao() async throws  { try logoutKakaoResult.get() }
    func logoutGoogle() async throws { try logoutGoogleResult.get() }
    func logoutApple() async throws  { try logoutAppleResult.get() }
    func unlinkKakao() async throws  { try unlinkKakaoResult.get() }
}
```

> `SocialLoginService` 프로토콜 전체 메서드: loginWithKakao, loginWithGoogle(presenting:), loginWithApple(presenting:), logoutKakao, logoutGoogle, logoutApple, unlinkKakao — 총 7개.
> login 메서드는 MyPage 테스트에서 호출되지 않으므로 `MockError.notExpected`를 throw (fatalError 사용 금지 — 테스트 프로세스 크래시 방지).

- [ ] **Step 2: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/Mocks/MockSocialLoginService.swift
git commit -m "feat: MockSocialLoginService 추가"
```

---

## Task 2: SettingsViewModelTests 동기 테스트 작성 (케이스 1–4)

**Files:**
- Create: `MyPage/Tests/MyPageTests/UnitTests/SettingsViewModelTests.swift`

동기 이벤트 4개 — `Task.sleep` 없이 `send` 직후 바로 assertion.

- [ ] **Step 1: 파일 생성**

```swift
import Foundation
import Testing
import Combine
@testable import MyPage
import Network

@MainActor
@Suite("SettingsViewModel 테스트", .serialized)
struct SettingsViewModelTests {

    private func makeSUT(
        userName: String = "테스트",
        email: String = "test@test.com",
        provider: String = "kakao",
        myPageService: MockMyPageService = .init(),
        socialLoginService: MockSocialLoginService = .init()
    ) -> SettingsViewModel {
        SettingsViewModel(
            userName: userName,
            email: email,
            provider: provider,
            myPageService: myPageService,
            socialLoginService: socialLoginService
        )
    }

    // MARK: - 동기 탭 이벤트

    @Test("viewDidLoad → setupProfile emit")
    func viewDidLoad_emitsSetupProfile() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .setupProfile(let userName, let email) = first else {
            Issue.record("Expected .setupProfile, got \(first)")
            return
        }
        #expect(userName == "테스트")
        #expect(email == "test@test.com")
    }

    @Test("didTapResetPassword → navigateToResetPassword emit")
    func didTapResetPassword_emitsNavigateToResetPassword() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapResetPassword)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .navigateToResetPassword = first else {
            Issue.record("Expected .navigateToResetPassword, got \(first)")
            return
        }
    }

    @Test("didTapLogout → showLogoutAlert emit")
    func didTapLogout_emitsShowLogoutAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapLogout)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showLogoutAlert = first else {
            Issue.record("Expected .showLogoutAlert, got \(first)")
            return
        }
    }

    @Test("didTapDeleteAccount → navigateToDeleteAccount emit")
    func didTapDeleteAccount_emitsNavigateToDeleteAccount() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapDeleteAccount)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .navigateToDeleteAccount = first else {
            Issue.record("Expected .navigateToDeleteAccount, got \(first)")
            return
        }
    }
}
```

- [ ] **Step 2: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/SettingsViewModelTests.swift
git commit -m "test: SettingsViewModel 동기 탭 이벤트 테스트 추가 (케이스 1-4)"
```

---

## Task 3: SettingsViewModelTests didConfirmLogout 테스트 작성 (케이스 5–9)

**Files:**
- Modify: `MyPage/Tests/MyPageTests/UnitTests/SettingsViewModelTests.swift`

`didConfirmLogout`은 내부에서 `Task { await self.performLogout() }` (fire-and-forget)으로 실행 → `Task.sleep` 필요.

- [ ] **Step 1: `SettingsViewModelTests` struct 닫는 `}` 앞에 아래 섹션 추가**

```swift
    // MARK: - didConfirmLogout

    @Test("didConfirmLogout kakao 성공 → logoutSucceeded emit")
    func didConfirmLogout_kakao_emitsLogoutSucceeded() async throws {
        let sut = makeSUT(provider: "kakao")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout google 성공 → logoutSucceeded emit")
    func didConfirmLogout_google_emitsLogoutSucceeded() async throws {
        let sut = makeSUT(provider: "google")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout apple 성공 → logoutSucceeded emit")
    func didConfirmLogout_apple_emitsLogoutSucceeded() async throws {
        let sut = makeSUT(provider: "apple")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout email 성공 → logoutSucceeded emit")
    func didConfirmLogout_email_emitsLogoutSucceeded() async throws {
        // email provider: SettingsViewModel의 switch에서 case .email: break → 서비스 호출 없이 logoutSucceeded
        let sut = makeSUT(provider: "email")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout 실패 → showErrorAlert emit")
    func didConfirmLogout_failure_emitsShowErrorAlert() async throws {
        let socialLoginService = MockSocialLoginService()
        socialLoginService.logoutKakaoResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(provider: "kakao", socialLoginService: socialLoginService)
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == "로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요.")
    }
```

> **에러 메시지 출처:** `SettingsViewModel.swift` `performLogout()` catch 블록:
> `outputSubject.send(.showErrorAlert("로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요."))`
> 하드코딩된 문자열이므로 위 값을 그대로 사용.

- [ ] **Step 2: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/SettingsViewModelTests.swift
git commit -m "test: SettingsViewModel didConfirmLogout 테스트 추가 (케이스 5-9)"
```

---

## Task 4: DeleteAccountViewModelTests 동기 테스트 작성 (케이스 1)

**Files:**
- Create: `MyPage/Tests/MyPageTests/UnitTests/DeleteAccountViewModelTests.swift`

- [ ] **Step 1: 파일 생성**

```swift
import Foundation
import Testing
import Combine
@testable import MyPage
import Network

@MainActor
@Suite("DeleteAccountViewModel 테스트", .serialized)
struct DeleteAccountViewModelTests {

    private func makeSUT(
        provider: String = "kakao",
        myPageService: MockMyPageService = .init(),
        socialLoginService: MockSocialLoginService = .init()
    ) -> DeleteAccountViewModel {
        DeleteAccountViewModel(
            provider: provider,
            myPageService: myPageService,
            socialLoginService: socialLoginService
        )
    }

    // MARK: - 동기 탭 이벤트

    @Test("didTapDelete → showConfirmAlert emit")
    func didTapDelete_emitsShowConfirmAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapDelete)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showConfirmAlert = first else {
            Issue.record("Expected .showConfirmAlert, got \(first)")
            return
        }
    }
}
```

- [ ] **Step 2: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/DeleteAccountViewModelTests.swift
git commit -m "test: DeleteAccountViewModel 동기 탭 이벤트 테스트 추가 (케이스 1)"
```

---

## Task 5: DeleteAccountViewModelTests didConfirmDelete 테스트 작성 (케이스 2–7)

**Files:**
- Modify: `MyPage/Tests/MyPageTests/UnitTests/DeleteAccountViewModelTests.swift`

`didConfirmDelete`는 내부에서 `Task { await self.performDelete() }` (fire-and-forget) → `Task.sleep` 필요.

provider별 deleteByProvider 분기:
- `"kakao"` → `unlinkKakao()` + `deleteSocialAccount(.kakao)` (두 호출 모두 성공해야 함)
- `"google"` → `deleteSocialAccount(.google)`
- `"apple"` → `deleteSocialAccount(.apple)`
- `"email"` → `deleteAccount()`

에러 케이스 주입: `"kakao"` provider에서 `unlinkKakaoResult`는 성공 유지, `deleteSocialAccountResult`만 실패로 설정.

- [ ] **Step 1: `DeleteAccountViewModelTests` struct 닫는 `}` 앞에 아래 섹션 추가**

```swift
    // MARK: - didConfirmDelete

    @Test("didConfirmDelete kakao 성공 → deletionSucceeded emit")
    func didConfirmDelete_kakao_emitsDeletionSucceeded() async throws {
        // kakao: unlinkKakao() + deleteSocialAccount(.kakao) 순서로 호출
        let sut = makeSUT(provider: "kakao")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete google 성공 → deletionSucceeded emit")
    func didConfirmDelete_google_emitsDeletionSucceeded() async throws {
        let sut = makeSUT(provider: "google")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete apple 성공 → deletionSucceeded emit")
    func didConfirmDelete_apple_emitsDeletionSucceeded() async throws {
        let sut = makeSUT(provider: "apple")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete email 성공 → deletionSucceeded emit")
    func didConfirmDelete_email_emitsDeletionSucceeded() async throws {
        // email: deleteAccount() 호출 (MockMyPageService.deleteAccountResult 기본값 = 성공)
        let sut = makeSUT(provider: "email")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete NetworkError 실패 → showErrorAlert emit")
    func didConfirmDelete_networkError_emitsShowErrorAlert() async throws {
        // kakao provider: unlinkKakao 성공 유지, deleteSocialAccount만 NetworkError 실패
        let myPageService = MockMyPageService()
        myPageService.deleteSocialAccountResult = .failure(NetworkError.serverError)
        let sut = makeSUT(provider: "kakao", myPageService: myPageService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == NetworkError.serverError.errorMessage)
    }

    @Test("didConfirmDelete 일반 Error 실패 → showErrorAlert emit")
    func didConfirmDelete_genericError_emitsShowErrorAlert() async throws {
        let myPageService = MockMyPageService()
        myPageService.deleteSocialAccountResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(provider: "kakao", myPageService: myPageService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        // DeleteAccountViewModel.swift performDelete() 일반 catch 블록 문자열
        #expect(message == "잠시 후 다시 시도해 주세요.")
    }
```

- [ ] **Step 2: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/DeleteAccountViewModelTests.swift
git commit -m "test: DeleteAccountViewModel didConfirmDelete 테스트 추가 (케이스 2-7)"
```
