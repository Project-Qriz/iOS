//
//  AppCoordinator.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    func start() -> UIViewController
}

@MainActor
protocol AppCoordinator: Coordinator {
    var window: UIWindow { get set }
}

@MainActor
protocol AppCoordinatorDependency {
    var loginCoordinator: LoginCoordinator { get }
    var tabBarCoordinator: TabBarCoordinator { get }
    var loginService: LoginService { get }
    var signUpService: SignUpService { get }
    var accountRecoveryService: AccountRecoveryService { get }
    var examScheduleService: ExamScheduleService { get }
}

@MainActor
final class AppCoordinatorDependencyImp: AppCoordinatorDependency {
    
    private lazy var network: Network = NetworkImp(session: .shared)
    private lazy var keychain: KeychainManager = KeychainManagerImpl()
    
    lazy var loginService: LoginService = LoginServiceImpl(network: network)
    lazy var signUpService: SignUpService = SignUpServiceImpl(network: network)
    lazy var accountRecoveryService: AccountRecoveryService = AccountRecoveryServiceImpl(network: network)
    lazy var examScheduleService: ExamScheduleService = ExamScheduleServiceImpl(network: network, keychain: keychain)
    
    private lazy var _loginCoordinator: LoginCoordinator = {
        let navi = UINavigationController()
        return LoginCoordinatorImp(
            navigationController: navi,
            loginService: loginService,
            signUpService: signUpService,
            accountRecoveryService: accountRecoveryService
        )
    }()
    
    var loginCoordinator: LoginCoordinator {
        return _loginCoordinator
    }
    
    var tabBarCoordinator: TabBarCoordinator {
        let tabBarDependency = TabBarCoordinatorDependencyImp(examService: examScheduleService)
        return TabBarCoordinatorImp(dependency: tabBarDependency)
    }
}

@MainActor
final class AppCoordinatorImp: AppCoordinator {
    
    var window: UIWindow
    private let dependency: AppCoordinatorDependency
    var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow, dependency: AppCoordinatorDependency) {
        self.window = window
        self.dependency = dependency
    }
    
    func start() -> UIViewController {
        /// 임시 로그인 상태
        let isLoggedIn = true
        _ = UINavigationBar.defaultBackButtonStyle()
        return isLoggedIn ? showTabBar() : showLogin()
    }
    
    private func showTabBar() -> UIViewController {
        let tabBarCoordinator = dependency.tabBarCoordinator
        childCoordinators.append(tabBarCoordinator)
        let tabBarVC = tabBarCoordinator.start()
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()
        return tabBarVC
    }
    
    private func showLogin() -> UIViewController {
        let loginCoordinator = dependency.loginCoordinator
        if let loginCoordinatorImp = loginCoordinator as? LoginCoordinatorImp {
            loginCoordinatorImp.delegate = self
        }
        childCoordinators.append(loginCoordinator)
        let loginVC = loginCoordinator.start()
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        return loginVC
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinatorImp: LoginCoordinatorDelegate {
    func didLogin(_ coordinator: LoginCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        let tabBarCoordinator = dependency.tabBarCoordinator
        childCoordinators.append(tabBarCoordinator)
        
        let tabBarVC = tabBarCoordinator.start()
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()
    }
}
