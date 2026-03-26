# SettingsViewModel & DeleteAccountViewModel Unit Tests — Design Spec

**Date:** 2026-03-26
**Scope:** SettingsViewModel, DeleteAccountViewModel 유닛 테스트 작성 + MockSocialLoginService 인프라 추가

---

## 목표

`MyPageTests` 타겟에 `MockSocialLoginService`를 추가하고, `SettingsViewModel`과 `DeleteAccountViewModel`의 모든 Input→Output 경로를 검증하는 유닛 테스트를 작성한다.

---

## 파일 구조

```
MyPage/Tests/MyPageTests/
├── Mocks/
│   ├── MockMyPageService.swift           (기존)
│   └── MockSocialLoginService.swift      (신규)
└── UnitTests/
    ├── MyPageViewModelTests.swift        (기존)
    ├── SettingsViewModelTests.swift      (신규)
    └── DeleteAccountViewModelTests.swift (신규)
```

---

## MockSocialLoginService

`SocialLoginService` 프로토콜을 구현하는 mock. 기존 `MockMyPageService` 패턴(`Result` 프로퍼티 + `@unchecked Sendable`)을 따른다. login 메서드는 MyPage 테스트에서 사용되지 않으므로 `MockError.notExpected`를 throw한다.

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

---

## SocialLogin 문자열 매핑

`SocialLogin(from:)`은 소문자 rawValue를 사용한다 (`QRIZUtils/SocialLoginType.swift`):

| Provider 문자열 | SocialLogin case |
|----------------|-----------------|
| `"kakao"` | `.kakao` |
| `"google"` | `.google` |
| `"apple"` | `.apple` |
| `"email"` (또는 unknown) | `.email` (fallback) |

---

## SettingsViewModelTests

테스트 프레임워크: Swift Testing (`@Suite`, `@Test`, `#expect`)
스타일: `@MainActor`, `.serialized`, 한국어 테스트 이름

### SUT Factory

```swift
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
```

### MARK: - 동기 탭 이벤트 (4개)

| # | Input | Expected Output |
|---|-------|-----------------|
| 1 | `viewDidLoad` | `.setupProfile(userName: "테스트", email: "test@test.com")` |
| 2 | `didTapResetPassword` | `.navigateToResetPassword` |
| 3 | `didTapLogout` | `.showLogoutAlert` |
| 4 | `didTapDeleteAccount` | `.navigateToDeleteAccount` |

동기 이벤트는 `Task.sleep` 없이 `send` 직후 바로 assertion.

### MARK: - didConfirmLogout (5개)

| # | Provider | Mock 설정 | Expected Output |
|---|----------|-----------|-----------------|
| 5 | `"kakao"` | 기본값 | `.logoutSucceeded` |
| 6 | `"google"` | 기본값 | `.logoutSucceeded` |
| 7 | `"apple"` | 기본값 | `.logoutSucceeded` |
| 8 | `"email"` | 기본값 (서비스 호출 없음) | `.logoutSucceeded` |
| 9 | `"kakao"` | `logoutKakaoResult = .failure(URLError(.notConnectedToInternet))` | `.showErrorAlert("로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요.")` |

`didConfirmLogout`은 내부에서 `Task { }` (fire-and-forget)으로 실행되므로 `Task.sleep(nanoseconds: asyncSleepNanoseconds)`로 대기.

**케이스 1 assertion 패턴 (`.setupProfile` — 연관값 2개):**
```swift
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
```

**케이스 9 assertion 패턴 (`.showErrorAlert` — String 연관값):**
```swift
guard case .showErrorAlert(let message) = first else {
    Issue.record("Expected .showErrorAlert, got \(first)")
    return
}
#expect(message == "로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요.")
```

---

## DeleteAccountViewModelTests

### SUT Factory

```swift
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
```

### MARK: - 동기 탭 이벤트 (1개)

| # | Input | Expected Output |
|---|-------|-----------------|
| 1 | `didTapDelete` | `.showConfirmAlert` |

### MARK: - didConfirmDelete (6개)

| # | Provider | Mock 설정 | Expected Output |
|---|----------|-----------|-----------------|
| 2 | `"kakao"` | 기본값 | `.deletionSucceeded` |
| 3 | `"google"` | 기본값 | `.deletionSucceeded` |
| 4 | `"apple"` | 기본값 | `.deletionSucceeded` |
| 5 | `"email"` | 기본값 | `.deletionSucceeded` |
| 6 | `"kakao"` | `deleteSocialAccountResult = .failure(NetworkError.serverError)` | `.showErrorAlert(NetworkError.serverError.errorMessage)` |
| 7 | `"kakao"` | `deleteSocialAccountResult = .failure(URLError(.notConnectedToInternet))` | `.showErrorAlert("잠시 후 다시 시도해 주세요.")` |

> 케이스 2 (kakao): `unlinkKakao()` + `deleteSocialAccount(.kakao)` 순서로 두 메서드 호출. 두 호출 모두 기본값(성공)이므로 `.deletionSucceeded` emit.
>
> 케이스 6–7의 에러 주입: `deleteSocialAccountResult`를 실패로 설정. kakao provider는 `unlinkKakao()` 이후 `deleteSocialAccount(.kakao)`를 호출하므로, `unlinkKakaoResult`는 성공 유지, `deleteSocialAccountResult`만 실패로 설정.

---

## 비동기 테스트 패턴

`MyPageViewModelTests`와 동일:

```swift
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
```

---

## Task 분류

| Task | 내용 | 테스트 수 |
|------|------|----------|
| Task 1 | `MockSocialLoginService` 작성 | — |
| Task 2 | `SettingsViewModelTests` 동기 테스트 (케이스 1–4) | 4개 |
| Task 3 | `SettingsViewModelTests` didConfirmLogout 테스트 (케이스 5–9) | 5개 |
| Task 4 | `DeleteAccountViewModelTests` 동기 테스트 (케이스 1) | 1개 |
| Task 5 | `DeleteAccountViewModelTests` didConfirmDelete 테스트 (케이스 2–7) | 6개 |
