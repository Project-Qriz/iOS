import UIKit
import DesignSystem
import Combine
import QRIZUtils
import ExamKit

final class ExamTestViewController: UIViewController {

    // MARK: - Properties
    private var contentView: ExamTestView { view as! ExamTestView }

    private let viewModel: ExamTestViewModel
    private let input: PassthroughSubject<ExamTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    private let submitAlertViewController = TwoButtonCustomAlertViewController(
        title: "제출하시겠습니까?",
        description: "확인 버튼을 누르면 다시 돌아올 수 없어요."
    )

    weak var coordinator: (any ExamNavigating)?

    // MARK: - Initializers
    init(viewModel: ExamTestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamTestViewController")
    }

    // MARK: - Methods
    override func loadView() {
        view = ExamTestView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        bind()
        setAlertButtonActions()
        input.send(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }

    private func bind() {
        let optionTapped = contentView.contentsView.optionTappedPublisher.map {
            ExamTestViewModel.Input.optionTapped(optionIdx: $0)
        }
        let prevTapped = contentView.footerView.prevButtonTappedPublisher.map {
            ExamTestViewModel.Input.prevButtonClicked
        }
        let nextTapped = contentView.footerView.nextButtonTappedPublisher.map {
            ExamTestViewModel.Input.nextButtonClicked
        }
        let mergedInput = input.merge(with: optionTapped, prevTapped, nextTapped)

        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed(let isServerError):
                    submitAlertViewController.dismiss(animated: true)
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
                case .updatePrevButton(let isVisible):
                    contentView.updatePrevButton(isVisible: isVisible)
                case .updateNextButton(let isVisible, let isTextSubmit):
                    contentView.updateNextButton(isVisible: isVisible, isTextSubmit: isTextSubmit)
                case .moveToExamResult(let examId):
                    removeNavigationItems()
                    coordinator?.showExamResult(examId: examId)
                case .moveToExamList:
                    removeNavigationItems()
                    coordinator?.quitExam()
                case .popSubmitAlert:
                    present(submitAlertViewController, animated: true)
                case .cancelAlert:
                    submitAlertViewController.dismiss(animated: true)
                case .submitSuccess:
                    submitAlertViewController.dismiss(animated: true)
                case .submitFailed:
                    submitAlertViewController.dismiss(animated: true)
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                }
            }
            .store(in: &subscriptions)
    }

    private func setNavigationItems() {
        let cancelButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(moveToExamList))
        cancelButtonItem.tintColor = .coolNeutral800
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: contentView.timeLabel),
            UIBarButtonItem(customView: contentView.totalTimeRemainingLabel)
        ]
    }

    @objc private func moveToExamList() {
        input.send(.cancelButtonClicked)
    }

    private func removeNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }

    private func setAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertSubmitButtonClicked)
        }

        let cancelAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertCancelButtonClicked)
        }

        submitAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }
}
