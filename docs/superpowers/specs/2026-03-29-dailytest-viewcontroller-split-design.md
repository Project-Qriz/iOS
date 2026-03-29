# DailyTestViewController 분리 설계

**날짜**: 2026-03-29
**대상 파일**: `Features/Daily/Sources/Daily/DailyTest/`

## 문제

`DailyTestViewController`가 다음 책임을 동시에 지고 있음:

- 서브뷰 프로퍼티 보유 및 레이아웃
- Combine 배선 (input 조합 + output 구독)
- 12개 Output 케이스 인라인 처리 (bind() 내부)
- Navigation bar 구성 및 해제
- Alert 버튼 액션 설정
- UI 업데이트 메서드 (updateProgress 등)

## 목표

- `DailyTestView`: 모든 UI 관련 코드 격리
- `DailyTestViewController`: 배선(bind)과 처리(handleOutput) 분리, 순수 조율자로 축소

## 설계

### 1. DailyTestView (새 파일)

**위치**: `DailyTest/View/DailyTestView.swift`

**책임**:
- 서브뷰 프로퍼티 보유 (scrollView, progressView, footerView, contentsView, timerLabel)
- Auto Layout
- UI 업데이트 메서드 (VC에서 직접 호출)
- `userInputPublisher` — footerView.input + contentsView.optionTappedPublisher 내부 merge

**공개 인터페이스**:

```swift
final class DailyTestView: UIView {
    // UI 업데이트
    func updateQuestion(_ question: QuestionData)
    func updateTotalPage(_ totalPage: Int)
    func updateProgress(timeLimit: Int, timeRemaining: Int)
    func updateOptionState(at optionIdx: Int, isSelected: Bool)
    func setButtonsVisibility(isVisible: Bool)
    func alterButtonText()
    func scrollToTop()

    // Input 노출 — VC가 merge해서 ViewModel에 전달
    var userInputPublisher: AnyPublisher<DailyTestViewModel.Input, Never> { get }
}
```

footerView와 contentsView는 `private`으로 유지.
`scrollToTop()`은 scrollView 접근을 뷰 내부로 캡슐화.

### 2. DailyTestViewController (기존 파일, 축소)

**책임**:
- 프로퍼티: contentView, viewModel, input, subscriptions, submitAlertViewController, coordinator
- Lifecycle: viewDidLoad, viewDidAppear
- `bind()` — 배선만 (6줄 이하)
- `handleOutput(_ event:)` extension — 12 케이스 처리, contentView 메서드 호출
- Navigation items extension
- Alert extension

**loadView() 사용**:

```swift
override func loadView() {
    contentView = DailyTestView()
    view = contentView
}
```

`bind()` 형태:

```swift
private func bind() {
    let merged = input.merge(with: contentView.userInputPublisher)
    viewModel.transform(input: merged.eraseToAnyPublisher())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] event in
            guard let self else { return }
            handleOutput(event)
        }
        .store(in: &subscriptions)
}
```

### 3. handleOutput extension

`// MARK: - Output Handling` extension으로 분리.
bind()의 인라인 switch를 `handleOutput(_ event: DailyTestViewModel.Output)`으로 이동.

```swift
private func handleOutput(_ event: DailyTestViewModel.Output) {
    switch event {
    case .fetchFailed(let isServerError): ...
    case .updateQuestion(let question):   contentView.updateQuestion(question)
    case .updateTotalPage(let totalPage): contentView.updateTotalPage(totalPage)
    case .updateTime(let limit, let rem): contentView.updateProgress(timeLimit: limit, timeRemaining: rem)
    case .updateOptionState(let idx, let sel): contentView.updateOptionState(at: idx, isSelected: sel)
    case .setButtonVisibility(let v):     contentView.setButtonsVisibility(isVisible: v)
    case .alterButtonText:                contentView.alterButtonText()
    case .moveToDailyResult:              coordinator?.showDailyResult()
    case .moveToHomeView:                 coordinator?.quitDaily()
    case .popSubmitAlert:                 present(submitAlertViewController, animated: true)
    case .cancelAlert:                    submitAlertViewController.dismiss(animated: true)
    case .submitSuccess:                  submitAlertViewController.dismiss(animated: true); removeNavigationItems()
    case .submitFailed:                   submitAlertViewController.dismiss(animated: true); showOneButtonAlert(...)
    }
}
```

## 파일 구조 변화

```
DailyTest/
├── View/
│   ├── DailyTestView.swift          ← 신규
│   ├── DailyTestFooterView.swift    (기존 유지)
│   └── DailyTestTimerLabel.swift    (기존 유지)
└── ViewController/
    └── DailyTestViewController.swift (기존, 대폭 축소)
```

## 테스트 영향

- 기존 SnapshotTest 없음 (DailyTest는 snapshot test 미작성)
- Unit test 없음 (ViewModel 테스트만 있음)
- 공개 인터페이스 변경 없음 → 테스트 수정 불필요

## 커밋 계획

1. `refactor: DailyTestView 추출 — 서브뷰 + 레이아웃 + UI 업데이트`
2. `refactor: DailyTestViewController bind/handleOutput 분리`
