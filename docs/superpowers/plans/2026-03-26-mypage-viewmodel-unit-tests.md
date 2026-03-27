# MyPage ViewModel Unit Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MyPage 패키지에 유닛 테스트 인프라를 구축하고 `MyPageViewModel`의 11개 Input→Output 경로를 모두 검증하는 테스트를 작성한다.

**Architecture:** Package.swift에 테스트 타겟과 SnapshotTesting 의존성을 추가한 뒤, `MockMyPageService` + `TestHelpers`를 갖춘 인프라 파일을 작성하고, 마지막으로 `MyPageViewModelTests`에 11개 테스트 케이스를 작성한다. 기존 코드베이스(MistakeNote 모듈)의 테스트 패턴을 그대로 따른다.

**Tech Stack:** Swift Testing (`@Suite`/`@Test`/`#expect`), Combine (`PassthroughSubject`, `sink`), swift-snapshot-testing (인프라 세팅만, 이번 플랜에서 스냅샷 테스트 작성은 없음)

---

## 파일 목록

| 작업 | 파일 |
|------|------|
| 수정 | `MyPage/Package.swift` |
| 생성 | `MyPage/Tests/MyPageTests/TestHelpers.swift` |
| 생성 | `MyPage/Tests/MyPageTests/Mocks/MockMyPageService.swift` |
| 생성 | `MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift` |

**참고 파일:**
- `MyPage/Sources/MyPage/MyPage/ViewModel/MyPageViewModel.swift` — 테스트 대상
- `Network/Sources/Network/Service/MyPage/MyPageService.swift` — mock 대상 프로토콜
- `Network/Sources/Network/Base/NetworkError.swift` — 에러 케이스
- `Network/Sources/Network/DTOs/MyPage/VersionRequest.swift` — VersionResponse, VersionData
- `Network/Sources/Network/DTOs/Daily/DailyResetRequest.swift` — DailyResetResponse
- `MistakeNote/Tests/MistakeNoteTests/Mocks/MockMistakeNoteService.swift` — 패턴 참고
- `MistakeNote/Tests/MistakeNoteTests/UnitTests/MistakeNoteListViewModelTests.swift` — 패턴 참고

---

## Task 1: Package.swift 수정

**Files:**
- Modify: `MyPage/Package.swift`

- [ ] **Step 1: Package.swift에 swift-snapshot-testing 의존성과 테스트 타겟 추가**

