# Onboarding 패키지 테스트 Design

**Goal:** Onboarding 패키지에 유닛 테스트와 스냅샷 테스트를 추가한다. MistakeNote의 검증된 패턴을 기반으로 하되, `@MainActor` Mock(대신 `@unchecked Sendable`), Combine Output 수집 헬퍼, Parameterized tests 세 가지를 개선한다.

**Tech Stack:** Swift Testing (유닛), XCTest + swift-snapshot-testing (스냅샷), Combine, SwiftUI, UIKit

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

`UserInfoService: Sendable`이므로 `@MainActor` 클래스의 암묵적 Sendable로 충족한다.

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
    static func make(questionId: Int = 1, category: Int = 1, question: String = "테스트 문제", ...) -> Self { ... }
}

extension AnalyzePreviewResponse {
    static func stub(estimatedScore: Double = 72.0, part1Score: Int = 40, part2Score: Int = 32, ...) -> Self { ... }
}

extension PreviewSubmitResponse {
    static func stub() -> Self { PreviewSubmitResponse(code: 1, msg: "ok", data: nil) }
}

extension UserInfoResponse {
    static func stub(name: String = "테스트유저") -> Self { ... }
}
```

### Combine Output 수집 헬퍼 (TestHelpers.swift)

`PreviewTestViewModel`의 Input/Output Combine 패턴 테스트용:

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

---

## Section 3: 유닛 테스트 설계

모든 유닛 테스트는 swift-testing (`@Suite`, `@Test`, `#expect`)을 사용한다.

### BeginOnboardingViewModelTests / BeginPreviewTestViewModelTests

```
- didTapButton() 호출 시 onNavigate 클로저 호출됨
```

### CheckConceptViewModelTests

```
- 초기 상태: selectedSet 비어있음, isDoneButtonEnabled = false
- didTapConcept: 선택/해제 토글 @Test(arguments: [0, 5, 15, 29])
- didTapAll: 전체 선택 (30개), 재탭 시 전체 해제
- didTapNone: selectedSet 비워지고 isDoneButtonEnabled = true
- isDoneButtonEnabled: 선택 없을 때 false, 1개 이상 true
- didTapDone: selectedSet 비어있으면 .greeting으로 navigate
- didTapDone: selectedSet 있으면 .previewTest로 navigate
- didTapDone: sendSurvey 성공 → navigate 호출
- didTapDone: sendSurvey 실패 → errorMessage 세팅
- didTapDone: isLoading 중 중복 탭 무시
```

### GreetingViewModelTests

```
- onAppear: nickname을 UserInfoManager.shared.name으로 즉시 세팅
- onAppear: fetchUserInfo 성공 시 nickname 업데이트
- onAppear: 2.5초 후 onNavigate 호출 (실제 타이머 대기)
```

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
- confirmSubmit 중 retrySubmit: 이중 제출 방지
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
    vm.previewScoresData.subjectScores = [40, 32]
    // ...
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
