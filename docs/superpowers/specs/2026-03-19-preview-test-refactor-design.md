# PreviewTest 리팩토링 Design

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PreviewTestViewModel의 병렬 배열 구조를 단일 모델로 통합하고, 타이머를 CountdownTimer로 교체하며, Button Output을 하나로 통합해 가독성과 유지보수성을 개선한다.

**Architecture:** PreviewQuestion 모델이 기존 3개 병렬 배열(questionList, submitList, selectedList)을 대체한다. @MainActor를 복원해 CountdownTimer와의 actor 경계를 일치시킨다. ViewController는 Button Output case 수정만 필요하며 PreviewTestView는 변경하지 않는다.

**Tech Stack:** Swift, Combine, UIKit, QRIZUtils(CountdownTimer)

---

## 변경 파일

- Modify: `Onboarding/Sources/Onboarding/PreviewTest/ViewModel/PreviewTestViewModel.swift`
- Modify: `Onboarding/Sources/Onboarding/PreviewTest/ViewController/PreviewTestViewController.swift`
- No change: `Onboarding/Sources/Onboarding/PreviewTest/View/PreviewTestView.swift`

---

## Section 1: PreviewQuestion 모델

### 문제

현재 ViewModel에 3개의 병렬 배열이 존재해 같은 인덱스를 통해 동기화됨:

```swift
private var questionList: [PreviewTestListQuestion]  // 문제 데이터
private var submitList: [TestSubmitData]             // 제출 데이터 (동일 인덱스)
private var selectedList: [Int?]                     // 선택된 옵션 (동일 인덱스)
private var currentNumber: Int?                      // 1-based 현재 번호
```

### 해결

`PreviewQuestion`은 ViewModel 파일 상단에 private 구조체로 선언한다.

```swift
private struct PreviewQuestion {
    let data: PreviewTestListQuestion
    var selectedOptionIdx: Int?   // 선택된 옵션 (1-based), nil이면 미선택
    var submitOptionId: Int?      // 제출 시 사용할 option ID
}
```

ViewModel 프로퍼티:
```swift
private var questions: [PreviewQuestion] = []
private var currentIndex: Int = 0  // 0-based. fetchQuestions 완료 시 0으로 설정
```

배열 접근이 단순해진다:
```swift
// 이전
questionList[currentNumber - 1]
submitList[currentNumber - 1].optionId = ...
selectedList[currentNumber - 1] = idx

// 이후
questions[currentIndex].data
questions[currentIndex].submitOptionId = ...
questions[currentIndex].selectedOptionIdx = idx
```

`submit()` 호출 시 `TestSubmitData` 재구성:
```swift
func submit() async {
    let submitList = questions.enumerated().map { idx, q in
        TestSubmitData(
            question: SubmitQuestionData(questionId: q.data.questionId, category: q.data.category),
            questionNum: idx + 1,
            optionId: q.submitOptionId
        )
    }
    // ...onboardingService.submitPreview(testSubmitDataList: submitList)
}
```

---

## Section 2: CountdownTimer 교체 + @MainActor 복원

### 문제

타이머 관련 코드가 ViewModel에 직접 구현되어 있어 복잡함:

```swift
private var timer: Timer?
private var startTime: Date?
private var timeLimit: Int = 0
// + startTimer(), tickTimer(), stopTimer() 3개 메서드
```

### 해결

`QRIZUtils.CountdownTimer`로 교체. `CountdownTimer`가 `@MainActor`이므로 ViewModel에 `@MainActor`를 복원한다. `@MainActor` 클래스의 `deinit`은 main actor에서 실행되므로 `countdownTimer?.stop()` 호출이 안전하다.

```swift
@MainActor
final class PreviewTestViewModel {
    private var countdownTimer: CountdownTimer?
    private var timeLimit: Int = 0  // progress 계산용으로 유지
```

**타이머 구독 위치:** `transform`이 실행될 때는 아직 `countdownTimer`가 nil이므로, 구독은 `fetchQuestions` 완료 후 `CountdownTimer` 생성 직후에 설정한다.

```swift
private func fetchQuestions() async {
    // ...fetch 완료 후
    currentIndex = 0
    timeLimit = response.data.totalTimeLimit

    // 초기 버튼 상태 설정 (첫 문제, 옵션 미선택)
    sendButtonStates(index: 0, selectedOption: nil)

    let timer = CountdownTimer(totalTime: timeLimit)
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
}
```

**이중 제출 방지:** 타이머 만료와 `escapeTapped`의 레이스 컨디션을 막기 위해 `isSubmitting` 플래그를 사용한다.

```swift
private var isSubmitting: Bool = false

// submit() 시작 시
func submit() async {
    guard !isSubmitting else { return }
    isSubmitting = true
    countdownTimer?.stop()
    // ...onboardingService.submitPreview(...)
}
```

**타이머 정지:** `escapeTapped`와 `submit()` 성공 시 명시적으로 정지. `deinit`에서도 정지.

```swift
// transform 내부
case .escapeTapped:
    countdownTimer?.stop()
    output.send(.navigateToHome)

// submit() 성공 시
countdownTimer?.stop()

// deinit (@MainActor 클래스이므로 안전)
deinit {
    countdownTimer?.stop()
}
```

제거되는 코드: `timer`, `startTime` 프로퍼티, `startTimer()`, `tickTimer()`, `stopTimer()` 메서드.

---

## Section 3: Button Output 통합 + handleOptionTap 수정

### 문제 1: Output 3개 개별 전송

```swift
case setPrevButtonHidden(Bool)
case setNextButtonHidden(Bool)
case setNextButtonTitle(isLastQuestion: Bool)
```

### 해결 1: Output 1개로 통합

```swift
case updateButtonStates(prevHidden: Bool, nextHidden: Bool, nextTitle: String)
```

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

### 문제 2: handleOptionTap에서 버튼 상태 미갱신

첫 번째 문제(index == 0)에서 옵션을 탭하면 다음 버튼 가시성이 바뀌어야 하는데, 페이지 이동 시에만 `sendButtonStates`를 호출하면 옵션 탭 시 버튼 상태가 갱신되지 않는다.

### 해결 2: handleOptionTap 내에서도 첫 문제 시 버튼 상태 갱신

```swift
func handleOptionTap(_ idx: Int) {
    // ...옵션 토글 로직

    if currentIndex == 0 {
        sendButtonStates(index: 0, selectedOption: questions[0].selectedOptionIdx)
    }
}
```

### ViewController 변경

```swift
// 이전 (3개 case)
case .setPrevButtonHidden(let hidden): ...
case .setNextButtonHidden(let hidden): ...
case .setNextButtonTitle(let isLastQuestion): ...

// 이후 (1개 case)
case .updateButtonStates(let prevHidden, let nextHidden, let nextTitle):
    previewTestView.previousButton.isHidden = prevHidden
    previewTestView.nextButton.isHidden = nextHidden
    previewTestView.nextButton.updateTitle(nextTitle)
```

---

## 변경하지 않는 것

- `PreviewTestView`: UI 컴포넌트 구조 유지
- Input enum: 변경 없음
- Output enum의 나머지 case: 변경 없음 (updateButtonStates로 3개 통합만)
- ViewController의 나머지 구조: 변경 없음
- `CountdownTimer` 자체: 수정 없음 (QRIZUtils 그대로 사용)
