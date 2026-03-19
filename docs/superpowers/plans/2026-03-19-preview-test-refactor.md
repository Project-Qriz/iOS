# PreviewTest 리팩토링 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PreviewTestViewModel의 병렬 배열을 PreviewQuestion 단일 모델로 통합하고, CountdownTimer로 타이머를 교체하며, Button Output 3개를 1개로 통합한다.

**Architecture:** Task 1에서 병렬 배열을 PreviewQuestion으로 교체(currentNumber 1-based → currentIndex 0-based), Task 2에서 CountdownTimer 교체 및 @MainActor 복원, Task 3에서 Button Output 통합 및 ViewController 업데이트. 각 Task 완료 후 빌드가 통과해야 한다.

**Tech Stack:** Swift, Combine, UIKit, QRIZUtils(CountdownTimer, NSAttributedString)

---

## 파일 구조

| 파일 | 변경 내용 |
|------|-----------|
| `Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift` | Task 1~3 모두 수정 |
| `Onboarding/Sources/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift` | Task 3에서 Output switch 수정 |
| `Onboarding/Sources/Onboarding/PreviewTest/View/PreviewTestView.swift` | 변경 없음 |

---

## Chunk 1: ViewModel 리팩토링

### Task 1: PreviewQuestion 모델 + 병렬 배열 교체

**Files:**
- Modify: `Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift`

**배경:**
현재 ViewModel은 동일 인덱스로 동기화되어야 하는 4개 병렬 배열을 가진다:
- `questionList: [PreviewTestListQuestion]` — 문제 데이터
- `submitList: [TestSubmitData]` — 제출용 데이터 (같은 인덱스)
- `selectedList: [Int?]` — 선택된 옵션 (같은 인덱스)
- `currentNumber: Int?` — 현재 문제 번호 (1-based)

이를 `PreviewQuestion` 단일 모델 + `currentIndex: Int` (0-based)로 교체한다.

- [ ] **Step 1: PreviewQuestion 구조체를 파일 맨 위(import 아래, class 선언 위)에 추가**

```swift
private struct PreviewQuestion {
    let data: PreviewTestListQuestion
    var selectedOptionIdx: Int?   // 선택된 옵션 번호 (1-based), nil이면 미선택
    var submitOptionId: Int?      // 제출 시 사용할 option ID
}
```

- [ ] **Step 2: Properties 섹션에서 병렬 배열 4개 제거, 새 프로퍼티 2개 추가**

제거할 줄 (현재 37~40번 줄):
```swift
private var questionList: [PreviewTestListQuestion] = []
private var submitList: [TestSubmitData] = []
private var selectedList: [Int?] = []
private var currentNumber: Int?
```

추가:
```swift
private var questions: [PreviewQuestion] = []
private var currentIndex: Int = 0   // 0-based 현재 문제 인덱스
```

- [ ] **Step 3: `handleOptionTap` 전체 교체**

현재 코드(92~112줄)를 아래로 교체:

```swift
func handleOptionTap(_ idx: Int) {
    let prev = questions[currentIndex].selectedOptionIdx

    if let prev {
        output.send(.updateOptionState(idx: prev, isSelected: false))
    }

    if prev == idx {
        questions[currentIndex].selectedOptionIdx = nil
        questions[currentIndex].submitOptionId = nil
    } else {
        questions[currentIndex].selectedOptionIdx = idx
        questions[currentIndex].submitOptionId = questions[currentIndex].data.options[idx - 1].id
        output.send(.updateOptionState(idx: idx, isSelected: true))
    }

    if currentIndex == 0 {
        output.send(.setNextButtonHidden(questions[0].selectedOptionIdx == nil))
    }
}
```

- [ ] **Step 4: `handleNextTap` 교체**

```swift
func handleNextTap() {
    if currentIndex >= questions.count - 1 {
        output.send(.showSubmitAlert)
    } else {
        navigatePage(offset: 1)
    }
}
```

- [ ] **Step 5: `navigatePage` 교체**

```swift
func navigatePage(offset: Int) {
    currentIndex += offset
    let selectedOption = questions[currentIndex].selectedOptionIdx

    output.send(.updateQuestion(
        question: questions[currentIndex].data,
        curNum: currentIndex + 1,
        selectedOption: selectedOption
    ))
    sendButtonStates(curNum: currentIndex + 1, selectedOption: selectedOption)
}
```

- [ ] **Step 6: `fetchQuestions` 교체**

