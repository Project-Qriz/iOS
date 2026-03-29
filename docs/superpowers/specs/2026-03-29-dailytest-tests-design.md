# DailyTest 테스트 Design

## Goal

`DailyTestViewModel` 유닛 테스트와 `DailyTestView` 스냅샷 테스트를 작성한다.

## Architecture

기존 `DailyLearnViewModelTests` / `DailyLearnSnapshotTests` 패턴을 그대로 따른다.

- **Unit Tests**: TestHarness + Factory + `Task.sleep` 기반 async 검증
- **Snapshot Tests**: `DailyTestView` 직접 생성 후 update 메서드로 상태 주입, VC 레벨 1케이스 추가

## Tech Stack

Swift Testing, XCTest (snapshot), SnapshotTesting v1.18.9+, Combine, iOS 17+

---

## 파일 구조

| 파일 | 변경 |
|------|------|
| `Tests/DailyTests/Mocks/MockDailyService.swift` | `getDailyTestListResult`, `submitDailyResult` 프로퍼티 + 메서드 구현 추가 |
| `Tests/DailyTests/UnitTests/DailyTestViewModelTests.swift` | 신규 — 17케이스 |
| `Tests/DailyTests/SnapshotTests/DailyTestSnapshotTests.swift` | 신규 — 6케이스 |

---

## MockDailyService 확장

현재 `getDailyTestList`, `submitDaily`는 `fatalError`. 두 Result 프로퍼티를 추가하고 구현한다.

```swift
var getDailyTestListResult: Result<DailyTestListResponse, Error> = .success(
    DailyTestListResponse(code: 1, msg: "ok", data: MockDailyService.sampleTestList)
)
var submitDailyResult: Result<Void, Error> = .success(())

func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
    try getDailyTestListResult.get()
}

func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
    try submitDailyResult.get()
}
```

테스트 픽스처 (3문항, timeLimit = 70):

```swift
static let sampleTestList: [DailyTestInfo] = [
    DailyTestInfo(
        questionId: 1, skillId: 1, category: 1,
        question: "다음 중 엔터티의 특징으로 옳지 않은 것은?",
        description: nil,
        options: [
            .init(id: 11, content: "반드시 속성을 가져야 한다."),
            .init(id: 12, content: "유일한 식별자가 있어야 한다."),
            .init(id: 13, content: "두 개 이상의 인스턴스가 존재해야 한다."),
            .init(id: 14, content: "업무에서 관리해야 하는 정보여야 한다."),
        ],
        timeLimit: 70, difficulty: 1
    ),
    DailyTestInfo(
        questionId: 2, skillId: 2, category: 1,
        question: "정규화의 목적으로 가장 적절하지 않은 것은?",
        description: nil,
        options: [
            .init(id: 21, content: "삽입 이상 제거"),
            .init(id: 22, content: "삭제 이상 제거"),
            .init(id: 23, content: "갱신 이상 제거"),
            .init(id: 24, content: "조회 성능 향상"),
        ],
        timeLimit: 70, difficulty: 1
    ),
    DailyTestInfo(
        questionId: 3, skillId: 3, category: 2,
        question: "다음 SQL 중 DDL에 해당하지 않는 것은?",
        description: nil,
        options: [
            .init(id: 31, content: "CREATE"),
            .init(id: 32, content: "ALTER"),
            .init(id: 33, content: "DROP"),
            .init(id: 34, content: "SELECT"),
        ],
        timeLimit: 1, difficulty: 1  // 타이머 테스트용 timeLimit = 1
    ),
]
```

타이머 테스트(16, 17)는 마지막 문항의 `timeLimit = 1`을 이용해 `Task.sleep(nanoseconds: 1_100_000_000)` 대기.

---

## TestHarness

```swift
@MainActor
final class TestHarness {
    let sut: DailyTestViewModel
    let service: MockDailyService
    var received: [DailyTestViewModel.Output] = []
    private let inputSubject = PassthroughSubject<DailyTestViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()

    init(service: MockDailyService = MockDailyService()) {
        self.service = service
        self.sut = DailyTestViewModel(day: 1, dailyService: service)
        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { [weak self] output in self?.received.append(output) }
            .store(in: &subscriptions)
    }

    func send(_ input: DailyTestViewModel.Input) {
        inputSubject.send(input)
    }

    func sendViewDidLoad() async {
        send(.viewDidLoad)
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
    }

    func sendViewDidAppear() {
        send(.viewDidAppear)
    }

    func resetReceived() {
        received = []
    }
}
```

---

## Unit Test 케이스 (17개)

### fetchData

| # | 테스트명 | 입력 | 기대 출력 |
|---|---------|------|----------|
| 1 | `fetchData_success_emitsUpdateTotalPageAndUpdateQuestion` | viewDidLoad, 성공 응답 3문항 | `updateTotalPage(3)` + `updateQuestion(Q1)` |
| 2 | `fetchData_serverError_emitsFetchFailedIsServerError` | viewDidLoad, `NetworkError.serverError` | `fetchFailed(isServerError: true)` |
| 3 | `fetchData_genericError_emitsFetchFailedNotServerError` | viewDidLoad, `URLError(.timedOut)` | `fetchFailed(isServerError: false)` |
| 4 | `fetchData_emptyData_emitsFetchFailed` | viewDidLoad, `data = []` | `fetchFailed(isServerError: false)` |

### 옵션 선택 (optionSelectHandler)

