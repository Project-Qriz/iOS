//
//  LoginViewController.swift
//  QRIZ
//
//  Created by KSH on 12/19/24.
//

import UIKit
import Combine
import QRIZUtils

final class LoginViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: LoginCoordinator?
    private let rootView: LoginMainView
    private let loginVM: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
        self.rootView = LoginMainView()
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
        observe()
    }

    // MARK: - Methods

    private func bind() {
        loginVM.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .isLoginButtonEnabled(let isEnabled):
                    rootView.loginInputView.setLoginButtonEnabled(isEnabled)

                case .showErrorAlert(let title, let description):
                    showOneButtonAlert(with: title, for: description, storingIn: &cancellables)

                case .navigateToAccountAction(let accountAction):
                    switch accountAction {
                    case .findId: coordinator?.showFindId()
                    case .findPassword: coordinator?.showFindPassword()
                    case .signUp: coordinator?.showSignUp()
                    }

                case .loginSucceeded:
                    if let loginCoordinator = coordinator {
                        loginCoordinator.delegate?.didLogin(loginCoordinator)
                    }
                }
            }
            .store(in: &cancellables)

        rootView.loginInputView.idTextPublisher
            .sink { [weak self] text in self?.loginVM.send(.idTextChanged(text)) }
            .store(in: &cancellables)

        rootView.loginInputView.passwordTextPublisher
            .sink { [weak self] text in self?.loginVM.send(.passwordTextChanged(text)) }
            .store(in: &cancellables)

        rootView.loginInputView.loginButtonTapPublisher
            .sink { [weak self] in self?.loginVM.send(.loginButtonTapped) }
            .store(in: &cancellables)

        rootView.accountOptionsView.accountActionTapPublisher
            .sink { [weak self] action in self?.loginVM.send(.accountActionSelected(action)) }
            .store(in: &cancellables)

        rootView.socialLoginView.socialLoginPublisher
            .sink { [weak self] social in
                guard let self else { return }
                let isPresentingProvider = (social == .google) || (social == .apple)
                let presenter: UIViewController? = isPresentingProvider ? self : nil
                loginVM.send(.socialLoginSelected(social, presenter: presenter))
            }
            .store(in: &cancellables)
    }

    private func observe() {
        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in self?.view.endEditing(true) }
            .store(in: &cancellables)
    }
}
