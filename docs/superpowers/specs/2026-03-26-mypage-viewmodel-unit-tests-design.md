# MyPage ViewModel Unit Tests — Design Spec

**Date:** 2026-03-26
**Scope:** MyPageViewModel 유닛 테스트 인프라 구축 및 테스트 케이스 작성

---

## 목표

MyPage 패키지에 유닛 테스트 인프라를 추가하고 `MyPageViewModel`의 모든 Input→Output 경로를 검증한다. 향후 스냅샷 테스트 추가를 고려해 Package.swift에 SnapshotTesting 의존성도 함께 세팅한다.

---

## 파일 구조

```
MyPage/
├── Package.swift                          (수정)
└── Tests/
    └── MyPageTests/
        ├── TestHelpers.swift
        ├── Mocks/
        │   └── MockMyPageService.swift
        └── UnitTests/
            └── MyPageViewModelTests.swift
```

---

## Package.swift 변경

기존 패키지 의존성에 `swift-snapshot-testing` 추가, `MyPageTests` 테스트 타겟 추가.
`Account`는 이미 package-level 의존성으로 선언되어 있으므로 `testTarget` 의존성에만 추가하면 된다.

```swift
// 추가할 package-level 의존성 (기존 의존성 뒤에 추가)
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),

// 추가할 testTarget (기존 MyPage target 뒤에 추가)
.testTarget(
    name: "MyPageTests",
    dependencies: [
        "MyPage",
        "Network",
        "Account",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
    ]
),
```

결과적으로 `Package.swift`의 `dependencies` 배열에는 총 6개 항목이 된다:
`Network`, `DesignSystem`, `QRIZUtils`, `Auth`, `Account`, `swift-snapshot-testing`

---

## TestHelpers.swift

비동기 테스트에서 Task 완료를 대기하기 위한 상수 정의.

```swift
import Foundation

let asyncSleepNanoseconds: UInt64 = 100_000_000  // 0.1초
```

---

## MockMyPageService

`MyPageService` 프로토콜을 구현하는 mock. 기존 코드베이스 패턴(`Result` 프로퍼티 + `@unchecked Sendable`)을 따른다.

```swift
final class MockMyPageService: MyPageService, @unchecked Sendable {

    var fetchVersionResult: Result<VersionResponse, Error> = .success(
        VersionResponse(
            code: 1,
            msg: "ok",
            data: VersionData(versionInfo: 1.0, updateInfo: "", date: "")
        )
    )

    var resetPlanResult: Result<DailyResetResponse, Error> = .success(
        DailyResetResponse(code: 1, msg: "초기화 완료!")
    )

    var deleteAccountResult: Result<DeleteAccountResponse, Error> = .success(
        DeleteAccountResponse(code: 0, msg: "ok")
    )

    var deleteSocialAccountResult: Result<SocialWithdrawResponse, Error> = .success(
        SocialWithdrawResponse(code: 0, msg: "ok")
    )

    func fetchVersion() async throws -> VersionResponse { try fetchVersionResult.get() }
    func resetPlan() async throws -> DailyResetResponse { try resetPlanResult.get() }
    func deleteAccount() async throws -> DeleteAccountResponse { try deleteAccountResult.get() }
    func deleteSocialAccount(socialLoginType: SocialLogin) async throws -> SocialWithdrawResponse {
        try deleteSocialAccountResult.get()
    }
}
```

---

## 테스트 케이스 (11개)

테스트 프레임워크: Swift Testing (`@Suite`, `@Test`, `#expect`)
스타일: `@MainActor`, `.serialized`, 한국어 테스트 이름

### MARK: - viewDidLoad (fetchVersion 비동기)

| # | 시나리오 | 예상 Output |
|---|----------|-------------|
| 1 | fetchVersion 성공 | `.setupView(userName: "테스트", version: "1.0")` |
| 2 | fetchVersion NetworkError 실패 | `.setupView(userName: "테스트", version: "0.0.0")` |
| 3 | fetchVersion 일반 Error 실패 | `.setupView(userName: "테스트", version: "0.0.0")` |

> fallback: 테스트 환경에서 `Bundle.main.infoDictionary?["CFBundleShortVersionString"]`은 `nil`이므로 `"0.0.0"` 반환.
> `versionInfo: 1.0` (Float) → `"\(1.0)"` → `"1.0"` (Swift 기본 Float 문자열 변환).

### MARK: - 동기 탭 이벤트

| # | Input | 예상 Output |
|---|-------|-------------|
| 4 | `didTapProfile` | `.navigateToSettingsView` |
| 5 | `didTapResetPlan` | `.showResetAlert` |
| 6 | `didTapRegisterExam` | `.showExamSchedule` |
| 7 | `didTapTermsOfService` | `.showTermsDetail(termItem:)` |
| 8 | `didTapPrivacyPolicy` | `.showTermsDetail(termItem:)` |

**케이스 7, 8 assertion 패턴:**

`Output`은 `Equatable`이 아니므로 `guard case` 패턴 매칭으로 검증.

```swift
// 케이스 7
guard case .showTermsDetail(let termItem) = received.first else {
    Issue.record("Expected .showTermsDetail")
    return
}
#expect(termItem.title == "서비스 이용약관")
#expect(termItem.pdfName == "TermsOfService")

// 케이스 8
#expect(termItem.title == "개인정보 처리방침")
#expect(termItem.pdfName == "PrivacyPolicy")
```

### MARK: - didConfirmResetPlan (performReset 비동기)

| # | 시나리오 | mock 설정 | 예상 Output |
|---|----------|-----------|-------------|
| 9 | resetPlan 성공 | 기본값 | `.resetSucceeded(message: "초기화 완료!")` |
| 10 | resetPlan NetworkError 실패 | `resetPlanResult = .failure(NetworkError.serverError)` | `.showErrorAlert(title: "초기화할 수 없습니다.", description: "서버 에러가 발생했습니다. 잠시 후 다시 시도해 주세요.")` |
| 11 | resetPlan 일반 Error 실패 | `resetPlanResult = .failure(URLError(.notConnectedToInternet))` | `.showErrorAlert(title: "초기화할 수 없습니다.", description: "잠시 후 다시 시도해주세요.")` |

> `NetworkError.serverError.errorMessage` == `"서버 에러가 발생했습니다. 잠시 후 다시 시도해 주세요."` (NetworkError.swift 참고)

---

## SUT Factory

```swift
private func makeSUT(
    userName: String = "테스트",
    service: MockMyPageService = .init()
) -> MyPageViewModel {
    MyPageViewModel(userName: userName, myPageService: service)
}
```

---

## 비동기 테스트 패턴

`fetchVersion`과 `performReset`은 내부에서 `Task { }` (fire-and-forget)으로 실행되므로 `Task.sleep`으로 대기.

```swift
let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
var received: [MyPageViewModel.Output] = []
var cancellables = Set<AnyCancellable>()

viewModel.transform(input: inputSubject.eraseToAnyPublisher())
    .sink { received.append($0) }
    .store(in: &cancellables)

inputSubject.send(.viewDidLoad)
try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

#expect(received.count == 1)
guard case .setupView(let userName, let version) = received[0] else {
    Issue.record("Expected .setupView")
    return
}
#expect(userName == "테스트")
#expect(version == "1.0")
```
