//
//  AppCoordinator.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import UIKit
import QRIZUtils
import Network
import Auth
import Account
import Onboarding

@MainActor
protocol AppCoordinator: Coordinator {
    var window: UIWindow { get set }
}

@MainActor
protocol AppCoordinatorDependency {
    // Coordinators
    var loginCoordinator: LoginCoordinator { get }
    var tabBarCoordinator: TabBarCoordinator { get }
    var onboardingCoordinator: any OnboardingCoordinator { get }
    
    // Services
    var loginService: LoginService { get }
    var signUpService: SignUpService { get }
    var accountRecoveryService: AccountRecoveryService { get }
    var examScheduleService: ExamScheduleService { get }
    var examTestService: ExamService { get }
    var dailyService: DailyService { get }
    var userInfoService: UserInfoService { get }
    var onboardingService: OnboardingService { get }
    var weeklyRecommendService: WeeklyRecommendService { get }
    var socialLoginService: SocialLoginService { get }
    
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
    lazy var examTestService: ExamService = ExamServiceImpl(network: network, keychainManager: keychain)
    lazy var dailyService: DailyService = DailyServiceImpl(network: network, keychainManager: keychain)
    lazy var myPageService: MyPageService = MyPageServiceImpl(network: network, keychain: keychain)
    lazy var userInfoService: UserInfoService = UserInfoServiceImpl(network: network, keychainManager: keychain)
    lazy var onboardingService: OnboardingService = OnboardingServiceImpl(network: network, keychainManager: keychain)
    lazy var weeklyRecommendService: WeeklyRecommendService = WeeklyRecommendServiceImpl(network: network, keychain: keychain)
    lazy var socialLoginService: SocialLoginService = SocialLoginServiceImpl()
    
    private lazy var _loginCoordinator: LoginCoordinator = {
        let navi = UINavigationController()
        return LoginCoordinatorImpl(
            navigationController: navi,
            loginService: loginService,
            userInfoService: userInfoService,
            signUpService: signUpService,
            accountRecoveryService: accountRecoveryService,
            socialLoginService: socialLoginService
        )
    }()
    
    var loginCoordinator: LoginCoordinator {
        return _loginCoordinator
    }
    
    var tabBarCoordinator: TabBarCoordinator {
        let tabBarDependency = TabBarCoordinatorDependencyImpl(
            examService: examScheduleService,
            examTestService: examTestService,
            dailyService: dailyService,
            onboardingService: onboardingService,
            userInfoService: userInfoService,
            myPageService: myPageService,
            accountRecoveryService: accountRecoveryService,
            weeklyService: weeklyRecommendService,
            socialLoginService: socialLoginService
        )
        return TabBarCoordinatorImpl(dependency: tabBarDependency)
    }
    
    var onboardingCoordinator: any OnboardingCoordinator {
        let navi = UINavigationController()
        return OnboardingCoordinator.make(
            navigationController: navi,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
    }
}

@MainActor
final class AppCoordinatorImpl: AppCoordinator {
    
    // MARK: - Properties
    
    var window: UIWindow
    private let dependency: AppCoordinatorDependency
    private var splashCoordinator: SplashCoordinator?
    private var childCoordinators: [Coordinator] = []

    // MARK: - Initialize

    init(window: UIWindow, dependency: AppCoordinatorDependency) {
        self.window = window
        self.dependency = dependency
        observeSessionEvents()
    }
    
    func start() -> UIViewController {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
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
        (loginCoordinator as? LoginCoordinatorImpl)?.delegate = self
        childCoordinators.append(loginCoordinator)
        
        let loginVC = loginCoordinator.start()
        replaceRootViewController(with: loginVC, animated: true)
        return loginVC
    }
    
    private func showTabBar() -> UIViewController {
        let tabBarCoordinator = dependency.tabBarCoordinator
        tabBarCoordinator.delegate = self
        childCoordinators.append(tabBarCoordinator)
        
        let tabBarVC = tabBarCoordinator.start()
        replaceRootViewController(with: tabBarVC, animated: true)
        return tabBarVC
    }
    
    private func showOnboarding() -> UIViewController {
        var onboardingCoordinator = dependency.onboardingCoordinator
        onboardingCoordinator.delegate = self
        childCoordinators.append(onboardingCoordinator)
        
        let onboardingVC = onboardingCoordinator.start()
        window.rootViewController = onboardingVC
        window.makeKeyAndVisible()
        return onboardingVC
    }

    private func observeSessionEvents() {
        Task { [weak self] in
            guard let self else { return }
            for await event in dependency.sessionNotifier.events {
                switch event {
                case .expired: resetToLogin()
                }
            }
        }
    }
    
    private func resetToLogin() {
        childCoordinators.removeAll()
        _ = showLogin()
    }
    
    private func replaceRootViewController(
        with vc: UIViewController,
        animated: Bool = true
    ) {
        let win = self.window
        if animated {
            UIView.transition(
                with: win,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    win.rootViewController = vc
                },
                completion: nil
            )
        } else {
            win.rootViewController = vc
            win.makeKeyAndVisible()
        }
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

// MARK: - TabBarCoordinatorDelegate

extension AppCoordinatorImpl: TabBarCoordinatorDelegate {
    func didLogout(_ coordinator: TabBarCoordinator) {
        childCoordinators.removeAll()
        dependency.keychain.deleteToken(forKey: TokenKey.accessToken.rawValue)
        _ = showLogin()
    }
}
