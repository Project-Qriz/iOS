# Onboarding 패키지 테스트 Design

**Goal:** Onboarding 패키지에 유닛 테스트와 스냅샷 테스트를 추가한다. MistakeNote의 검증된 패턴을 기반으로 하되, `@MainActor` Mock(대신 `@unchecked Sendable`), Combine Output 수집 헬퍼, Parameterized tests 세 가지를 개선한다.

**Tech Stack:** Swift Testing (유닛), XCTest + swift-snapshot-testing (스냅샷), Combine, SwiftUI, UIKit

**주요 설계 결정:**
- Mock 클래스에 `@unchecked Sendable` 대신 `@MainActor` 사용 (Swift 5.7+에서 암묵적 Sendable 충족)
- `GreetingViewModel` 타이머 테스트는 `RunLoop.main.run(until:)`으로 실제 2.5초 대기
- `PreviewTestViewModel`은 Combine Output 수집 헬퍼로 이벤트 배열을 수집 후 검증
- `UserInfoManager.shared` 싱글톤 오염 방지를 위해 각 테스트 스위트 init에서 상태 리셋

---

## Section 1: Package.swift & 파일 구조

### Package.swift 변경

`dependencies`에 패키지 추가:

```swift
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
```

`targets`에 testTarget 추가:

```swift
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
```

### 디렉토리 구조

```
Tests/OnboardingTests/
├── Mocks/
│   ├── MockOnboardingService.swift
│   └── MockUserInfoService.swift
├── UnitTests/
│   ├── BeginOnboardingViewModelTests.swift
│   ├── BeginPreviewTestViewModelTests.swift
│   ├── CheckConceptViewModelTests.swift
│   ├── GreetingViewModelTests.swift
│   ├── PreviewTestViewModelTests.swift
│   └── PreviewResultViewModelTests.swift
├── SnapshotTests/
│   ├── BeginOnboardingSnapshotTests.swift
│   ├── BeginPreviewTestSnapshotTests.swift
│   ├── CheckConceptSnapshotTests.swift
│   ├── GreetingSnapshotTests.swift
│   ├── PreviewTestSnapshotTests.swift
│   └── PreviewResultSnapshotTests.swift
├── TestHelpers.swift
└── SnapshotTestHelpers.swift
```

---

## Section 2: Mock & Test Fixtures

### MockOnboardingService

`@MainActor`를 사용해 `@unchecked Sendable` 없이 Sendable을 만족시킨다. `OnboardingService`는 Sendable 요구사항이 없으므로 `@MainActor`만으로 충분하다.

```swift
@MainActor
final class MockOnboardingService: OnboardingService {
    var sendSurveyResult: Result<Void, Error> = .success(())
    var getPreviewTestListResult: Result<PreviewTestListResponse, Error> = .success(.stub())
    var submitPreviewResult: Result<PreviewSubmitResponse, Error> = .success(.stub())
    var analyzePreviewResult: Result<AnalyzePreviewResponse, Error> = .success(.stub())

    func sendSurvey(keyConcepts: [String]) async throws { try sendSurveyResult.get() }
    func getPreviewTestList() async throws -> PreviewTestListResponse { try getPreviewTestListResult.get() }
    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse { try submitPreviewResult.get() }
    func analyzePreview() async throws -> AnalyzePreviewResponse { try analyzePreviewResult.get() }
}
```

### MockUserInfoService

`UserInfoService: Sendable`을 요구한다. Swift 5.7+에서 `@MainActor` 클래스는 단일 액터에 격리되므로 암묵적으로 `Sendable`을 만족한다. 테스트 타겟이 `swiftLanguageMode(.v5)`이므로 이 규칙이 적용된다.

```swift
@MainActor
final class MockUserInfoService: UserInfoService {
    var getUserInfoResult: Result<UserInfoResponse, Error> = .success(.stub())
    func getUserInfo() async throws -> UserInfoResponse { try getUserInfoResult.get() }
}
```

### Test Fixtures (TestHelpers.swift)

`.stub()` / `.make()` 팩토리로 응답 객체 생성:

