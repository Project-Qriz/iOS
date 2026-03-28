# DailyLearn 리팩토링 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `DailyLearnViewController`에서 레이아웃 책임을 `DailyLearnView`로 분리하고, 버그 5건을 수정한다.

**Architecture:** `DailyLearnView`(UIView)가 모든 레이아웃과 UI 상태 업데이트를 담당하고, `DailyLearnViewController`는 ViewModel 바인딩과 CollectionView 데이터소스만 담당한다. `DailyNavigating`에 `finishDaily()`를 추가해 VC가 coordinator 내부를 직접 참조하는 패턴을 제거한다.

**Tech Stack:** UIKit, Combine, Swift Package Manager

---

## 파일 구조

| 작업 | 경로 |
|---|---|
| 삭제 | `Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnSectionTitleLabel.swift` |
| 삭제 | `Features/Daily/Sources/Daily/DailyLearn/View/StudyContentView.swift` |
| 신규 | `Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnView.swift` |
| 수정 | `Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift` |
| 수정 | `Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift` |
| 수정 | `Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift` |

---

### Task 1: 미사용 파일 삭제

**Files:**
- Delete: `Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnSectionTitleLabel.swift`
- Delete: `Features/Daily/Sources/Daily/DailyLearn/View/StudyContentView.swift`

- [ ] **Step 1: 파일 삭제**

```bash
rm Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnSectionTitleLabel.swift
rm Features/Daily/Sources/Daily/DailyLearn/View/StudyContentView.swift
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

> `DailyLearnSectionTitleLabel`은 `DailyLearnViewController`에서만 사용된다. 다음 Task에서 `DailyLearnViewController`를 교체하므로 지금 삭제해도 일시적으로 빌드 에러가 발생한다. 에러가 발생하면 Task 3 완료 후 재확인한다.

- [ ] **Step 3: 커밋**

```bash
git add -A
git commit -m "remove: 미사용 DailyLearnSectionTitleLabel, StudyContentView 삭제"
```

---

### Task 2: DailyLearnView 작성

**Files:**
- Create: `Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnView.swift`

아래 코드를 그대로 작성한다. 버그 1·2·3·4를 수정한 최종 버전이다.

- [ ] **Step 1: DailyLearnView.swift 생성**

`Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnView.swift`:

```swift
import UIKit
import DesignSystem
import QRIZUtils

final class DailyLearnView: UIView {

    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customBlue50
        return scrollView
    }()
    private let scrollInnerView: UIView = .init()
    private let studyContentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    let studyCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    private let relatedTestTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "관련된 테스트"
        return label
    }()
    private let testSubtextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let testNavigator: TestNavigatorButton = .init()

    var onTestNavigatorTap: (() -> Void)?

    // Stored constraints (Bug 3 fix)
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var testNavigatorHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        backgroundColor = .customBlue50
        // Cell 등록을 View에서 처리 (ViewController 불필요)
        studyCollectionView.register(StudyContentCell.self, forCellWithReuseIdentifier: StudyContentCell.identifier)
        // Bug 4 fix: gestureRecognizer를 init에서 1회만 등록
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTestNavigatorTap))
        testNavigator.addGestureRecognizer(tap)
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyLearnView")
    }

    // MARK: - Methods

    /// setTitleLabels / setTestSubtextLabel / setNavigatorButton / setNavigatorButtonHeight 역할을 통합
    func configure(state: DailyTestState, type: DailyLearnType, score: Double?) {
        setTitleLabels(type: type)
        setTestSubtextLabel(state: state)
        testNavigator.setDailyUI(state: state, type: type, score: score)
        setNavigatorButtonHeight(state: state)
    }

    /// updateCollectionViewHeight() 대체 메서드. layoutIfNeeded() 호출 필수.
    func reloadConcepts() {
        studyCollectionView.reloadData()
        studyCollectionView.layoutIfNeeded()
        // Bug 3 fix: stored constraint 패턴
        collectionViewHeightConstraint?.isActive = false
        collectionViewHeightConstraint = studyCollectionView.heightAnchor.constraint(
            equalToConstant: studyCollectionView.contentSize.height
        )
        collectionViewHeightConstraint?.isActive = true
    }

    @objc private func handleTestNavigatorTap() {
        onTestNavigatorTap?()
    }

    private func setTitleLabels(type: DailyLearnType) {
        switch type {
        case .daily:
            studyContentTitleLabel.text = "오늘 공부할 내용"
        case .weekly:
            studyContentTitleLabel.text = "주간 복습 내용"
        case .monthly:
            studyContentTitleLabel.text = "종합 복습 내용"
        }
    }

    private func setTestSubtextLabel(state: DailyTestState) {
        switch state {
        case .unavailable:
            testSubtextLabel.text = "이전 테스트를 학습 완료했는지 확인해주세요!"
        case .zeroAttempt:
            testSubtextLabel.text = "아래의 테스트를 학습 완료해야만 다음 데일리 테스트를 진행할 수 있습니다!"
        case .passed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        case .retestRequired:
            testSubtextLabel.text = "점수 미달인 경우 재시험을 볼 수 있습니다."
        case .failed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        }
    }

    /// testNavigatorHeightConstraint stored constraint 패턴 유지
    private func setNavigatorButtonHeight(state: DailyTestState) {
        let buttonHeight: CGFloat = state == .retestRequired ? 153.0 : 116.0
        testNavigatorHeightConstraint?.isActive = false
        testNavigatorHeightConstraint = testNavigator.heightAnchor.constraint(equalToConstant: buttonHeight)
        testNavigatorHeightConstraint?.isActive = true
    }
}

