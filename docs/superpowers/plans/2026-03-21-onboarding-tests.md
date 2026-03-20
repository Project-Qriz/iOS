# Onboarding 패키지 테스트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Onboarding SPM 패키지에 유닛 테스트(swift-testing)와 스냅샷 테스트(XCTest + swift-snapshot-testing)를 추가한다.

**Architecture:** 기존 MistakeNote 패키지의 테스트 패턴을 따르되, `@MainActor` Mock, Combine Output 수집 헬퍼, Parameterized tests 세 가지를 개선해 적용한다. 유닛 테스트는 swift-testing `@Suite`/`@Test`/`#expect`, 스냅샷 테스트는 XCTest + SnapshotTesting을 사용한다.

**Tech Stack:** Swift Testing, XCTest, Combine, SwiftUI, UIKit, swift-snapshot-testing 1.18.9

---

## 파일 맵

| 파일 | 역할 |
|------|------|
| `Onboarding/Package.swift` | testTarget + swift-snapshot-testing 의존성 추가 |
| `Tests/OnboardingTests/TestHelpers.swift` | fixtures, asyncSleepNanoseconds, collectOutputs 헬퍼 |
| `Tests/OnboardingTests/SnapshotTestHelpers.swift` | OnboardingSnapshotTestCase 기반 클래스 |
| `Tests/OnboardingTests/Mocks/MockOnboardingService.swift` | OnboardingService Mock |
| `Tests/OnboardingTests/Mocks/MockUserInfoService.swift` | UserInfoService Mock |
| `Tests/OnboardingTests/UnitTests/BeginOnboardingViewModelTests.swift` | didTapButton 유닛 테스트 |
| `Tests/OnboardingTests/UnitTests/BeginPreviewTestViewModelTests.swift` | didTapButton 유닛 테스트 |
| `Tests/OnboardingTests/UnitTests/CheckConceptViewModelTests.swift` | 선택 로직, didTapDone 유닛 테스트 |
| `Tests/OnboardingTests/UnitTests/GreetingViewModelTests.swift` | nickname, 타이머 유닛 테스트 |
| `Tests/OnboardingTests/UnitTests/PreviewTestViewModelTests.swift` | Input/Output Combine 유닛 테스트 |
| `Tests/OnboardingTests/UnitTests/PreviewResultViewModelTests.swift` | 데이터 매핑, navigate 유닛 테스트 |
| `Tests/OnboardingTests/SnapshotTests/BeginOnboardingSnapshotTests.swift` | BeginOnboardingView 스냅샷 |
| `Tests/OnboardingTests/SnapshotTests/BeginPreviewTestSnapshotTests.swift` | BeginPreviewTestView 스냅샷 |
| `Tests/OnboardingTests/SnapshotTests/CheckConceptSnapshotTests.swift` | CheckConceptView 스냅샷 (3 상태) |
| `Tests/OnboardingTests/SnapshotTests/GreetingSnapshotTests.swift` | GreetingView 스냅샷 |
| `Tests/OnboardingTests/SnapshotTests/PreviewTestSnapshotTests.swift` | PreviewTestView(UIKit) 스냅샷 |
| `Tests/OnboardingTests/SnapshotTests/PreviewResultSnapshotTests.swift` | PreviewResultView 스냅샷 |

---

## Task 1: Package.swift 설정

**Files:**
- Modify: `Onboarding/Package.swift`

- [ ] **Step 1: Package.swift에 swift-snapshot-testing 의존성 및 testTarget 추가**

`Onboarding/Package.swift`를 다음과 같이 수정한다:

```swift
// swift-tools-version: 6.0

import PackageDescription

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
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: [
                "Onboarding",
                "Network",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
```

- [ ] **Step 2: Xcode에서 패키지 의존성 해결 확인**

Xcode에서 `QRIZ.xcodeproj`를 열고 File → Packages → Resolve Package Versions 실행. 빌드 오류 없음을 확인한다.

- [ ] **Step 3: 커밋**

```bash
git add Onboarding/Package.swift
git commit -m "config: OnboardingTests 테스트 타겟 및 swift-snapshot-testing 의존성 추가"
```

---

## Task 2: 공통 헬퍼 및 Mock 파일 생성

**Files:**
- Create: `Onboarding/Tests/OnboardingTests/TestHelpers.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTestHelpers.swift`
- Create: `Onboarding/Tests/OnboardingTests/Mocks/MockOnboardingService.swift`
- Create: `Onboarding/Tests/OnboardingTests/Mocks/MockUserInfoService.swift`