```swift
let asyncSleepNanoseconds: UInt64 = 100_000_000

extension PreviewTestListResponse {
    static func stub(questionCount: Int = 3, totalTimeLimit: Int = 600) -> Self { ... }
}

extension PreviewTestListQuestion {
    // options는 기본 4개 제공 — optionTapped 테스트에서 options[idx-1] 접근 시 크래시 방지
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
    ) -> Self { ... }
}

extension AnalyzePreviewResponse {
    // totalScore = part1Score + part2Score로 계산해 ScoreBreakdown 생성
    static func stub(
        estimatedScore: Double = 72.0,
        totalScore: Int = 72,
        part1Score: Int = 40,
        part2Score: Int = 32,
        topConceptsToImprove: [String] = ["SQL 기본", "SELECT문"],
        totalQuestions: Int = 10,
        weakAreas: [WeakArea] = []
    ) -> Self { ... }
}

extension PreviewSubmitResponse {
    static func stub() -> Self { PreviewSubmitResponse(code: 1, msg: "ok", data: nil) }
}

extension UserInfoResponse {
    // previewTestStatus 노출 — fetchUserInfo 후 UserInfoManager 상태 검증 시 제어 필요
    static func stub(
        name: String = "테스트유저",
        previewTestStatus: PreviewTestStatus = .previewCompleted
    ) -> Self { ... }
}
```

### Combine Output 수집 헬퍼 (TestHelpers.swift)

`PreviewTestViewModel`의 Input/Output Combine 패턴 테스트용.

**중요:** `transform(input:)`은 반드시 헬퍼 호출 전 한 번만 호출한다. 헬퍼는 이미 materialized된 Output publisher와 Input subject를 받는다.

```swift
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

**사용 패턴 (테스트 내부):**
```swift
let inputSubject = PassthroughSubject<PreviewTestViewModel.Input, Never>()
let outputPublisher = vm.transform(input: inputSubject.eraseToAnyPublisher())

let outputs = await collectOutputs(from: outputPublisher) {
    inputSubject.send(.viewDidLoad)
}
#expect(outputs.contains { ... })
```

---

## Section 3: 유닛 테스트 설계

모든 유닛 테스트는 swift-testing (`@Suite`, `@Test`, `#expect`)을 사용한다.

### BeginOnboardingViewModelTests / BeginPreviewTestViewModelTests

```
- didTapButton() 호출 시 onNavigate 클로저 호출됨
```

### CheckConceptViewModelTests

각 테스트 시작 전 `UserInfoManager.shared` 상태를 리셋해 싱글톤 오염을 방지한다.

```
- 초기 상태: selectedSet 비어있음, isDoneButtonEnabled = false
- didTapConcept: 선택/해제 토글 @Test(arguments: [0, 5, 15, 29])
- didTapAll: 전체 선택 (30개), 재탭 시 전체 해제
- didTapNone: selectedSet 비워지고 isDoneButtonEnabled = true
- didTapNone 후 didTapConcept: updateDoneButton()을 통해 isDoneButtonEnabled 정상 갱신
- isDoneButtonEnabled: 선택 없을 때 false, 1개 이상 true
- didTapDone: didTapNone() 후 selectedSet 비어있고 isDoneButtonEnabled = true인 상태에서 .greeting으로 navigate
- didTapDone: selectedSet 있으면 .previewTest로 navigate
- didTapDone: sendSurvey 성공 → navigate 호출
- didTapDone: sendSurvey 실패 → errorMessage 세팅
- didTapDone: isLoading 중 중복 탭 무시
```

### GreetingViewModelTests

```
- onAppear: nickname을 UserInfoManager.shared.name으로 즉시 세팅
- onAppear: fetchUserInfo 성공 시 nickname 업데이트
- onAppear: 2.5초 후 onNavigate 호출
```

Timer는 RunLoop 기반이므로 Swift Testing의 협력 스레드 풀에서 단순 `Task.sleep`만으로는 실행되지 않는다. 대기 방법:

```swift
RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.6))
#expect(navigateCalled)
```

각 GreetingViewModel 테스트 시작 전 `UserInfoManager.shared`를 초기 상태로 리셋한다.

