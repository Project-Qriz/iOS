import UIKit
import DesignSystem
import Combine

@MainActor
final class PlanChangeViewController: UIViewController {

    // MARK: - Properties

    private let rootView = PlanChangeMainView()
    private let viewModel: PlanChangeViewModel
    private let inputSubject = PassthroughSubject<PlanChangeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: PlanChangeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        inputSubject.send(.viewDidLoad)
    }

    // MARK: - Methods

    private func showResetAlert() {
        let alert = TwoButtonCustomAlertViewController(
            title: "플랜을 초기화 할까요?",
            description: "지금까지의 플랜이 초기화되며,\nDay1부터 다시 시작됩니다.",
            confirmAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.inputSubject.send(.tapResetConfirmed)
                }
            },
            cancelAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        present(alert, animated: true)
    }

    // MARK: - Binding

    private func bind() {
        let planSelected = rootView.planSelectedPublisher
            .map { PlanChangeViewModel.Input.selectPlan($0) }

        let confirmTapped = rootView.confirmTapPublisher
            .map { PlanChangeViewModel.Input.tapConfirm }

        let resetTapped = rootView.resetTapPublisher
            .map { PlanChangeViewModel.Input.tapReset }

        let dismissTapped = rootView.dismissTapPublisher
            .map { PlanChangeViewModel.Input.tapDismiss }

        let input = inputSubject
            .merge(with: planSelected)
            .merge(with: confirmTapped)
            .merge(with: resetTapped)
            .merge(with: dismissTapped)
            .eraseToAnyPublisher()

        viewModel.transform(input: input)
            .receive(on: RunLoop.main)
            .sink { [weak self] output in
                guard let self else { return }

                switch output {
                case .applyCurrentPlan(let plan):
                    rootView.applyCurrentPlan(plan)
                case .applyAvailablePlans(let plans):
                    rootView.applyAvailablePlans(plans)
                case .applySelection(let plan):
                    rootView.applySelection(plan)
                case .setConfirmEnabled(let enabled):
                    rootView.setConfirmEnabled(enabled)
                case .setLoading(let loading):
                    rootView.setLoading(loading)
                case .showResetAlert:
                    showResetAlert()
                case .showAlert(let title, let description):
                    showOneButtonAlert(with: title, for: description, storingIn: &cancellables)
                case .showError(let message):
                    showOneButtonAlert(with: message, storingIn: &cancellables)
                }
            }
            .store(in: &cancellables)
    }
}
