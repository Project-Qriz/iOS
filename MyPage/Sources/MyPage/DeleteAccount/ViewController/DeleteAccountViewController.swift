import UIKit
import DesignSystem
import Combine

final class DeleteAccountViewController: UIViewController {

    // MARK: - Enums

    private enum Attributes {
        static let navigationTitle: String = "회원 탈퇴"
    }

    // MARK: - Properties

    weak var coordinator: MyPageNavigating?
    private let rootView: DeleteAccountMainView
    private let viewModel: DeleteAccountViewModel
    private let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: DeleteAccountViewModel) {
        self.rootView = DeleteAccountMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
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
        setNavigationBarTitle(title: Attributes.navigationTitle, textColor: .coolNeutral800)
    }

    // MARK: - Methods

    private func bind() {
        let didTapDeleteButton  = rootView.deleteTapPublisher
            .map { DeleteAccountViewModel.Input.didTapDelete }

        let input = inputSubject
            .merge(with: didTapDeleteButton)
            .eraseToAnyPublisher()

        let output = viewModel.transform(input: input)

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .showConfirmAlert:
                    self.coordinator?.showConfirmDeleteAlert { [weak self] in
                        self?.inputSubject.send(.didConfirmDelete)
                    }

                case .deletionSucceeded:
                    coordinator?.handleDeletionSucceeded()

                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &self.cancellables)
                }
            }
            .store(in: &cancellables)

    }
}