### PreviewTestViewModelTests

Combine Output 수집 헬퍼로 출력 이벤트를 배열로 수집한 뒤 `#expect`로 검증한다.

```
- viewDidLoad: getPreviewTestList 성공 → updateTotalNum, updateQuestion, updateButtonStates 포함
- viewDidLoad: getPreviewTestList 실패 → showError 포함
- optionTapped: 선택 → updateOptionState(isSelected: true)
- optionTapped: 같은 옵션 재탭 → updateOptionState(isSelected: false)
- optionTapped: 첫 문제에서 선택 시 updateButtonStates(nextHidden: false) 출력
- prevTapped/nextTapped: updateQuestion 포함
- nextTapped: 마지막 문제에서 → showSubmitAlert
- escapeTapped: navigateToHome
- confirmSubmit: submitPreview 성공 → navigateToResult
- confirmSubmit: submitPreview 실패 → showSubmitRetryAlert
- confirmSubmit 동시 중복 호출: isSubmitting guard로 두 번째 submit 무시 (retrySubmit은 실패 후 isSubmitting이 false로 리셋된 뒤의 정상 재시도 경로임)
```

### PreviewResultViewModelTests

```
- onViewDidLoad: analyzePreview 성공 → previewScoresData.expectScore 세팅
- onViewDidLoad: analyzePreview 성공 → subjectScores[0], subjectScores[1] 세팅
- onViewDidLoad: analyzePreview 성공 → firstConcept, secondConcept 세팅
- onViewDidLoad: analyzePreview 실패 → errorMessage 세팅
- didTapClose: onNavigateToGreeting 호출
```

---

## Section 4: 스냅샷 테스트 설계

### SnapshotTestHelpers.swift

```swift
@MainActor
class OnboardingSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}
```

### 각 화면별 테스트 케이스

| 파일 | 테스트 케이스 |
|------|-------------|
| `BeginOnboardingSnapshotTests` | `testInitialState` |
| `BeginPreviewTestSnapshotTests` | `testInitialState` |
| `CheckConceptSnapshotTests` | `testInitialState`, `testWithSomeSelected`, `testAllSelected` |
| `GreetingSnapshotTests` | `testInitialState` |
| `PreviewResultSnapshotTests` | `testLoadedState` |
| `PreviewTestSnapshotTests` | `testInitialState` (UIKit View) |

### SwiftUI 뷰 스냅샷 방식

```swift
func testInitialState() {
    let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: .init(onNavigate: {})))
    vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
    vc.view.layoutIfNeeded()
    assertSnapshot(of: vc, as: .image)
}
```

### PreviewTestSnapshotTests (UIKit View)

```swift
func testInitialState() {
    let view = PreviewTestView()
    view.frame = CGRect(origin: .zero, size: Self.deviceSize)
    view.layoutIfNeeded()
    assertSnapshot(of: view, as: .image)
}
```

### PreviewResultSnapshotTests

`analyzePreview`가 async이므로 로딩 완료 상태를 캡처하기 위해 stub 데이터로 `previewScoresData` / `previewConceptsData`를 직접 세팅한 뒤 스냅샷을 찍는다.

```swift
func testLoadedState() {
    let vm = PreviewResultViewModel(
        onboardingService: MockOnboardingService(),
        onNavigateToGreeting: {}
    )
    vm.previewScoresData.expectScore = 72.0
    // subjectScores는 5개 배열로 초기화되므로 인덱스 할당으로 실제 updateData와 동일한 상태 재현
    vm.previewScoresData.subjectScores[0] = 40
    vm.previewScoresData.subjectScores[1] = 32
    vm.previewScoresData.subjectCount = 2
    let vc = UIHostingController(rootView: PreviewResultView(viewModel: vm))
    vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
    vc.view.layoutIfNeeded()
    assertSnapshot(of: vc, as: .image)
}
```

---

## 변경하지 않는 것

- Onboarding 소스 코드 (ViewModel, View 수정 없음)
- GreetingViewModel 타이머 interval (실제 2.5초 대기 방식 사용)
- MistakeNote 패키지의 기존 테스트
