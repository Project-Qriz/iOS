import UIKit
import DesignSystem
import Combine

final class SettingsViewController: UIViewController {

    // MARK: - Enums

    private enum Attributes {
        static let navigationTitle: String = "설정"
    }

    // MARK: - Properties

    weak var coordinator: MyPageNavigating?
    private let rootView: SettingsMainView
    private let viewModel: SettingsViewModel
    private let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialize

    init(viewModel: SettingsViewModel) {
        self.rootView = SettingsMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setNavigationBarTitle(title: Attributes.navigationTitle, textColor: .coolNeutral800)
        inputSubject.send(.viewDidLoad)
    }

    // MARK: - Functions

    private func bind() {
        let viewDidLoad = inputSubject

        let optionTap = rootView.optionTapPublisher
            .compactMap { option -> SettingsViewModel.Input? in
                switch option {
                case .resetPassword: return .didTapResetPassword
                case .logout: return .didTapLogout
                case .deleteAccount: return .didTapDeleteAccount
                }
            }

        let input = viewDidLoad
            .merge(with: optionTap)
            .eraseToAnyPublisher()

        let output = viewModel.transform(input: input)

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }

                switch output {
                case .setupProfile(let userName, let email):
                    rootView.configureProfile(name: userName, email: email)

                case .navigateToResetPassword:
                    coordinator?.showFindPassword()

                case .showLogoutAlert:
                    coordinator?.showLogoutAlert(confirm: { [weak self] in
                        self?.inputSubject.send(.didConfirmLogout)
                    })

                case .navigateToDeleteAccount:
                    coordinator?.showDeleteAccount()

                case .logoutSucceeded:
                    coordinator?.handleLogoutSucceeded()

                case .showErrorAlert(let message):
                    showOneButtonAlert(with: message, storingIn: &cancellables)
                }
            }.store(in: &cancellables)
    }
}
