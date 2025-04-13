//
//  LoginCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/21/25.
//

import UIKit

@MainActor
protocol LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate? { get set }
    func showSignUp()
    func showFindId()
    func showFindPassword()
    func showResetPassword()
    func popToRootViewController()
}

@MainActor
protocol LoginCoordinatorDelegate: AnyObject {
    func didLogin(_ coordinator: LoginCoordinator)
}

@MainActor
final class LoginCoordinatorImp: LoginCoordinator {
    
    weak var delegate: LoginCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []
    private let loginService: LoginService
    private let signUpService: SignUpService
    private let accountRecoveryService: AccountRecoveryService
    
    init(
        navigationController: UINavigationController,
        loginService: LoginService,
        authService: SignUpService,
        accountRecoveryService: AccountRecoveryService
    ) {
        self.navigationController = navigationController
        self.loginService = loginService
        self.signUpService = authService
        self.accountRecoveryService = accountRecoveryService
    }
    
    func start() -> UIViewController {
        let loginVM = LoginViewModel(loginService: loginService)
        let loginVC = LoginViewController(loginVM: loginVM)
        loginVC.coordinator = self
        navigationController.viewControllers = [loginVC]
        return navigationController
    }
    
    func showSignUp() {
        let signUpCoordinator = SignUpCoordinatorImpl(
            navigationController: navigationController,
            signUpService: signUpService
        )
        signUpCoordinator.delegate = self
        childCoordinators.append(signUpCoordinator)
        _ = signUpCoordinator.start()
    }
    
    func showFindId() {
        let findIDVM = FindIDViewModel(accountRecoveryService: accountRecoveryService)
        let findIDVC = FindIDViewController(findIDInputVM: findIDVM)
        findIDVC.coordinator = self
        navigationController.pushViewController(findIDVC, animated: true)
    }
    
    func showFindPassword() {
        let findPasswordVerificationVM = FindPasswordVerificationViewModel(accountRecoveryService: accountRecoveryService)
        let findPasswordVerificationVC = FindPasswordVerificationViewController(
            findPasswordVerificationVM: findPasswordVerificationVM
        )
        findPasswordVerificationVC.coordinator = self
        navigationController.pushViewController(findPasswordVerificationVC, animated: true)
    }
    
    func showResetPassword() {
        let resetPasswordVM = ResetPasswordViewModel(accountRecoveryService: accountRecoveryService)
        let resetPasswordVC = ResetPasswordViewController(resetPasswordVM: resetPasswordVM)
        resetPasswordVC.coordinator = self
        navigationController.pushViewController(resetPasswordVC, animated: true)
    }
    
    func popToRootViewController() {
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - SignUpCoordinatorDelegate

extension LoginCoordinatorImp: SignUpCoordinatorDelegate {
    func didFinishSignUp(_ coordinator: SignUpCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController.popToRootViewController(animated: true)
    }
}