- [ ] **Step 1: TestHelpers.swift 생성**

```swift
import Foundation
import Combine
import Network
import QRIZUtils
@testable import Onboarding

let asyncSleepNanoseconds: UInt64 = 100_000_000

// MARK: - PreviewTestListResponse Fixtures

extension PreviewTestListResponse {
    static func stub(questionCount: Int = 3, totalTimeLimit: Int = 600) -> Self {
        PreviewTestListResponse(
            code: 1,
            msg: "ok",
            data: .init(
                questions: (1...questionCount).map { .make(questionId: $0) },
                totalTimeLimit: totalTimeLimit
            )
        )
    }
}

extension PreviewTestListQuestion {
    // options 기본 4개 — optionTapped 테스트에서 options[idx-1] 접근 시 크래시 방지
    static func make(
        questionId: Int = 1,
        skillId: Int = 1,
        category: Int = 1,
        question: String = "테스트 문제",
        description: String? = nil,
        options: [PreviewTestListOption] = [
            .init(id: 1, content: "선택지1"),
            .init(id: 2, content: "선택지2"),
            .init(id: 3, content: "선택지3"),
            .init(id: 4, content: "선택지4"),
        ],
        timeLimit: Int = 60,
        difficulty: Int = 1
    ) -> Self {
        PreviewTestListQuestion(
            questionId: questionId,
            skillId: skillId,
            category: category,
            question: question,
            description: description,
            options: options,
            timeLimit: timeLimit,
            difficulty: difficulty
        )
    }
}

// MARK: - AnalyzePreviewResponse Fixtures

extension AnalyzePreviewResponse {
    // totalScore = part1Score + part2Score로 ScoreBreakdown 생성
    static func stub(
        estimatedScore: Double = 72.0,
        totalScore: Int = 72,
        part1Score: Int = 40,
        part2Score: Int = 32,
        topConceptsToImprove: [String] = ["SQL 기본", "SELECT문"],
        totalQuestions: Int = 10,
        weakAreas: [WeakArea] = []
    ) -> Self {
        AnalyzePreviewResponse(
            code: 1,
            msg: "ok",
            data: .init(
                estimatedScore: estimatedScore,
                scoreBreakdown: .init(
                    totalScore: totalScore,
                    part1Score: part1Score,
                    part2Score: part2Score
                ),
                weakAreaAnalysis: .init(
                    totalQuestions: totalQuestions,
                    weakAreas: weakAreas
                ),
                topConceptsToImprove: topConceptsToImprove
            )
        )
    }
}

// MARK: - PreviewSubmitResponse Fixtures

extension PreviewSubmitResponse {
    static func stub() -> Self {
        PreviewSubmitResponse(code: 1, msg: "ok", data: nil)
    }
}

// MARK: - UserInfoResponse Fixtures

extension UserInfoResponse {
    // previewTestStatus 노출 — fetchUserInfo 후 UserInfoManager 상태 제어
    static func stub(
        name: String = "테스트유저",
        previewTestStatus: PreviewTestStatus = .previewCompleted
    ) -> Self {
        UserInfoResponse(
            code: 1,
            msg: "ok",
            data: UserInfo(
                name: name,
                userId: "testUser123",
                email: "test@example.com",
                previewTestStatus: previewTestStatus,
                provider: nil
            )
        )
    }
}

// MARK: - Combine Output 수집 헬퍼

/// PreviewTestViewModel Input/Output 패턴 테스트용.
/// 반드시 transform(input:)을 호출한 후 반환된 publisher를 넘길 것.
@MainActor
func collectOutputs(
    from publisher: AnyPublisher<PreviewTestViewModel.Output, Never>,
    after action: () -> Void
) async -> [PreviewTestViewModel.Output] {
    var outputs: [PreviewTestViewModel.Output] = []
    let cancellable = publisher.sink { outputs.append($0) }
    action()
    try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
    cancellable.cancel()
    return outputs
}
```

- [ ] **Step 2: SnapshotTestHelpers.swift 생성**

```swift
import UIKit
import XCTest
@testable import Onboarding

@MainActor
class OnboardingSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}
```

- [ ] **Step 3: MockOnboardingService.swift 생성**

