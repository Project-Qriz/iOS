# PreviewTest 리팩토링 Implementation Plan

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

`questionList[currentNumber - 1]`, `submitList[currentNumber - 1]`, `selectedList[currentNumber - 1]`처럼 항상 `- 1` 연산과 3개 배열을 동시에 수정해야 해서 파악이 어렵다.

### 해결

```swift
struct PreviewQuestion {
    let data: PreviewTestListQuestion
    var selectedOptionIdx: Int?   // 선택된 옵션 (1-based), nil이면 미선택
    var submitOptionId: Int?      // 제출 시 사용할 option ID
}

// 3개 배열 → 1개
private var questions: [PreviewQuestion] = []

// currentNumber (1-based) → currentIndex (0-based)
private var currentIndex: Int = 0
```

배열 접근:
```swift
// 이전
questionList[currentNumber - 1]
submitList[currentNumber - 1].optionId = ...

// 이후
questions[currentIndex].data
questions[currentIndex].submitOptionId = ...
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

`QRIZUtils.CountdownTimer`로 교체. `CountdownTimer`가 `@MainActor`이므로 ViewModel에 `@MainActor`를 복원한다.

```swift
@MainActor
final class PreviewTestViewModel {
    private var countdownTimer: CountdownTimer?
    private var timeLimit: Int = 0  // progress 계산용으로 유지
```

`fetchQuestions` 완료 시:
```swift
countdownTimer = CountdownTimer(totalTime: response.data.totalTimeLimit)
countdownTimer?.start()
```

`transform` 내에서 타이머 구독:
```swift
countdownTimer?.remainingTimePublisher
    .sink { [weak self] remaining in
        guard let self else { return }
        output.send(.updateTime(timeLimit: timeLimit, timeRemaining: remaining))
        if remaining <= 0 { Task { await self.submit() } }
    }
    .store(in: &cancellables)
```

`deinit` 정리:
```swift
deinit {
    countdownTimer?.stop()
}
```

---

## Section 3: Button Output 통합

### 문제

버튼 상태 변경 시 Output 3개를 개별 전송:

```swift
case setPrevButtonHidden(Bool)
case setNextButtonHidden(Bool)
case setNextButtonTitle(isLastQuestion: Bool)
```

`sendButtonStates()` 호출 한 번에 Output이 3개 발생해 VC의 switch도 3개 case 처리 필요.

### 해결

Output 1개로 통합:

```swift
case updateButtonStates(prevHidden: Bool, nextHidden: Bool, nextTitle: String)
```

ViewModel:
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

ViewController:
```swift
case .updateButtonStates(let prevHidden, let nextHidden, let nextTitle):
    previewTestView.previousButton.isHidden = prevHidden
    previewTestView.nextButton.isHidden = nextHidden
    previewTestView.nextButton.updateTitle(nextTitle)
```

---

## 변경하지 않는 것

- `PreviewTestView`: UI 컴포넌트 구조 유지
- Input enum: 변경 없음
- Output enum의 나머지 case: 변경 없음
- ViewController의 나머지 구조: 변경 없음
- `CountdownTimer` 자체: 수정 없음 (QRIZUtils 그대로 사용)