`MyPage/Package.swift`를 아래 내용으로 교체:

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyPage",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MyPage", targets: ["MyPage"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../Auth"),
        .package(path: "../Account"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "MyPage",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "Auth",
                "Account",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "MyPageTests",
            dependencies: [
                "MyPage",
                "Network",
                "Account",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
```

- [ ] **Step 2: Xcode에서 패키지 의존성 해석 확인**

Xcode에서 `File → Packages → Resolve Package Versions` 실행 또는:

```bash
cd /Users/hun/iOS/MyPage && swift package resolve
```

Expected: `swift-snapshot-testing` 패키지가 다운로드되고 에러 없음.

- [ ] **Step 3: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Package.swift
git commit -m "feat: MyPage 테스트 타겟 추가 — SnapshotTesting 의존성 포함"
```

---

## Task 2: TestHelpers.swift 작성

**Files:**
- Create: `MyPage/Tests/MyPageTests/TestHelpers.swift`

- [ ] **Step 1: 파일 생성**

```swift
import Foundation

let asyncSleepNanoseconds: UInt64 = 100_000_000  // 0.1초
```

- [ ] **Step 2: 빌드 확인**

Xcode에서 `MyPageTests` 타겟을 빌드하거나:

```bash
cd /Users/hun/iOS/MyPage && swift build --target MyPage
```

Expected: 컴파일 에러 없음.

- [ ] **Step 3: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/TestHelpers.swift
git commit -m "feat: MyPageTests TestHelpers 추가"
```

---

## Task 3: MockMyPageService 작성

**Files:**
- Create: `MyPage/Tests/MyPageTests/Mocks/MockMyPageService.swift`

- [ ] **Step 1: 파일 생성**

```swift
import Foundation
import Network
import QRIZUtils

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

    func fetchVersion() async throws -> VersionResponse {
        try fetchVersionResult.get()
    }

    func resetPlan() async throws -> DailyResetResponse {
        try resetPlanResult.get()
    }

    func deleteAccount() async throws -> DeleteAccountResponse {
        try deleteAccountResult.get()
    }

    func deleteSocialAccount(socialLoginType: SocialLogin) async throws -> SocialWithdrawResponse {
        try deleteSocialAccountResult.get()
    }
}
```

- [ ] **Step 2: 빌드 확인**

Xcode에서 `MyPageTests` 타겟 빌드 또는:

```bash
cd /Users/hun/iOS/MyPage && swift build
```

Expected: 컴파일 에러 없음. `MyPageService` 프로토콜의 4개 메서드 모두 구현 확인.

- [ ] **Step 3: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/Mocks/MockMyPageService.swift
git commit -m "feat: MockMyPageService 추가"
```

---

## Task 4: viewDidLoad 테스트 작성 (케이스 1–3)

**Files:**
- Create: `MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift`

`fetchVersion`은 내부에서 `Task { }` (fire-and-forget)으로 실행되므로 `Task.sleep`으로 완료를 대기한다.

- [ ] **Step 1: 테스트 파일 뼈대 + viewDidLoad 테스트 3개 작성**

```swift
import Testing
import Combine
@testable import MyPage
import Network

@MainActor
@Suite("MyPageViewModel 테스트", .serialized)
struct MyPageViewModelTests {

    private func makeSUT(
        userName: String = "테스트",
        service: MockMyPageService = .init()
    ) -> MyPageViewModel {
        MyPageViewModel(userName: userName, myPageService: service)
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad → fetchVersion 성공 → setupView emit")
    func viewDidLoad_fetchVersionSuccess_emitsSetupView() async throws {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .setupView(let userName, let version) = received[0] else {
            Issue.record("Expected .setupView, got \(received)")
            return
        }
        #expect(userName == "테스트")
        #expect(version == "1.0")
    }

    @Test("viewDidLoad → fetchVersion NetworkError 실패 → setupView(fallback) emit")
    func viewDidLoad_fetchVersionNetworkError_emitsSetupViewWithFallback() async throws {
        let service = MockMyPageService()
        service.fetchVersionResult = .failure(NetworkError.serverError)
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .setupView(let userName, let version) = received[0] else {
            Issue.record("Expected .setupView, got \(received)")
            return
        }
        #expect(userName == "테스트")
        #expect(version == "0.0.0")
    }

    @Test("viewDidLoad → fetchVersion 일반 Error 실패 → setupView(fallback) emit")
    func viewDidLoad_fetchVersionGenericError_emitsSetupViewWithFallback() async throws {
        let service = MockMyPageService()
        service.fetchVersionResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .setupView(let userName, let version) = received[0] else {
            Issue.record("Expected .setupView, got \(received)")
            return
        }
        #expect(userName == "테스트")
        #expect(version == "0.0.0")
    }
}
```

- [ ] **Step 2: 테스트 실행 — viewDidLoad 3개 통과 확인**

Xcode에서 `MyPageTests` 스킴으로 테스트 실행 (⌘U) 또는:

```bash
xcodebuild test -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/MyPageViewModelTests
```

Expected: 3개 테스트 모두 PASS.

- [ ] **Step 3: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift
git commit -m "test: MyPageViewModel viewDidLoad 테스트 추가 (케이스 1-3)"
```

---

## Task 5: 동기 탭 이벤트 테스트 작성 (케이스 4–8)

**Files:**
- Modify: `MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift`

동기 이벤트는 `Task.sleep` 없이 `send` 직후 바로 assertion.

- [ ] **Step 1: `MyPageViewModelTests` struct 안에 5개 테스트 추가**

기존 `viewDidLoad` 테스트 아래에 다음 섹션 추가:

```swift
    // MARK: - 동기 탭 이벤트

    @Test("didTapProfile → navigateToSettingsView emit")
    func didTapProfile_emitsNavigateToSettingsView() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapProfile)

        #expect(received.count == 1)
        guard case .navigateToSettingsView = received[0] else {
            Issue.record("Expected .navigateToSettingsView, got \(received)")
            return
        }
    }

    @Test("didTapResetPlan → showResetAlert emit")
    func didTapResetPlan_emitsShowResetAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapResetPlan)

        #expect(received.count == 1)
        guard case .showResetAlert = received[0] else {
            Issue.record("Expected .showResetAlert, got \(received)")
            return
        }
    }

    @Test("didTapRegisterExam → showExamSchedule emit")
    func didTapRegisterExam_emitsShowExamSchedule() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapRegisterExam)

        #expect(received.count == 1)
        guard case .showExamSchedule = received[0] else {
            Issue.record("Expected .showExamSchedule, got \(received)")
            return
        }
    }

    @Test("didTapTermsOfService → showTermsDetail(서비스 이용약관) emit")
    func didTapTermsOfService_emitsShowTermsDetailWithTermsOfService() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapTermsOfService)

        #expect(received.count == 1)
        guard case .showTermsDetail(let termItem) = received[0] else {
            Issue.record("Expected .showTermsDetail, got \(received)")
            return
        }
        #expect(termItem.title == "서비스 이용약관")
        #expect(termItem.pdfName == "TermsOfService")
    }

    @Test("didTapPrivacyPolicy → showTermsDetail(개인정보 처리방침) emit")
    func didTapPrivacyPolicy_emitsShowTermsDetailWithPrivacyPolicy() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapPrivacyPolicy)

        #expect(received.count == 1)
        guard case .showTermsDetail(let termItem) = received[0] else {
            Issue.record("Expected .showTermsDetail, got \(received)")
            return
        }
        #expect(termItem.title == "개인정보 처리방침")
        #expect(termItem.pdfName == "PrivacyPolicy")
    }
