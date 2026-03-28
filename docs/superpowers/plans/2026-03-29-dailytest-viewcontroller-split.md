# DailyTestViewController 분리 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `DailyTestViewController`에서 UI 코드를 `DailyTestView`로 추출하고, `bind()`의 배선과 처리를 분리하여 ViewController를 순수 조율자로 축소한다.

**Architecture:** `DailyTestView: UIView`가 서브뷰, 레이아웃, UI 업데이트 메서드, `userInputPublisher`를 소유. `DailyTestViewController`는 `loadView()`로 뷰를 설정하고, `bind()`는 배선만, `handleOutput()`은 처리만 담당.

**Tech Stack:** UIKit, Combine, Swift 5.0, iOS 15.0+

---

## 파일 구조

| 파일 | 변경 |
|------|------|
| `Features/Daily/Sources/Daily/DailyTest/View/DailyTestView.swift` | 신규 생성 |
| `Features/Daily/Sources/Daily/DailyTest/ViewController/DailyTestViewController.swift` | 대폭 수정 |

---

### Task 1: DailyTestView 생성

**Files:**
- Create: `Features/Daily/Sources/Daily/DailyTest/View/DailyTestView.swift`

- [ ] **Step 1: DailyTestView 파일 생성**

`Features/Daily/Sources/Daily/DailyTest/View/DailyTestView.swift`를 아래 내용으로 작성:

```swift
//
//  DailyTestView.swift
//  QRIZ
//

import UIKit
import DesignSystem
import Combine
import ExamKit

final class DailyTestView: UIView {

    // MARK: - Properties

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()

    let progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .customBlue500
        view.trackTintColor = .coolNeutral200
        return view
    }()

    private let footerView: DailyTestFooterView = .init()
    private let contentsView: TestContentsView = .init()
    private let timerLabel: DailyTestTimerLabel = .init()

    var timerBarButtonItem: UIBarButtonItem {
        UIBarButtonItem(customView: timerLabel)
    }

    var userInputPublisher: AnyPublisher<DailyTestViewModel.Input, Never> {
        let optionTapped = contentsView.optionTappedPublisher
            .map { DailyTestViewModel.Input.optionTapped(optionIdx: $0) }
        return footerView.input
            .merge(with: optionTapped)
            .eraseToAnyPublisher()
    }

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestView")
    }

    // MARK: - Methods

    func updateQuestion(_ question: QuestionData) {
        contentsView.updateQuestion(question)
        footerView.updateCurPage(curPage: question.questionNumber)
        scrollToTop()
    }

    func updateTotalPage(_ totalPage: Int) {
        footerView.updateTotalPage(totalPage: totalPage)
    }

    func updateProgress(timeLimit: Int, timeRemaining: Int) {
        timerLabel.updateTime(timeRemaining: timeRemaining)
        progressView.progress = Float(timeLimit - timeRemaining) / Float(timeLimit)
    }

    func updateOptionState(at optionIdx: Int, isSelected: Bool) {
        contentsView.setOptionState(at: optionIdx, isSelected: isSelected)
    }

    func setButtonsVisibility(isVisible: Bool) {
        footerView.setButtonsVisibility(isVisible: isVisible)
    }

    func alterButtonText() {
        footerView.alterButtonText()
    }

    private func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: false)
    }
}

// MARK: - Auto Layout

extension DailyTestView {
    private func addViews() {
        addSubview(progressView)
        addSubview(scrollView)
        scrollView.addSubview(contentsView)
        addSubview(footerView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 132),

            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            scrollView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            contentsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentsView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
}
```

- [ ] **Step 2: 커밋**

```bash
git add Features/Daily/Sources/Daily/DailyTest/View/DailyTestView.swift
git commit -m "refactor: DailyTestView 추출 — 서브뷰, 레이아웃, UI 업데이트"
```

---

### Task 2: DailyTestViewController 리팩토링

**Files:**
- Modify: `Features/Daily/Sources/Daily/DailyTest/ViewController/DailyTestViewController.swift`

- [ ] **Step 1: DailyTestViewController 전체 교체**

파일 전체를 아래 내용으로 교체:

```swift
//
//  DailyTestViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class DailyTestViewController: UIViewController {

    // MARK: - Properties

    private var contentView: DailyTestView!
    private let viewModel: DailyTestViewModel
    private let input: PassthroughSubject<DailyTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    private let submitAlertViewController = TwoButtonCustomAlertViewController(
        title: "제출하시겠습니까?",
        description: "확인 버튼을 누르면 다시 돌아올 수 없어요."
    )

    weak var coordinator: (any DailyNavigating)?

    // MARK: - Initializers

    init(viewModel: DailyTestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestViewController")
    }

    // MARK: - Lifecycle

    override func loadView() {
        contentView = DailyTestView()
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setAlertButtonActions()
        bind()
        input.send(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }

    // MARK: - Bind

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
}

// MARK: - Output Handling

extension DailyTestViewController {
    private func handleOutput(_ event: DailyTestViewModel.Output) {
        switch event {
        case .fetchFailed(let isServerError):
            if isServerError {
                showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &subscriptions)
            } else {
                showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
            }
        case .updateQuestion(let question):
            contentView.updateQuestion(question)
        case .updateTotalPage(let totalPage):
            contentView.updateTotalPage(totalPage)
        case .updateTime(let timeLimit, let timeRemaining):
            contentView.updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
        case .updateOptionState(let optionIdx, let isSelected):
            contentView.updateOptionState(at: optionIdx, isSelected: isSelected)
        case .setButtonVisibility(let isVisible):
            contentView.setButtonsVisibility(isVisible: isVisible)
        case .alterButtonText:
            contentView.alterButtonText()
        case .moveToDailyResult:
            coordinator?.showDailyResult()
        case .moveToHomeView:
            coordinator?.quitDaily()
        case .popSubmitAlert:
            present(submitAlertViewController, animated: true)
        case .cancelAlert:
            submitAlertViewController.dismiss(animated: true)
        case .submitSuccess:
            submitAlertViewController.dismiss(animated: true)
            removeNavigationItems()
        case .submitFailed:
            submitAlertViewController.dismiss(animated: true)
            showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
        }
    }
}

// MARK: - Navigation Items

extension DailyTestViewController {
    private func setNavigationItems() {
        let cancelButtonItem = UIBarButtonItem(
            title: "취소",
            style: .done,
            target: self,
            action: #selector(moveToHome)
        )
        cancelButtonItem.tintColor = .coolNeutral800
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = contentView.timerBarButtonItem
    }

    private func removeNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }

    @objc private func moveToHome() {
        input.send(.cancelButtonClicked)
    }
}

// MARK: - Alert

extension DailyTestViewController {
    private func setAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.input.send(.alertSubmitButtonClicked)
        }
        let cancelAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.input.send(.alertCancelButtonClicked)
        }
        submitAlertViewController.setupButtonActions(
            confirmAction: confirmAction,
            cancelAction: cancelAction
        )
    }
}
```

- [ ] **Step 2: 빌드 확인**

Xcode에서 `Daily` 타겟 빌드. 에러 없이 통과해야 함.

- [ ] **Step 3: 커밋**

```bash
git add Features/Daily/Sources/Daily/DailyTest/ViewController/DailyTestViewController.swift
git commit -m "refactor: DailyTestViewController bind/handleOutput 분리 및 DailyTestView 사용"
```
