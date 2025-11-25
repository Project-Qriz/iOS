//
//  LoginViewController.swift
//  QRIZ
//
//  Created by KSH on 12/19/24.
//

import UIKit
import Combine
import GoogleSignIn

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: LoginCoordinator?
    private let rootView: LoginMainView
    private let loginVM: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
        self.rootView = LoginMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        observe()
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let idInput = rootView.loginInputView.idTextPublisher
            .map { LoginViewModel.Input.idTextChanged($0) }
        
        let passwordInput = rootView.loginInputView.passwordTextPublisher
            .map { LoginViewModel.Input.passwordTextChanged($0) }
        
        let loginButtonInput = rootView.loginInputView.loginButtonTapPublisher
            .map { LoginViewModel.Input.loginButtonTapped }
        
        let accountActionInput = rootView.accountOptionsView.accountActionTapPublisher
            .map { LoginViewModel.Input.accountActionSelected($0) }
        
        let socialLoginInput = rootView.socialLoginView.socialLoginPublisher
            .map { [weak self] social -> LoginViewModel.Input in
                let isPresentingProvider = (social == .google) || (social == .apple)
                let presenter = isPresentingProvider ? self : nil
                return .socialLoginSelected(social, presenter: presenter)
            }
        
        let input = Publishers.Merge5(
            idInput,
            passwordInput,
            loginButtonInput,
            accountActionInput,
            socialLoginInput
        )
            .eraseToAnyPublisher()
        
        let output = loginVM.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isLoginButtonEnabled(let isEnabled):
                    self.rootView.loginInputView.setLoginButtonEnabled(isEnabled)
                    
                case .showErrorAlert(let errorTitle, let errorDescription):
                    self.showOneButtonAlert(with: errorTitle, for: errorDescription, storingIn: &cancellables)
                    
                case .navigateToAccountAction(let accountAction):
                    switch accountAction {
                    case .findId: self.coordinator?.showFindId()
                    case .findPassword: self.coordinator?.showFindPassword()
                    case .signUp: self.coordinator?.showSignUp()
                    }
                    
                case .loginSucceeded:
                    if let loginCoordinator = self.coordinator {
                        loginCoordinator.delegate?.didLogin(loginCoordinator)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
    }
}