```swift
func fetchQuestions() async {
    do {
        let response = try await onboardingService.getPreviewTestList()
        let rawQuestions = response.data.questions
        guard !rawQuestions.isEmpty else { return }

        currentIndex = 0
        timeLimit = response.data.totalTimeLimit
        questions = rawQuestions.map { PreviewQuestion(data: $0) }

        output.send(.updateTotalNum(rawQuestions.count))
        output.send(.updateQuestion(question: questions[0].data, curNum: 1, selectedOption: nil))
        sendButtonStates(curNum: 1, selectedOption: nil)
        startTimer(totalTimeLimit: response.data.totalTimeLimit)
    } catch {
        output.send(.showError("문제 불러오기 실패"))
    }
}
```

- [ ] **Step 7: `submit` 교체 (TestSubmitData 재구성)**

```swift
func submit() async {
    let submitList = questions.enumerated().map { idx, q in
        TestSubmitData(
            question: SubmitQuestionData(questionId: q.data.questionId, category: q.data.category),
            questionNum: idx + 1,
            optionId: q.submitOptionId
        )
    }
    do {
        _ = try await onboardingService.submitPreview(testSubmitDataList: submitList)
        stopTimer()
        output.send(.dismissSubmitAlert)
        output.send(.navigateToResult)
    } catch {
        output.send(.dismissSubmitAlert)
        output.send(.showError("잠시 후 다시 시도해주세요."))
    }
}
```

- [ ] **Step 8: 빌드 확인**

```bash
cd /Users/hun/iOS && xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|BUILD"
```

Expected: `** BUILD SUCCEEDED **` (error: 라인 없음)

- [ ] **Step 9: 커밋**

```bash
cd /Users/hun/iOS && git add Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift && git commit -m "refactor: PreviewQuestion 모델로 병렬 배열 통합"
```

---

### Task 2: CountdownTimer 교체 + @MainActor 복원

**Files:**
- Modify: `Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift`

**배경:**
`CountdownTimer` (`QRIZUtils`)는 `@MainActor` final class. `init(totalTime: Int)`으로 생성, `.start()`로 시작, `.stop()`으로 정지. `remainingTimePublisher: AnyPublisher<Int, Never>`가 초당 1씩 감소하는 값을 emit하며, 0에서 멈춤. `CurrentValueSubject` 기반이라 구독 즉시 현재값(= totalTime)을 emit한다. ViewModel에 `@MainActor`를 추가해 CountdownTimer와 actor 경계를 일치시킨다.

- [ ] **Step 1: class 선언에 `@MainActor` 추가**

```swift
// 변경 전
final class PreviewTestViewModel {

// 변경 후
@MainActor
final class PreviewTestViewModel {
```

- [ ] **Step 2: Properties 섹션에서 `timer`, `startTime` 제거, `countdownTimer`·`isSubmitting` 추가**

제거:
```swift
private var timer: Timer?
private var startTime: Date?
```

추가(`timeLimit: Int = 0` 바로 위에):
```swift
private var countdownTimer: CountdownTimer?
private var isSubmitting: Bool = false
```

- [ ] **Step 3: `deinit` 교체**

```swift
deinit {
    countdownTimer?.stop()
}
```

- [ ] **Step 4: `transform` 내 `.escapeTapped` case 교체**

```swift
case .escapeTapped:
    countdownTimer?.stop()
    output.send(.navigateToHome)
```

- [ ] **Step 5: `fetchQuestions` 내 `startTimer` 호출을 CountdownTimer 구독으로 교체**

`sendButtonStates(curNum: 1, selectedOption: nil)` 다음 줄의 `startTimer(totalTimeLimit: response.data.totalTimeLimit)`를 아래로 교체:

```swift
let timer = CountdownTimer(totalTime: response.data.totalTimeLimit)
countdownTimer = timer
timer.remainingTimePublisher
    .sink { [weak self] remaining in
        guard let self else { return }
        output.send(.updateTime(timeLimit: timeLimit, timeRemaining: remaining))
        if remaining == 0 {
            guard !isSubmitting else { return }
            Task { await self.submit() }
        }
    }
    .store(in: &cancellables)
timer.start()
```

> **주의:** `CountdownTimer`는 `CurrentValueSubject` 기반이라 구독 즉시 `totalTime`을 emit한다. 별도로 초기 `.updateTime`을 보낼 필요 없다.

- [ ] **Step 6: `submit` 에 `isSubmitting` 가드 + `countdownTimer` 정지 추가**