// MARK: - Auto Layout
extension DailyLearnView {
    private func addViews() {
        addSubview(scrollView)
        scrollView.addSubview(scrollInnerView)
        scrollInnerView.addSubview(studyContentTitleLabel)
        scrollInnerView.addSubview(studyCollectionView)
        scrollInnerView.addSubview(relatedTestTitleLabel)
        scrollInnerView.addSubview(testSubtextLabel)
        scrollInnerView.addSubview(testNavigator)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollInnerView.translatesAutoresizingMaskIntoConstraints = false
        studyContentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        studyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        relatedTestTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        testSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        testNavigator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            scrollInnerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollInnerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollInnerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollInnerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollInnerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            studyContentTitleLabel.topAnchor.constraint(equalTo: scrollInnerView.topAnchor, constant: 25),
            studyContentTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),

            studyCollectionView.topAnchor.constraint(equalTo: studyContentTitleLabel.bottomAnchor, constant: 17),
            studyCollectionView.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            studyCollectionView.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),

            // Bug 2 fix: scrollView → scrollInnerView
            relatedTestTitleLabel.topAnchor.constraint(equalTo: studyCollectionView.bottomAnchor, constant: 32),
            relatedTestTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            relatedTestTitleLabel.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),

            // Bug 1 fix: constant 18 → -18
            testSubtextLabel.topAnchor.constraint(equalTo: relatedTestTitleLabel.bottomAnchor, constant: 19),
            testSubtextLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            testSubtextLabel.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),

            testNavigator.topAnchor.constraint(equalTo: testSubtextLabel.bottomAnchor, constant: 18),
            testNavigator.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            testNavigator.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),
            testNavigator.bottomAnchor.constraint(equalTo: scrollInnerView.bottomAnchor, constant: -100),
        ])
    }
}
```

- [ ] **Step 2: 커밋**

```bash
git add Features/Daily/Sources/Daily/DailyLearn/View/DailyLearnView.swift
git commit -m "feat: DailyLearnView 추출 및 레이아웃 버그 수정"
```

---

### Task 3: DailyLearnViewController 슬림화

**Files:**
- Modify: `Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift`

아래 코드로 전체 교체한다. Bug 5 수정 포함.

- [ ] **Step 1: DailyLearnViewController.swift 교체**

`Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift`:

```swift
import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class DailyLearnViewController: UIViewController {

    // MARK: - Properties
    private var dailyLearnView: DailyLearnView { view as! DailyLearnView }

    private let retestAlertViewController: TwoButtonCustomAlertViewController = .init(
        title: "시험을 다시 보겠습니까?",
        description: """
        이미 한번 봤던 시험입니다.
        만약 미달인 경우 재시험의 기회가 없습니다.
        """)

    private let viewModel: DailyLearnViewModel
    private let input: PassthroughSubject<DailyLearnViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    weak var coordinator: (any DailyNavigating)?

    private var conceptArr: [(Int, String)] = []

    // MARK: - Initializer
    init(dailyLearnViewModel: DailyLearnViewModel) {
        self.viewModel = dailyLearnViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyLearnViewController")
    }

    // MARK: - Methods
    override func loadView() {
        view = DailyLearnView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setCollectionViewDataSourceAndDelegate()
        setTestNavigatorAction()
        setAlertButtonActions()
        bind()
        input.send(.viewDidLoad)
        tabBarController?.tabBar.isHidden = true
    }

    private func setCollectionViewDataSourceAndDelegate() {
        dailyLearnView.studyCollectionView.dataSource = self
        dailyLearnView.studyCollectionView.delegate = self
    }

    private func setTestNavigatorAction() {
        dailyLearnView.onTestNavigatorTap = { [weak self] in
            self?.input.send(.testNavigatorButtonClicked)
        }
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchSuccess(let state, let type, let score):
                    dailyLearnView.configure(state: state, type: type, score: score)
                case .fetchFailed(let isServerError):
                    if isServerError {
                        showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &subscriptions)
                    } else {
                        showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                    }
                case .updateContent(let conceptArr):
                    self.conceptArr = conceptArr
                    dailyLearnView.reloadConcepts()
                case .moveToDailyTest:
                    coordinator?.showDailyTest()
                case .showRetestAlert:
                    present(retestAlertViewController, animated: true)
                case .moveToDailyTestResult:
                    coordinator?.showDailyResult()
                case .moveToConcept(let chapter, let conceptItem):
                    coordinator?.showConcept(chapter: chapter, conceptItem: conceptItem)
                case .dismissAlert:
                    retestAlertViewController.dismiss(animated: true)
                case .moveToHome:
                    // Bug 5 fix: coordinator 내부(delegate) 직접 접근 제거
                    tabBarController?.tabBar.isHidden = false
                    coordinator?.finishDaily()
                }
            }
            .store(in: &subscriptions)
    }

    private func setAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            self?.input.send(.alertMoveClicked)
        }
        let cancelAction = UIAction { [weak self] _ in
            self?.input.send(.alertCancelClicked)
        }
        retestAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }

    private func setNavigationItems() {
        let titleView = UILabel()
        titleView.text = "오늘의 공부"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        navigationItem.titleView = titleView

        let backImage = UIImage(systemName: "chevron.left")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRectMake(0, 0, 28, 28))
        button.setImage(backImage, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.input.send(.backButtonClicked)
        }, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension DailyLearnViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StudyContentCell.identifier,
            for: indexPath
        ) as? StudyContentCell else {
            print("Failed to create StudyContentCell")
            return UICollectionViewCell()
        }
        cell.setLabelText(
            titleText: "\(SurveyCheckList.list[conceptArr[indexPath.item].0 - 1])",
            descriptionText: "\(conceptArr[indexPath.item].1)"
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conceptArr.count
    }
}

