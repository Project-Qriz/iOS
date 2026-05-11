import UIKit
import DesignSystem
import Combine
import QRIZNetwork
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
        setButtonActions()
        setAlertButtonActions()
        input.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
                case .updateQuestion(let question, let selectedOption):
                    updateQuestionUI(question: question, selectedOption: selectedOption)
                case .updateTotalNum(let num):
                    totalNum = num
                case .updateTime(let timeLimit, let timeRemaining):
                    previewTestView.updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
                case .updateOptionState(let idx, let isSelected):
                    previewTestView.updateOptionState(at: idx, isSelected: isSelected)
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

        previewTestView.optionTappedPublisher
            .sink { [weak self] idx in self?.input.send(.optionTapped(idx)) }
            .store(in: &cancellables)
    }

    func setNavigationItem() {
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

    func updateQuestionUI(question: QuestionData, selectedOption: Int?) {
        previewTestView.updateQuestion(question)
        if let selectedOption { previewTestView.updateOptionState(at: selectedOption, isSelected: true) }
        previewTestView.pageIndicatorLabel.setCurrentPage(question.questionNumber)
        previewTestView.pageIndicatorLabel.setTotalPage(totalNum)
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
