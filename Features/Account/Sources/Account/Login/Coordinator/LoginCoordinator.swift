//
//  LoginCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/21/25.
//

import UIKit
import QRIZUtils
import Network

@MainActor
public protocol LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate? { get set }
    func showSignUp()
    func showFindId()
    func showFindPassword()
    func popToRootViewController()
}

@MainActor
public protocol LoginCoordinatorDelegate: AnyObject {
    func didLogin(_ coordinator: LoginCoordinator)
}

@MainActor
public func makeLoginCoordinator(
    navigationController: UINavigationController,
    loginService: any LoginService,
    userInfoService: any UserInfoService,
    signUpService: any SignUpService,
    accountRecoveryService: any AccountRecoveryService,
    socialLoginService: any SocialLoginService
) -> any LoginCoordinator {
    LoginCoordinatorImpl(
        navigationController: navigationController,
        loginService: loginService,
        userInfoService: userInfoService,
        signUpService: signUpService,
        accountRecoveryService: accountRecoveryService,
        socialLoginService: socialLoginService
    )
}

@MainActor
public final class LoginCoordinatorImpl: LoginCoordinator, NavigationGuard {

    public weak var delegate: LoginCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []

    private let loginService: LoginService
    private let userInfoService: UserInfoService
    private let signUpService: SignUpService
    private let accountRecoveryService: AccountRecoveryService
    private let socialLoginService: SocialLoginService

    // NavigationGuard
    public var isNavigating: Bool = false

    public init(
        navigationController: UINavigationController,
        loginService: LoginService,
        userInfoService: UserInfoService,
        signUpService: SignUpService,
        accountRecoveryService: AccountRecoveryService,
        socialLoginService: SocialLoginService
    ) {
        self.navigationController = navigationController
        self.loginService = loginService
        self.userInfoService = userInfoService
        self.signUpService = signUpService
        self.accountRecoveryService = accountRecoveryService
        self.socialLoginService = socialLoginService
    }
    
    public func start() -> UIViewController {
        let loginVM = LoginViewModel(loginService: loginService, userInfoService: userInfoService, socialLoginService: socialLoginService)
        let loginVC = LoginViewController(loginVM: loginVM)
        loginVC.coordinator = self
        navigationController.viewControllers = [loginVC]
        return navigationController
    }
    
    public func showSignUp() {
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

    public func showFindId() {
        guardNavigation {
            let findIDVM = FindIDViewModel(accountRecoveryService: accountRecoveryService)
            let findIDVC = FindIDViewController(findIDInputVM: findIDVM)
            findIDVC.coordinator = self
            navigationController.pushViewController(findIDVC, animated: true)
        }
    }

    public func showFindPassword() {
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
    
    public func popToRootViewController() {
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - SignUpCoordinatorDelegate

extension LoginCoordinatorImpl: SignUpCoordinatorDelegate {
    public func didFinishSignUp(_ coordinator: SignUpCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - AccountRecoveryCoordinatorDelegate

extension LoginCoordinatorImpl: AccountRecoveryCoordinatorDelegate {
    public func didFinishPasswordReset(_ coordinator: AccountRecoveryCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController.popToRootViewController(animated: true)
    }
}