```

- [ ] **Step 2: 테스트 실행 — 동기 탭 5개 통과 확인**

```bash
xcodebuild test -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/MyPageViewModelTests
```

Expected: 8개 테스트 모두 PASS (viewDidLoad 3개 + 동기 탭 5개).

- [ ] **Step 3: 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift
git commit -m "test: MyPageViewModel 동기 탭 이벤트 테스트 추가 (케이스 4-8)"
```

---

## Task 6: didConfirmResetPlan 테스트 작성 (케이스 9–11)

**Files:**
- Modify: `MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift`

- [ ] **Step 1: `MyPageViewModelTests` struct 안에 3개 테스트 추가**

기존 동기 탭 테스트 아래에 다음 섹션 추가:

```swift
    // MARK: - didConfirmResetPlan

    @Test("didConfirmResetPlan → resetPlan 성공 → resetSucceeded emit")
    func didConfirmResetPlan_resetPlanSuccess_emitsResetSucceeded() async throws {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .resetSucceeded(let message) = received[0] else {
            Issue.record("Expected .resetSucceeded, got \(received)")
            return
        }
        #expect(message == "초기화 완료!")
    }

    @Test("didConfirmResetPlan → resetPlan NetworkError 실패 → showErrorAlert emit")
    func didConfirmResetPlan_resetPlanNetworkError_emitsShowErrorAlert() async throws {
        let service = MockMyPageService()
        service.resetPlanResult = .failure(NetworkError.serverError)
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .showErrorAlert(let title, let description) = received[0] else {
            Issue.record("Expected .showErrorAlert, got \(received)")
            return
        }
        #expect(title == "초기화할 수 없습니다.")
        #expect(description == "서버 에러가 발생했습니다. 잠시 후 다시 시도해 주세요.")
    }

    @Test("didConfirmResetPlan → resetPlan 일반 Error 실패 → showErrorAlert emit")
    func didConfirmResetPlan_resetPlanGenericError_emitsShowErrorAlert() async throws {
        let service = MockMyPageService()
        service.resetPlanResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .showErrorAlert(let title, let description) = received[0] else {
            Issue.record("Expected .showErrorAlert, got \(received)")
            return
        }
        #expect(title == "초기화할 수 없습니다.")
        #expect(description == "잠시 후 다시 시도해주세요.")
    }
```

- [ ] **Step 2: 전체 테스트 실행 — 11개 모두 통과 확인**

```bash
xcodebuild test -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/MyPageViewModelTests
```

Expected: 11개 테스트 모두 PASS.

- [ ] **Step 3: 최종 커밋**

```bash
cd /Users/hun/iOS
git add MyPage/Tests/MyPageTests/UnitTests/MyPageViewModelTests.swift
git commit -m "test: MyPageViewModel didConfirmResetPlan 테스트 추가 (케이스 9-11)"
```