| # | 테스트명 | 입력 | 기대 출력 |
|---|---------|------|----------|
| 5 | `optionTapped_Q1_firstTap_selectsOptionAndShowsButton` | viewDidLoad → optionTapped(1) | `updateOptionState(1, true)` + `setButtonVisibility(true)` |
| 6 | `optionTapped_Q1_sameTap_deselectsAndHidesButton` | viewDidLoad → optionTapped(1) → optionTapped(1) | 두 번째 tap에서 `updateOptionState(1, false)` + `setButtonVisibility(false)` |
| 7 | `optionTapped_Q1_differentTap_switchesSelection` | viewDidLoad → optionTapped(1) → optionTapped(2) | `updateOptionState(1, false)` + `updateOptionState(2, true)` |
| 8 | `optionTapped_Q2_doesNotEmitSetButtonVisibility` | viewDidLoad → nextButton → optionTapped(1) | `setButtonVisibility` 미방출 |

### 버튼 동작 (handleNextButton / buttonStateHandler)

| # | 테스트명 | 입력 | 기대 출력 |
|---|---------|------|----------|
| 9 | `nextButton_notLastQuestion_advancesToNextQuestion` | viewDidLoad → nextButton | `updateQuestion(Q2)` |
| 10 | `nextButton_lastQuestion_emitsPopSubmitAlert` | viewDidLoad → nextButton → nextButton → nextButton | `popSubmitAlert` |
| 11 | `lastQuestion_emitsAlterButtonText` | viewDidLoad → nextButton → nextButton | `alterButtonText` |

### 제출

| # | 테스트명 | 입력 | 기대 출력 |
|---|---------|------|----------|
| 12 | `alertSubmit_success_emitsSubmitSuccessAndMoveToDailyResult` | viewDidLoad → nextButton×2 → nextButton → alertSubmit | `submitSuccess` + `moveToDailyResult` |
| 13 | `alertSubmit_failure_emitsSubmitFailed` | submitDailyResult = .failure | `submitFailed` |

### 기타

| # | 테스트명 | 입력 | 기대 출력 |
|---|---------|------|----------|
| 14 | `alertCancel_emitsCancelAlert` | alertCancelButtonClicked | `cancelAlert` |
| 15 | `cancelButton_emitsMoveToHomeView` | cancelButtonClicked | `moveToHomeView` |

### 타이머

| # | 테스트명 | 입력 | 기대 출력 |
|---|---------|------|----------|
| 16 | `timer_timeout_autoAdvancesToNextQuestion` | viewDidLoad → nextButton×2 → viewDidAppear → sleep 2.1초 | `submitSuccess` + `moveToDailyResult` |
| 17 | `timer_recordsTimeSpentOnQuestionAdvance` | viewDidLoad → viewDidAppear → sleep 1.1초 → nextButton | `capturedSubmitData[0].timeSpent > 0` |

> 16번: Q3(timeLimit=1) 진입 후 viewDidAppear로 타이머 시작. t=1s에 timeRemaining=0(아직 유지), t=2s에 timeRemaining=-1 → 자동 제출. sleep은 `2_100_000_000` ns 필요.
> 17번: viewDidAppear 없이 nextButton만 누르면 timeRemaining == timeLimit이라 timeSpent=0. viewDidAppear → sleep 1.1초로 타이머가 최소 1회 발화한 뒤 nextButton → timeSpent > 0 확인.
> `timeSpent`는 ViewModel 내부 상태라 직접 접근 불가. MockDailyService의 `capturedSubmitData`로 검증.

MockDailyService에 `capturedSubmitData: [DailySubmitData]?` 추가 필요.

---

## Snapshot Test 케이스 (6개)

`DailyTestSnapshotTests: DailySnapshotTestCase`

`DailyTestView`를 직접 생성하고 update 메서드로 상태 주입. 디바이스 크기 393×852.

### 헬퍼

```swift
func makeView(size: CGSize = DailySnapshotTestCase.deviceSize) -> DailyTestView {
    let view = DailyTestView()
    view.frame = CGRect(origin: .zero, size: size)
    view.updateTotalPage(3)
    return view
}

func sampleQuestion(number: Int, timeLimit: Int = 70) -> QuestionData {
    QuestionData(
        question: "다음 중 엔터티의 특징으로 옳지 않은 것은?",
        option1: "반드시 속성을 가져야 한다.",
        option2: "유일한 식별자가 있어야 한다.",
        option3: "두 개 이상의 인스턴스가 존재해야 한다.",
        option4: "업무에서 관리해야 하는 정보여야 한다.",
        timeLimit: timeLimit,
        questionNumber: number
    )
}
```

| # | 테스트명 | 상태 |
|---|---------|------|
| 1 | `firstQuestion_buttonHidden` | `updateQuestion(Q1)` + `setButtonsVisibility(false)` |
| 2 | `firstQuestion_buttonVisible` | `updateQuestion(Q1)` + `setButtonsVisibility(true)` + `updateOptionState(2, true)` |
| 3 | `middleQuestion` | `updateQuestion(Q2)` + `setButtonsVisibility(true)` |
| 4 | `lastQuestion_submitButton` | `updateQuestion(Q3)` + `setButtonsVisibility(true)` + `alterButtonText()` |
| 5 | `optionSelected` | `updateQuestion(Q1)` + `setButtonsVisibility(false)` + `updateOptionState(3, true)` |
| 6 | `withNavigationBar` | `DailyTestViewController`를 `inDailyNav()`로 래핑 + `loadViewIfNeeded()` + view 직접 조작 |

6번은 `vc.view as! DailyTestView`로 캐스팅 후 update 메서드 호출.
