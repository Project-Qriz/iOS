import UIKit
import Combine
import DesignSystem
import QRIZUtils
import ExamKit

final class ExamTestViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: (any ExamNavigating)?
    private let rootView: ExamTestView
    private let viewModel: ExamTestViewModel
    private let inputSubject = PassthroughSubject<ExamTestViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let submitAlertViewController = TwoButtonCustomAlertViewController(
        title: "제출하시겠습니까?",
        description: "확인 버튼을 누르면 다시 돌아올 수 없어요."
    )

    // MARK: - Initialization

    init(viewModel: ExamTestViewModel) {
        self.rootView = ExamTestView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupNavigationItems()
        setupAlertButtonActions()
        AnalyticsManager.shared.log(.screenView(.examTest))
        inputSubject.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputSubject.send(.viewDidAppear)
    }

    // MARK: - Methods

    private func bind() {
        let optionTapped = rootView.optionTappedPublisher
            .map { ExamTestViewModel.Input.didTapOption(optionIdx: $0) }
        let prevTapped = rootView.prevButtonTappedPublisher
            .map { ExamTestViewModel.Input.didTapPrevButton }
        let nextTapped = rootView.nextButtonTappedPublisher
            .map { ExamTestViewModel.Input.didTapNextButton }
        let input = inputSubject
            .merge(with: optionTapped, prevTapped, nextTapped)
            .eraseToAnyPublisher()

        let output = viewModel.transform(input: input)

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .fetchFailed(let isServerError):
                    submitAlertViewController.dismiss(animated: true)
                    if isServerError {
                        showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &cancellables)
                    } else {
                        showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &cancellables)
                    }
                case .updateQuestion(let question):
                    rootView.updateQuestion(question)
                case .updateTotalPage(let totalPage):
                    rootView.updateTotalPage(totalPage)
                case .updateTime(let timeLimit, let timeRemaining):
                    rootView.updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
                case .updateOptionState(let optionIdx, let isSelected):
                    rootView.updateOptionState(at: optionIdx, isSelected: isSelected)
                case .updatePrevButton(let isVisible):
                    rootView.updatePrevButton(isVisible: isVisible)
                case .updateNextButton(let isVisible, let isTextSubmit):
                    rootView.updateNextButton(isVisible: isVisible, isTextSubmit: isTextSubmit)
                case .moveToExamResult(let examId):
                    removeNavigationItems()
                    submitAlertViewController.dismiss(animated: true) { [weak self] in
                        self?.coordinator?.showExamResult(examId: examId)
                    }
                case .moveToExamList:
                    removeNavigationItems()
                    coordinator?.quitExam()
                case .popSubmitAlert:
                    present(submitAlertViewController, animated: true)
                case .cancelAlert:
                    submitAlertViewController.dismiss(animated: true)
                case .submitSuccess:
                    break
                case .submitFailed:
                    submitAlertViewController.dismiss(animated: true)
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &cancellables)
                }
            }
            .store(in: &cancellables)
    }

    private func setupNavigationItems() {
        let cancelButtonItem = UIBarButtonItem(
            title: "취소",
            style: .done,
            target: self,
            action: #selector(didTapCancelButton)
        )
        cancelButtonItem.tintColor = .coolNeutral800
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: rootView.timeLabel),
            UIBarButtonItem(customView: rootView.totalTimeRemainingLabel),
        ]
    }

    private func setupAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            self?.inputSubject.send(.didTapAlertSubmit)
        }
        let cancelAction = UIAction { [weak self] _ in
            self?.inputSubject.send(.didTapAlertCancel)
        }
        submitAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }

    @objc private func didTapCancelButton() {
        inputSubject.send(.didTapCancelButton)
    }

    private func removeNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
    }
}
