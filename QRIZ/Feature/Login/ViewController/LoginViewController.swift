//
//  LoginViewController.swift
//  QRIZ
//
//  Created by KSH on 12/19/24.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: LoginMainView
    private let loginVM: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - initialize
    
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
            .map { LoginViewModel.Input.socialLoginSelected($0) }
        
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
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isLoginButtonEnabled(let isEnabled):
                    self.rootView.loginInputView.setLoginButtonEnabled(isEnabled)
                }
            }
            .store(in: &cancellables)
    }
}
