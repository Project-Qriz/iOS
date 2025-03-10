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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() -> UIViewController {
        let loginVM = LoginViewModel()
        let loginVC = LoginViewController(loginVM: loginVM)
        loginVC.coordinator = self
        navigationController.viewControllers = [loginVC]
        return navigationController
    }
    
    func showSignUp() {
        let signUpCoordinator = SignUpCoordinatorImpl(navigationController: navigationController)
        signUpCoordinator.delegate = self
        childCoordinators.append(signUpCoordinator)
        _ = signUpCoordinator.start()
    }
    
    func showFindId() {
        let findIDVM = FindIDViewModel()
        let findIDVC = FindIDViewController(findIDInputVM: findIDVM)
        navigationController.pushViewController(findIDVC, animated: true)
    }
    
    func showFindPassword() {
        let findPWVM = FindPasswordVerificationViewModel()
        let findPWVC = FindPasswordVerificationViewController(findPasswordVerificationVM: findPWVM)
        navigationController.pushViewController(findPWVC, animated: true)
    }
}

// MARK: - SignUpCoordinatorDelegate

extension LoginCoordinatorImp: SignUpCoordinatorDelegate {
    func didFinishSignUp(_ coordinator: SignUpCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController.popViewController(animated: true)
    }
}
