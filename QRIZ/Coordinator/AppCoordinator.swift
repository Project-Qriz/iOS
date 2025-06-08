//
//  AppCoordinator.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import UIKit
import Combine

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
    // Coordinators
    var loginCoordinator: LoginCoordinator { get }
    var tabBarCoordinator: TabBarCoordinator { get }
    var onboardingCoordinator: OnboardingCoordinator { get }
    
    // Services
    var loginService: LoginService { get }
    var signUpService: SignUpService { get }
    var accountRecoveryService: AccountRecoveryService { get }
    var examScheduleService: ExamScheduleService { get }
    var userInfoService: UserInfoService { get }
    var onboardingService: OnboardingService { get }
    
    // Utils
    var keychain: KeychainManager { get }
    var sessionNotifier: SessionEventNotifier { get }
}

@MainActor
final class AppCoordinatorDependencyImpl: AppCoordinatorDependency {
    
    var keychain: KeychainManager = KeychainManagerImpl()
    var sessionNotifier: SessionEventNotifier = SessionEventNotifierImpl()
    private lazy var network: Network = NetworkImpl(session: .shared, notifier: sessionNotifier)

    lazy var loginService: LoginService = LoginServiceImpl(network: network)
    lazy var signUpService: SignUpService = SignUpServiceImpl(network: network)
    lazy var accountRecoveryService: AccountRecoveryService = AccountRecoveryServiceImpl(network: network)
    lazy var examScheduleService: ExamScheduleService = ExamScheduleServiceImpl(network: network, keychain: keychain)
    lazy var userInfoService: UserInfoService = UserInfoServiceImpl(network: network, keychainManager: keychain)
    lazy var onboardingService: OnboardingService = OnboardingServiceImpl(network: network, keychainManager: keychain)
    
    private lazy var _loginCoordinator: LoginCoordinator = {
        let navi = UINavigationController()
        return LoginCoordinatorImp(
            navigationController: navi,
            loginService: loginService,
            userInfoService: userInfoService,
            signUpService: signUpService,
            accountRecoveryService: accountRecoveryService
        )
    }()
    
    var loginCoordinator: LoginCoordinator {
        return _loginCoordinator
    }
    
    var tabBarCoordinator: TabBarCoordinator {
        let tabBarDependency = TabBarCoordinatorDependencyImp(
            examService: examScheduleService,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
        return TabBarCoordinatorImp(dependency: tabBarDependency)
    }
    
    var onboardingCoordinator: OnboardingCoordinator {
        let navi = UINavigationController()
        return OnboardingCoordinatorImpl(navigationController: navi,
                                         onboardingService: onboardingService,
                                         userInfoService: userInfoService)
    }
}

@MainActor
final class AppCoordinatorImpl: AppCoordinator {
    
    // MARK: - Properties
    
    var window: UIWindow
    private let dependency: AppCoordinatorDependency
    private var splashCoordinator: SplashCoordinator?
    private var childCoordinators: [Coordinator] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(window: UIWindow, dependency: AppCoordinatorDependency) {
        self.window = window
        self.dependency = dependency
        bindSessionEvent()
    }
    
    func start() -> UIViewController {
        _ = UINavigationBar.defaultBackButtonStyle()
        return showSplash()
    }
    
    private func showSplash() -> UIViewController {
        let splash = SplashCoordinatorImpl(
            window: window,
            userInfoService: dependency.userInfoService,
            keychain: dependency.keychain
        )
        splash.delegate = self
        splashCoordinator = splash
        childCoordinators.append(splash)
        return splash.start()
    }
    
    private func showLogin() -> UIViewController {
        let loginCoordinator = dependency.loginCoordinator
        (loginCoordinator as? LoginCoordinatorImp)?.delegate = self
        childCoordinators.append(loginCoordinator)
        
        let loginVC = loginCoordinator.start()
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        return loginVC
    }
    
    private func showTabBar() -> UIViewController {
        let tabBarCoordinator = dependency.tabBarCoordinator
        childCoordinators.append(tabBarCoordinator)
        
        let tabBarVC = tabBarCoordinator.start()
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()
        return tabBarVC
    }
    
    private func showOnboarding() -> UIViewController {
        let onboardingCoordinator = dependency.onboardingCoordinator
        (onboardingCoordinator as? OnboardingCoordinatorImpl)?.delegate = self
        childCoordinators.append(onboardingCoordinator)
        
        let onboardingVC = onboardingCoordinator.start()
        window.rootViewController = onboardingVC
        window.makeKeyAndVisible()
        return onboardingVC
    }

    private func bindSessionEvent() {
        dependency.sessionNotifier.event
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event { case .expired: self.resetToLogin() }
            }
            .store(in: &cancellables)
    }
    
    private func resetToLogin() {
        childCoordinators.removeAll()
        _ = showLogin()
    }
}

// MARK: - SplashCoordinatorDelegate

extension AppCoordinatorImpl: SplashCoordinatorDelegate {
    func didFinishSplash(_ coordinator: SplashCoordinator, isLoggedIn: Bool) {
        childCoordinators.removeAll { $0 === coordinator }
        splashCoordinator = nil
        _ = isLoggedIn ? showTabBar() : showLogin()
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinatorImpl: LoginCoordinatorDelegate {
    func didLogin(_ coordinator: LoginCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        _ = UserInfoManager.shared.previewTestStatus == .notStarted ?
        showOnboarding() : showTabBar()
    }
}

// MARK: - OnboardingCoordinatorDelegate

extension AppCoordinatorImpl: OnboardingCoordinatorDelegate {
    func didFinishOnboarding(_ coordinator: any OnboardingCoordinator) {
        childCoordinators.removeAll() { $0 === coordinator }
        _ = showTabBar()
    }
}