```swift
import Foundation
import Network
import QRIZUtils
@testable import Onboarding

// @MainActor: OnboardingService는 Sendable 요구 없음. @MainActor로 mutable 프로퍼티 안전하게 접근.
@MainActor
final class MockOnboardingService: OnboardingService {
    var sendSurveyResult: Result<Void, Error> = .success(())
    var getPreviewTestListResult: Result<PreviewTestListResponse, Error> = .success(.stub())
    var submitPreviewResult: Result<PreviewSubmitResponse, Error> = .success(.stub())
    var analyzePreviewResult: Result<AnalyzePreviewResponse, Error> = .success(.stub())

    func sendSurvey(keyConcepts: [String]) async throws {
        if case .failure(let error) = sendSurveyResult { throw error }
    }

    func getPreviewTestList() async throws -> PreviewTestListResponse {
        try getPreviewTestListResult.get()
    }

    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse {
        try submitPreviewResult.get()
    }

    func analyzePreview() async throws -> AnalyzePreviewResponse {
        try analyzePreviewResult.get()
    }
}
```

- [ ] **Step 4: MockUserInfoService.swift 생성**

```swift
import Foundation
import Network
import QRIZUtils

// @MainActor: UserInfoService는 Sendable을 요구하며, Swift 5.7+에서 @MainActor 클래스는
// 단일 액터에 격리되어 암묵적으로 Sendable을 만족한다.
@MainActor
final class MockUserInfoService: UserInfoService {
    var getUserInfoResult: Result<UserInfoResponse, Error> = .success(.stub())

    func getUserInfo() async throws -> UserInfoResponse {
        try getUserInfoResult.get()
    }
}
```

- [ ] **Step 5: 빌드 확인 (Xcode에서 Cmd+B)**

빌드 오류 없음을 확인한다.

- [ ] **Step 6: 커밋**

```bash
git add Onboarding/Tests/
git commit -m "test: Onboarding 테스트 공통 헬퍼 및 Mock 서비스 추가"
```

---

## Task 3: BeginOnboarding & BeginPreviewTest 테스트

**Files:**
- Create: `Onboarding/Tests/OnboardingTests/UnitTests/BeginOnboardingViewModelTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/UnitTests/BeginPreviewTestViewModelTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTests/BeginOnboardingSnapshotTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTests/BeginPreviewTestSnapshotTests.swift`

- [ ] **Step 1: BeginOnboardingViewModelTests.swift 작성**

```swift
import Testing
@testable import Onboarding

@MainActor
@Suite("BeginOnboardingViewModel 테스트")
struct BeginOnboardingViewModelTests {

    @Test("didTapButton 호출 시 onNavigate 클로저 실행됨")
    func didTapButton_callsOnNavigate() {
        var navigateCalled = false
        let sut = BeginOnboardingViewModel(onNavigate: { navigateCalled = true })

        sut.didTapButton()

        #expect(navigateCalled)
    }
}
```

- [ ] **Step 2: BeginPreviewTestViewModelTests.swift 작성**

```swift
import Testing
@testable import Onboarding

@MainActor
@Suite("BeginPreviewTestViewModel 테스트")
struct BeginPreviewTestViewModelTests {

    @Test("didTapButton 호출 시 onNavigate 클로저 실행됨")
    func didTapButton_callsOnNavigate() {
        var navigateCalled = false
        let sut = BeginPreviewTestViewModel(onNavigate: { navigateCalled = true })

        sut.didTapButton()

        #expect(navigateCalled)
    }
}
```

- [ ] **Step 3: BeginOnboardingSnapshotTests.swift 작성**

```swift
import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class BeginOnboardingSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = BeginOnboardingViewModel(onNavigate: {})
        let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 4: BeginPreviewTestSnapshotTests.swift 작성**

```swift
import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class BeginPreviewTestSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = BeginPreviewTestViewModel(onNavigate: {})
        let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 5: 유닛 테스트 실행 (Cmd+U)**

`BeginOnboardingViewModelTests`, `BeginPreviewTestViewModelTests` 모두 통과 확인.

- [ ] **Step 6: 스냅샷 테스트 첫 실행 (레퍼런스 이미지 생성)**

Xcode에서 스냅샷 테스트 실행. 처음 실행 시 `__Snapshots__` 폴더에 레퍼런스 이미지가 생성되며 테스트가 실패한다. 두 번째 실행에서 통과를 확인한다.

- [ ] **Step 7: 커밋**

