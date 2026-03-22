import UIKit
import DesignSystem
import Combine
import Network
import QRIZUtils
import ExamKit

final class PreviewTestViewController: UIViewController {

    // MARK: - Properties

    private let previewTestView = PreviewTestView()
    private var totalNum: Int = 0

    private let submitAlertViewController = TwoButtonCustomAlertViewController(
        title: "제출하시겠습니까?",
        description: "확인 버튼을 누르면 다시 돌아올 수 없어요."
    )

    private let submitRetryAlertViewController = TwoButtonCustomAlertViewController(
        title: "제출에 실패했습니다.",
        description: "다시 시도하시겠습니까?"
    )

    private let viewModel: PreviewTestViewModel
    private let input = PassthroughSubject<PreviewTestViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let onNavigateToResult: () -> Void
    private let onNavigateToHome: () -> Void

    // MARK: - Initializer

    init(
        viewModel: PreviewTestViewModel,
        onNavigateToResult: @escaping () -> Void,
        onNavigateToHome: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onNavigateToResult = onNavigateToResult
        self.onNavigateToHome = onNavigateToHome
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = previewTestView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setNavigationItem()
        setOptionActions()
        setButtonActions()
        setAlertButtonActions()
        input.send(.viewDidLoad)
    }
}

// MARK: - Bind

private extension PreviewTestViewController {

    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .updateQuestion(let question, let curNum, let selectedOption):
                    updateQuestionUI(question: question, curNum: curNum, selectedOption: selectedOption)
                case .updateTotalNum(let num):
                    totalNum = num
                case .updateTime(let timeLimit, let timeRemaining):
                    previewTestView.progressView.progress = Float(timeRemaining) / Float(timeLimit)
                    previewTestView.timeLabel.text = timeRemaining.formattedTime
                case .updateOptionState(let idx, let isSelected):
                    setOptionState(idx: idx, isSelected: isSelected)
                case .updateButtonStates(let prevHidden, let nextHidden, let nextTitle):
                    previewTestView.previousButton.isHidden = prevHidden
                    previewTestView.nextButton.isHidden = nextHidden
                    previewTestView.nextButton.updateTitle(nextTitle)
                case .showSubmitAlert:
                    present(submitAlertViewController, animated: true)
                case .dismissSubmitAlert:
                    submitAlertViewController.dismiss(animated: true)
                case .showSubmitRetryAlert:
                    present(submitRetryAlertViewController, animated: true)
                case .showError(let message):
                    showOneButtonAlert(with: message, storingIn: &cancellables)
                case .navigateToResult:
                    onNavigateToResult()
                case .navigateToHome:
                    onNavigateToHome()
                }
            }
            .store(in: &cancellables)
    }

    func setNavigationItem() {
        navigationController?.navigationBar.isHidden = false
        previewTestView.cancelButton.addAction(UIAction { [weak self] _ in
            self?.input.send(.escapeTapped)
        }, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: previewTestView.cancelButton)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: previewTestView.timeLabel),
            UIBarButtonItem(customView: previewTestView.totalTimeRemainingLabel)
        ]
    }

    func setAlertButtonActions() {
        submitAlertViewController.setupButtonActions(
            confirmAction: UIAction { [weak self] _ in self?.input.send(.confirmSubmit) },
            cancelAction: UIAction { [weak self] _ in self?.input.send(.cancelSubmit) }
        )
        submitRetryAlertViewController.setupButtonActions(
            confirmAction: UIAction { [weak self] _ in self?.input.send(.retrySubmit) },
            cancelAction: UIAction { [weak self] _ in self?.submitRetryAlertViewController.dismiss(animated: true) }
        )
    }

    func updateQuestionUI(question: PreviewTestListQuestion, curNum: Int, selectedOption: Int?) {
        previewTestView.questionNumberLabel.text = String(format: "%02d.", curNum)
        previewTestView.questionTitleLabel.attributedText = NSAttributedString(text: question.question, lineSpacing: 4)
        setOptionsString(question.options.map(\.content))
        resetOptionStates()
        if let selectedOption { setOptionState(idx: selectedOption, isSelected: true) }
        previewTestView.pageIndicatorLabel.setCurrentPage(curNum)
        previewTestView.pageIndicatorLabel.setTotalPage(totalNum)
    }
}

// MARK: - Options

private extension PreviewTestViewController {

    func setOptionsString(_ options: [String]) {
        zip(previewTestView.optionLabels, options).forEach { label, content in
            label.setOptionString(content)
        }
    }

    func resetOptionStates() {
        previewTestView.optionLabels.forEach { $0.setOptionState(isSelected: false) }
    }

    func setOptionActions() {
        for (index, optionLabel) in previewTestView.optionLabels.enumerated() {
            optionLabel.isUserInteractionEnabled = true
            optionLabel.tag = index + 1
            optionLabel.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(didTapOption(_:)))
            )
        }
    }

    @objc func didTapOption(_ sender: UITapGestureRecognizer) {
        guard let idx = sender.view?.tag else { return }
        input.send(.optionTapped(idx))
    }

    func setOptionState(idx: Int, isSelected: Bool) {
        switch idx {
        case 1...4:
            previewTestView.optionLabels[idx - 1].setOptionState(isSelected: isSelected)
        default:
            assertionFailure("Invalid option index: \(idx)")
        }
    }
}

// MARK: - Buttons

private extension PreviewTestViewController {

    func setButtonActions() {
        previewTestView.previousButton.addAction(UIAction { [weak self] _ in
            self?.input.send(.prevTapped)
        }, for: .touchUpInside)

        previewTestView.nextButton.addAction(UIAction { [weak self] _ in
            self?.input.send(.nextTapped)
        }, for: .touchUpInside)
    }
}