extension DailyLearnViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 116)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if conceptArr.count != 0 {
            input.send(.toConceptClicked(conceptIdx: conceptArr[indexPath.row].0))
        }
    }
}
```

- [ ] **Step 2: 커밋**

```bash
git add Features/Daily/Sources/Daily/DailyLearn/ViewController/DailyLearnViewController.swift
git commit -m "refactor: DailyLearnViewController 슬림화 및 coordinator delegate 직접 호출 제거"
```

---

### Task 4: finishDaily() 추가

**Files:**
- Modify: `Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift` — `DailyNavigating` 프로토콜에 `finishDaily()` 추가 (기존 `quitDaily()` 아래)
- Modify: `Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift` — `quitDaily()` 구현 아래에 `finishDaily()` 구현 추가

- [ ] **Step 1: DailyNavigating에 finishDaily() 추가**

`Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift`의 `DailyNavigating` 프로토콜에 한 줄 추가:

```swift
// 변경 전
@MainActor
protocol DailyNavigating: DailyCoordinator {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()
}

// 변경 후
@MainActor
protocol DailyNavigating: DailyCoordinator {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()       // DailyTest/DailyResult → DailyLearn 복귀
    func finishDaily()     // DailyLearn 뒤로가기 → Daily 세션 전체 종료
}
```

- [ ] **Step 2: DailyCoordinatorImpl에 finishDaily() 구현 추가**

`Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift`의 `quitDaily()` 아래에 추가:

```swift
// 기존 quitDaily() 바로 아래에 추가
func finishDaily() {
    delegate?.didQuitDaily(self)
}
```

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 커밋**

```bash
git add Features/Daily/Sources/Daily/Coordinator/DailyCoordinator.swift
git add Features/Daily/Sources/Daily/Coordinator/DailyCoordinatorImpl.swift
git commit -m "feat: DailyNavigating에 finishDaily() 추가"
```