```bash
git add Onboarding/Tests/
git commit -m "test: BeginOnboarding, BeginPreviewTest 유닛 및 스냅샷 테스트 추가"
```

---

## Task 4: CheckConcept 테스트

**Files:**
- Create: `Onboarding/Tests/OnboardingTests/UnitTests/CheckConceptViewModelTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTests/CheckConceptSnapshotTests.swift`

- [ ] **Step 1: CheckConceptViewModelTests.swift 작성**

```swift
import Testing
import QRIZUtils
@testable import Onboarding

@MainActor
@Suite("CheckConceptViewModel 테스트", .serialized)
struct CheckConceptViewModelTests {

    // 싱글톤 오염 방지: 각 테스트 시작 전 UserInfoManager 초기화
    private func makeSUT(
        service: MockOnboardingService = .init(),
        onNavigate: @escaping (CheckConceptNavigation) -> Void = { _ in }
    ) -> CheckConceptViewModel {
        UserInfoManager.shared.update(
            name: "",
            userId: "",
            email: "",
            previewTestStatus: .notStarted,
            provider: nil
        )
        return CheckConceptViewModel(onboardingService: service, onNavigate: onNavigate)
    }

    // MARK: - 초기 상태

    @Test("초기 상태: selectedSet 비어있고 isDoneButtonEnabled false")
    func initialState() {
        let sut = makeSUT()
        #expect(sut.selectedSet.isEmpty)
        #expect(!sut.isDoneButtonEnabled)
    }

    // MARK: - didTapConcept

    @Test("didTapConcept: 선택/해제 토글", arguments: [0, 5, 15, 29])
    func didTapConcept_togglesSelection(index: Int) {
        let sut = makeSUT()

        sut.didTapConcept(at: index)
        #expect(sut.selectedSet.contains(index))

        sut.didTapConcept(at: index)
        #expect(!sut.selectedSet.contains(index))
    }

    // MARK: - didTapAll

    @Test("didTapAll: 전체 30개 선택")
    func didTapAll_selectsAll() {
        let sut = makeSUT()
        sut.didTapAll()
        #expect(sut.selectedSet.count == 30)
    }

    @Test("didTapAll: 전체 선택 후 재탭 시 전체 해제")
    func didTapAll_whenAllSelected_deselectsAll() {
        let sut = makeSUT()
        sut.didTapAll()
        sut.didTapAll()
        #expect(sut.selectedSet.isEmpty)
    }

    // MARK: - didTapNone

    @Test("didTapNone: selectedSet 비워지고 isDoneButtonEnabled true")
    func didTapNone_clearsSetAndEnablesButton() {
        let sut = makeSUT()
        sut.didTapConcept(at: 0)

        sut.didTapNone()

        #expect(sut.selectedSet.isEmpty)
        #expect(sut.isDoneButtonEnabled)
    }

    @Test("didTapNone 후 didTapConcept: isDoneButtonEnabled 정상 갱신")
    func afterDidTapNone_didTapConcept_updatesDoneButton() {
        let sut = makeSUT()
        sut.didTapNone()
        // isDoneButtonEnabled = true (none 선택 상태)

        sut.didTapConcept(at: 0) // 개념 1개 선택 → true 유지
        #expect(sut.isDoneButtonEnabled)

        sut.didTapConcept(at: 0) // 개념 해제 → updateDoneButton() → isEmpty이면 false
        #expect(!sut.isDoneButtonEnabled)
    }

    // MARK: - isDoneButtonEnabled

    @Test("isDoneButtonEnabled: 선택 없을 때 false")
    func isDoneButtonEnabled_false_whenNothingSelected() {
        let sut = makeSUT()
        #expect(!sut.isDoneButtonEnabled)
    }

    @Test("isDoneButtonEnabled: 1개 이상 선택 시 true")
    func isDoneButtonEnabled_true_whenAtLeastOneSelected() {
        let sut = makeSUT()
        sut.didTapConcept(at: 0)
        #expect(sut.isDoneButtonEnabled)
    }

    // MARK: - didTapDone 네비게이션

    @Test("didTapNone 후 didTapDone → .greeting으로 navigate")
    func didTapDone_afterTapNone_navigatesToGreeting() async {
        var destination: CheckConceptNavigation?
        let service = MockOnboardingService()
        let sut = makeSUT(service: service, onNavigate: { destination = $0 })

        sut.didTapNone()   // isDoneButtonEnabled = true, selectedSet = empty
        sut.didTapDone()

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(destination == .greeting)
    }

    @Test("selectedSet 있을 때 didTapDone → .previewTest로 navigate")
    func didTapDone_withSelection_navigatesToPreviewTest() async {
        var destination: CheckConceptNavigation?
        let service = MockOnboardingService()
        let sut = makeSUT(service: service, onNavigate: { destination = $0 })

        sut.didTapConcept(at: 0)
        sut.didTapDone()

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(destination == .previewTest)
    }

    // MARK: - didTapDone 에러 처리

    @Test("didTapDone: sendSurvey 실패 시 errorMessage 세팅")
    func didTapDone_onServiceFailure_setsErrorMessage() async {
        let service = MockOnboardingService()
        service.sendSurveyResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)

        sut.didTapConcept(at: 0)
        sut.didTapDone()

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.errorMessage != nil)
    }

    @Test("didTapDone: isLoading 중 중복 탭 무시")
    func didTapDone_whileLoading_isIgnored() async {
        var navigateCount = 0
        let service = MockOnboardingService()
        let sut = makeSUT(service: service, onNavigate: { _ in navigateCount += 1 })

        sut.didTapConcept(at: 0)
        sut.didTapDone()
        sut.didTapDone() // isLoading = true 상태에서 두 번째 탭

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(navigateCount == 1)
    }
}
```