```swift
func submit() async {
    guard !isSubmitting else { return }
    isSubmitting = true
    countdownTimer?.stop()

    let submitList = questions.enumerated().map { idx, q in
        TestSubmitData(
            question: SubmitQuestionData(questionId: q.data.questionId, category: q.data.category),
            questionNum: idx + 1,
            optionId: q.submitOptionId
        )
    }
    do {
        _ = try await onboardingService.submitPreview(testSubmitDataList: submitList)
        output.send(.dismissSubmitAlert)
        output.send(.navigateToResult)
    } catch {
        isSubmitting = false
        output.send(.dismissSubmitAlert)
        output.send(.showError("잠시 후 다시 시도해주세요."))
    }
}
```

- [ ] **Step 7: `startTimer`, `tickTimer`, `stopTimer` 메서드 3개 제거**

private extension 내 아래 세 함수 전체 삭제:
```swift
func startTimer(totalTimeLimit: Int) { ... }
func tickTimer() { ... }
func stopTimer() { ... }
```

- [ ] **Step 8: 빌드 확인**

```bash
cd /Users/hun/iOS && xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|BUILD"
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 9: 커밋**

```bash
cd /Users/hun/iOS && git add Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift && git commit -m "refactor: CountdownTimer 교체 및 @MainActor 복원"
```

---

## Chunk 2: Button Output 통합

### Task 3: Button Output 3개 → 1개 + ViewController 업데이트

**Files:**
- Modify: `Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift`
- Modify: `Onboarding/Sources/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift`

**배경:**
현재 버튼 상태 변경 시 Output 3개(`setPrevButtonHidden`, `setNextButtonHidden`, `setNextButtonTitle`)를 개별 전송한다. 이를 `updateButtonStates` 하나로 통합한다. `sendButtonStates`의 시그니처도 0-based `index`로 변경한다.

- [ ] **Step 1: Output enum에서 3개 case 제거, 1개로 교체**

제거:
```swift
case setPrevButtonHidden(Bool)
case setNextButtonHidden(Bool)
case setNextButtonTitle(isLastQuestion: Bool)
```

추가:
```swift
case updateButtonStates(prevHidden: Bool, nextHidden: Bool, nextTitle: String)
```

- [ ] **Step 2: `sendButtonStates` 시그니처 및 구현 교체**

```swift
func sendButtonStates(index: Int, selectedOption: Int?) {
    let isFirst = index == 0
    let isLast = index == questions.count - 1
    output.send(.updateButtonStates(
        prevHidden: isFirst,
        nextHidden: isFirst && selectedOption == nil,
        nextTitle: isLast ? "제출" : "다음"
    ))
}
```

- [ ] **Step 3: `navigatePage` 내 `sendButtonStates` 호출을 새 시그니처로 교체**

```swift
sendButtonStates(index: currentIndex, selectedOption: selectedOption)
```

- [ ] **Step 4: `fetchQuestions` 내 `sendButtonStates` 호출을 새 시그니처로 교체**

```swift
sendButtonStates(index: 0, selectedOption: nil)
```

- [ ] **Step 5: `handleOptionTap` 내 버튼 상태 갱신을 새 시그니처로 교체**

기존:
```swift
if currentIndex == 0 {
    output.send(.setNextButtonHidden(questions[0].selectedOptionIdx == nil))
}
```

교체:
```swift
if currentIndex == 0 {
    sendButtonStates(index: 0, selectedOption: questions[0].selectedOptionIdx)
}
```

- [ ] **Step 6: ViewController Output switch에서 3개 case 제거, 1개로 교체**

파일: `Onboarding/Sources/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift`

제거(82~87번 줄 근처):
```swift
case .setPrevButtonHidden(let hidden):
    previewTestView.previousButton.isHidden = hidden
case .setNextButtonHidden(let hidden):
    previewTestView.nextButton.isHidden = hidden
case .setNextButtonTitle(let isLastQuestion):
    previewTestView.nextButton.updateTitle(isLastQuestion ? "제출" : "다음")
```

추가(동일 위치):
```swift
case .updateButtonStates(let prevHidden, let nextHidden, let nextTitle):
    previewTestView.previousButton.isHidden = prevHidden
    previewTestView.nextButton.isHidden = nextHidden
    previewTestView.nextButton.updateTitle(nextTitle)
```

- [ ] **Step 7: 빌드 확인**

```bash
cd /Users/hun/iOS && xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|BUILD"
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 8: 커밋**

```bash
cd /Users/hun/iOS && git add Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift Onboarding/Sources/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift && git commit -m "refactor: Button Output 3개를 updateButtonStates로 통합"
```
