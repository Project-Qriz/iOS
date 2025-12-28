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
    func popToRootViewController()
}

@MainActor
protocol LoginCoordinatorDelegate: AnyObject {
    func didLogin(_ coordinator: LoginCoordinator)
}

@MainActor
final class LoginCoordinatorImpl: LoginCoordinator, NavigationGuard {

    weak var delegate: LoginCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []

    private let loginService: LoginService
    private let userInfoService: UserInfoService
    private let signUpService: SignUpService
    private let accountRecoveryService: AccountRecoveryService

    // NavigationGuard
    var isNavigating: Bool = false
    
    init(
        navigationController: UINavigationController,
        loginService: LoginService,
        userInfoService: UserInfoService,
        signUpService: SignUpService,
        accountRecoveryService: AccountRecoveryService
    ) {
        self.navigationController = navigationController
        self.loginService = loginService
        self.userInfoService = userInfoService
        self.signUpService = signUpService
        self.accountRecoveryService = accountRecoveryService
    }
    
    func start() -> UIViewController {
        let loginVM = LoginViewModel(loginService: loginService, userInfoService: userInfoService)
        let loginVC = LoginViewController(loginVM: loginVM)
        loginVC.coordinator = self
        navigationController.viewControllers = [loginVC]
        return navigationController
    }
    
    func showSignUp() {
        guardNavigation {
            let signUpCoordinator = SignUpCoordinatorImpl(
                navigationController: navigationController,
                signUpService: signUpService
            )
            signUpCoordinator.delegate = self
            childCoordinators.append(signUpCoordinator)
            _ = signUpCoordinator.start()
        }
    }

    func showFindId() {
        guardNavigation {
            let findIDVM = FindIDViewModel(accountRecoveryService: accountRecoveryService)
            let findIDVC = FindIDViewController(findIDInputVM: findIDVM)
            findIDVC.coordinator = self
            navigationController.pushViewController(findIDVC, animated: true)
        }
    }

    func showFindPassword() {
        guardNavigation {
            let recoveryCoordinator = AccountRecoveryCoordinatorImpl(
                navigationController: navigationController,
                accountRecoveryService: accountRecoveryService
            )
            recoveryCoordinator.delegate = self
            childCoordinators.append(recoveryCoordinator)
            _ = recoveryCoordinator.start()
        }
    }
    
    func popToRootViewController() {
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - SignUpCoordinatorDelegate

extension LoginCoordinatorImpl: SignUpCoordinatorDelegate {
    func didFinishSignUp(_ coordinator: SignUpCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - AccountRecoveryCoordinatorDelegate

extension LoginCoordinatorImpl: AccountRecoveryCoordinatorDelegate {
    func didFinishPasswordReset(_ coordinator: AccountRecoveryCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController.popToRootViewController(animated: true)
    }
}