- [ ] **Step 2: CheckConceptSnapshotTests.swift 작성**

```swift
import XCTest
import SnapshotTesting
import SwiftUI
import Network
@testable import Onboarding

@MainActor
class CheckConceptSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in }
        )
        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }

    func testWithSomeSelected() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in }
        )
        vm.didTapConcept(at: 0)
        vm.didTapConcept(at: 5)
        vm.didTapConcept(at: 10)

        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }

    func testAllSelected() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in }
        )
        vm.didTapAll()

        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 3: 유닛 테스트 실행 (Cmd+U)**

`CheckConceptViewModelTests` 전체 통과 확인.

- [ ] **Step 4: 스냅샷 테스트 실행 (레퍼런스 생성 후 재실행)**

첫 실행 → 레퍼런스 이미지 생성 (실패). 두 번째 실행 → 통과 확인.

- [ ] **Step 5: 커밋**

```bash
git add Onboarding/Tests/
git commit -m "test: CheckConcept 유닛 및 스냅샷 테스트 추가"
```

---

## Task 5: Greeting 테스트

**Files:**
- Create: `Onboarding/Tests/OnboardingTests/UnitTests/GreetingViewModelTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTests/GreetingSnapshotTests.swift`

- [ ] **Step 1: GreetingViewModelTests.swift 작성**

> Timer는 RunLoop 기반이므로 `Task.sleep`만으로는 firing되지 않는다. `RunLoop.main.run(until:)`으로 대기한다. 이 테스트는 실제 2.5초가 소요된다.

```swift
import Testing
import QRIZUtils
import Network
@testable import Onboarding

@MainActor
@Suite("GreetingViewModel 테스트", .serialized)
struct GreetingViewModelTests {

    private func resetUserInfo(name: String = "") {
        UserInfoManager.shared.update(
            name: name,
            userId: "",
            email: "",
            previewTestStatus: .notStarted,
            provider: nil
        )
    }

    private func makeSUT(
        service: MockUserInfoService = .init(),
        onNavigate: @escaping () -> Void = {}
    ) -> GreetingViewModel {
        GreetingViewModel(userInfoService: service, onNavigate: onNavigate)
    }

    // MARK: - nickname 즉시 세팅

    @Test("onAppear: UserInfoManager.shared.name을 nickname으로 즉시 세팅")
    func onAppear_setsNicknameFromUserInfoManager() {
        resetUserInfo(name: "홍길동")
        let sut = makeSUT()

        sut.onAppear()

        #expect(sut.nickname == "홍길동")
    }

    // MARK: - fetchUserInfo 성공 시 nickname 업데이트

    @Test("onAppear: fetchUserInfo 성공 시 nickname 업데이트")
    func onAppear_onFetchSuccess_updatesNickname() async {
        resetUserInfo(name: "초기이름")
        let service = MockUserInfoService()
        service.getUserInfoResult = .success(.stub(name: "서버이름"))
        let sut = makeSUT(service: service)

        sut.onAppear()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.nickname == "서버이름")
    }

    // MARK: - 타이머 (실제 2.5초 대기)

    @Test("onAppear: 2.5초 후 onNavigate 호출")
    func onAppear_after2_5Seconds_callsOnNavigate() {
        resetUserInfo()
        var navigateCalled = false
        let sut = makeSUT(onNavigate: { navigateCalled = true })

        sut.onAppear()

        // Timer는 RunLoop 기반 — Task.sleep 대신 RunLoop.main.run으로 드레인
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.6))

        #expect(navigateCalled)
    }
}
```

- [ ] **Step 2: GreetingSnapshotTests.swift 작성**

```swift
import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class GreetingSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        // UIHostingController에서 layoutIfNeeded()만으로는 SwiftUI의 .onAppear가
        // 실행되지 않으므로 타이머가 시작되지 않는다 — 초기 상태(빈 nickname) 캡처
        let vm = GreetingViewModel(
            userInfoService: MockUserInfoService(),
            onNavigate: {}
        )
        let vc = UIHostingController(rootView: GreetingView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 3: 유닛 테스트 실행 (Cmd+U)**

`GreetingViewModelTests` 전체 통과 확인. 타이머 테스트는 약 2.6초 소요됨.

- [ ] **Step 4: 스냅샷 테스트 실행 (레퍼런스 생성 후 재실행)**

- [ ] **Step 5: 커밋**

```bash
git add Onboarding/Tests/
git commit -m "test: Greeting 유닛 및 스냅샷 테스트 추가"
```

---

## Task 6: PreviewTest 테스트

**Files:**
- Create: `Onboarding/Tests/OnboardingTests/UnitTests/PreviewTestViewModelTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTests/PreviewTestSnapshotTests.swift`

- [ ] **Step 1: PreviewTestViewModelTests.swift 작성**

> `transform(input:)` 호출은 반드시 `collectOutputs` 전에 한 번만 수행한다.

```swift
import Testing
import Combine
import Network
@testable import Onboarding

@MainActor
@Suite("PreviewTestViewModel 테스트", .serialized)
struct PreviewTestViewModelTests {

    private func makeSUT(service: MockOnboardingService = .init()) -> PreviewTestViewModel {
        PreviewTestViewModel(onboardingService: service)
    }

    private func makeInput() -> (
        subject: PassthroughSubject<PreviewTestViewModel.Input, Never>,
        publisher: AnyPublisher<PreviewTestViewModel.Input, Never>
    ) {
        let subject = PassthroughSubject<PreviewTestViewModel.Input, Never>()
        return (subject, subject.eraseToAnyPublisher())
    }

    // MARK: - viewDidLoad 성공

    @Test("viewDidLoad: getPreviewTestList 성공 → updateTotalNum, updateQuestion, updateButtonStates 출력")
    func viewDidLoad_onSuccess_sendsInitialOutputs() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.viewDidLoad)
        }

        let hasUpdateTotalNum = outputs.contains { if case .updateTotalNum = $0 { return true }; return false }
        let hasUpdateQuestion = outputs.contains { if case .updateQuestion = $0 { return true }; return false }
        let hasUpdateButtonStates = outputs.contains { if case .updateButtonStates = $0 { return true }; return false }

        #expect(hasUpdateTotalNum)
        #expect(hasUpdateQuestion)
        #expect(hasUpdateButtonStates)
    }

    // MARK: - viewDidLoad 실패

    @Test("viewDidLoad: getPreviewTestList 실패 → showError 출력")
    func viewDidLoad_onFailure_sendsShowError() async {
        let service = MockOnboardingService()
        service.getPreviewTestListResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.viewDidLoad)
        }

        let hasShowError = outputs.contains { if case .showError = $0 { return true }; return false }
        #expect(hasShowError)
    }

    // MARK: - optionTapped

    @Test("optionTapped: 선택 → updateOptionState(isSelected: true)")
    func optionTapped_sendsOptionSelected() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        // 먼저 문제 로드
        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.optionTapped(1))
        }

        let selectedTrue = outputs.contains {
            if case .updateOptionState(let idx, let isSelected) = $0 {
                return idx == 1 && isSelected == true
            }
            return false
        }
        #expect(selectedTrue)
    }

    @Test("optionTapped: 같은 옵션 재탭 → updateOptionState(isSelected: false)")
    func optionTapped_sameTwice_sendsOptionDeselected() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.optionTapped(1)) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.optionTapped(1))
        }

        let deselected = outputs.contains {
            if case .updateOptionState(let idx, let isSelected) = $0 {
                return idx == 1 && isSelected == false
            }
            return false
        }
        #expect(deselected)
    }

    @Test("첫 문제에서 optionTapped: updateButtonStates(nextHidden: false) 출력")
    func optionTapped_onFirstQuestion_updatesButtonStates() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.optionTapped(1))
        }

        let buttonStateUpdated = outputs.contains {
            if case .updateButtonStates(_, let nextHidden, _) = $0 {
                return nextHidden == false
            }
            return false
        }
        #expect(buttonStateUpdated)
    }

    // MARK: - 페이지 이동

    @Test("nextTapped: updateQuestion 출력")
    func nextTapped_sendsUpdateQuestion() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.optionTapped(1)) } // 첫 문제 선택 필요

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.nextTapped)
        }

        let hasUpdateQuestion = outputs.contains { if case .updateQuestion = $0 { return true }; return false }
        #expect(hasUpdateQuestion)
    }

    @Test("prevTapped: updateQuestion 출력")
    func prevTapped_sendsUpdateQuestion() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        // 2번째 문제로 이동 후 prevTapped
        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.optionTapped(1)) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.nextTapped) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.prevTapped)
        }

        let hasUpdateQuestion = outputs.contains { if case .updateQuestion = $0 { return true }; return false }
        #expect(hasUpdateQuestion)
    }

    @Test("nextTapped: 마지막 문제에서 showSubmitAlert 출력")
    func nextTapped_onLastQuestion_sendsShowSubmitAlert() async {
        let service = MockOnboardingService()
        service.getPreviewTestListResult = .success(.stub(questionCount: 1))
        let sut = makeSUT(service: service)
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.nextTapped)
        }

        let hasSubmitAlert = outputs.contains { if case .showSubmitAlert = $0 { return true }; return false }
        #expect(hasSubmitAlert)
    }

    // MARK: - escapeTapped

    @Test("escapeTapped: navigateToHome 출력")
    func escapeTapped_sendsNavigateToHome() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.escapeTapped)
        }

        let hasNavigateToHome = outputs.contains { if case .navigateToHome = $0 { return true }; return false }
        #expect(hasNavigateToHome)
    }

    // MARK: - confirmSubmit

    @Test("confirmSubmit: submitPreview 성공 → navigateToResult 출력")
    func confirmSubmit_onSuccess_sendsNavigateToResult() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.confirmSubmit)
        }

        let hasNavigateToResult = outputs.contains { if case .navigateToResult = $0 { return true }; return false }
        #expect(hasNavigateToResult)
    }

    @Test("confirmSubmit: submitPreview 실패 → showSubmitRetryAlert 출력")
    func confirmSubmit_onFailure_sendsShowSubmitRetryAlert() async {
        let service = MockOnboardingService()
        service.submitPreviewResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.confirmSubmit)
        }

        let hasRetryAlert = outputs.contains { if case .showSubmitRetryAlert = $0 { return true }; return false }
        #expect(hasRetryAlert)
    }

    @Test("confirmSubmit 동시 중복 호출: 두 번째 submit 무시")
    func confirmSubmit_concurrent_secondCallIsIgnored() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        var navigateToResultCount = 0
        var cancellables = Set<AnyCancellable>()
        outputPublisher.sink {
            if case .navigateToResult = $0 { navigateToResultCount += 1 }
        }.store(in: &cancellables)

        subject.send(.confirmSubmit)
        subject.send(.confirmSubmit) // isSubmitting = true 상태에서 두 번째 — 무시됨

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(navigateToResultCount == 1)
    }
}
```

- [ ] **Step 2: PreviewTestSnapshotTests.swift 작성 (UIKit View)**

```swift
import XCTest
import SnapshotTesting
@testable import Onboarding

@MainActor
class PreviewTestSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let view = PreviewTestView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.layoutIfNeeded()

        assertSnapshot(of: view, as: .image)
    }
}
```

- [ ] **Step 3: 유닛 테스트 실행 (Cmd+U)**

`PreviewTestViewModelTests` 전체 통과 확인.

- [ ] **Step 4: 스냅샷 테스트 실행 (레퍼런스 생성 후 재실행)**

- [ ] **Step 5: 커밋**

```bash
git add Onboarding/Tests/
git commit -m "test: PreviewTest 유닛 및 스냅샷 테스트 추가"
```

---

## Task 7: PreviewResult 테스트

**Files:**
- Create: `Onboarding/Tests/OnboardingTests/UnitTests/PreviewResultViewModelTests.swift`
- Create: `Onboarding/Tests/OnboardingTests/SnapshotTests/PreviewResultSnapshotTests.swift`

- [ ] **Step 1: PreviewResultViewModelTests.swift 작성**

```swift
import Testing
import QRIZUtils
@testable import Onboarding

@MainActor
@Suite("PreviewResultViewModel 테스트", .serialized)
struct PreviewResultViewModelTests {

    private func makeSUT(
        service: MockOnboardingService = .init(),
        onNavigateToGreeting: @escaping () -> Void = {}
    ) -> PreviewResultViewModel {
        PreviewResultViewModel(
            onboardingService: service,
            onNavigateToGreeting: onNavigateToGreeting
        )
    }

    // MARK: - analyzePreview 성공

    @Test("onViewDidLoad: analyzePreview 성공 → expectScore 세팅")
    func onViewDidLoad_onSuccess_setsExpectScore() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .success(.stub(estimatedScore: 84.5))
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.previewScoresData.expectScore == 84.5)
    }

    @Test("onViewDidLoad: analyzePreview 성공 → subjectScores[0], subjectScores[1] 세팅")
    func onViewDidLoad_onSuccess_setsSubjectScores() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .success(.stub(part1Score: 45, part2Score: 38))
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.previewScoresData.subjectScores[0] == 45)
        #expect(sut.previewScoresData.subjectScores[1] == 38)
        #expect(sut.previewScoresData.subjectCount == 2)
    }

    @Test("onViewDidLoad: analyzePreview 성공 → firstConcept, secondConcept 세팅")
    func onViewDidLoad_onSuccess_setsConcepts() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .success(
            .stub(topConceptsToImprove: ["SQL 기본", "SELECT문"])
        )
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.previewConceptsData.firstConcept == "SQL 기본")
        #expect(sut.previewConceptsData.secondConcept == "SELECT문")
    }

    // MARK: - analyzePreview 실패

    @Test("onViewDidLoad: analyzePreview 실패 → errorMessage 세팅")
    func onViewDidLoad_onFailure_setsErrorMessage() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.errorMessage != nil)
    }

    // MARK: - didTapClose

    @Test("didTapClose: onNavigateToGreeting 호출")
    func didTapClose_callsOnNavigateToGreeting() {
        var navigateCalled = false
        let sut = makeSUT(onNavigateToGreeting: { navigateCalled = true })

        sut.didTapClose()

        #expect(navigateCalled)
    }
}
```

- [ ] **Step 2: PreviewResultSnapshotTests.swift 작성**

```swift
import XCTest
import SnapshotTesting
import SwiftUI
import QRIZUtils
@testable import Onboarding

@MainActor
class PreviewResultSnapshotTests: OnboardingSnapshotTestCase {

    func testLoadedState() {
        let vm = PreviewResultViewModel(
            onboardingService: MockOnboardingService(),
            onNavigateToGreeting: {}
        )
        // subjectScores는 [0,0,0,0,0] 5개 배열로 초기화 — 인덱스 할당으로 실제 updateData와 동일하게 재현
        vm.previewScoresData.expectScore = 72.0
        vm.previewScoresData.subjectScores[0] = 40
        vm.previewScoresData.subjectScores[1] = 32
        vm.previewScoresData.subjectCount = 2
        vm.previewConceptsData.firstConcept = "SQL 기본"
        vm.previewConceptsData.secondConcept = "SELECT문"
        vm.previewConceptsData.totalQuestions = 10

        let vc = UIHostingController(rootView: PreviewResultView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 3: 유닛 테스트 실행 (Cmd+U)**

`PreviewResultViewModelTests` 전체 통과 확인.

- [ ] **Step 4: 스냅샷 테스트 실행 (레퍼런스 생성 후 재실행)**

- [ ] **Step 5: 전체 테스트 최종 실행**

모든 유닛 테스트 + 스냅샷 테스트 통과 확인 (Cmd+U).

- [ ] **Step 6: 커밋**

```bash
git add Onboarding/Tests/
git commit -m "test: PreviewResult 유닛 및 스냅샷 테스트 추가"
```
