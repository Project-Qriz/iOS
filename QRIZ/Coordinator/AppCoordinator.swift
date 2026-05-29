//
//  AppCoordinator.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import UIKit
import QRIZUtils
import QRIZNetwork
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
    lazy var adService: any AdService = AdServiceImpl()

    lazy var loginCoordinator: LoginCoordinator = {
        let navi = UINavigationController()
        return makeLoginCoordinator(
            navigationController: navi,
            loginService: loginService,
            userInfoService: userInfoService,
            signUpService: signUpService,
            accountRecoveryService: accountRecoveryService,
            socialLoginService: socialLoginService
        )
    }()

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
            socialLoginService: socialLoginService,
            adService: adService
        )
        return TabBarCoordinatorImpl(dependency: tabBarDependency)
    }
    
    var onboardingCoordinator: any OnboardingCoordinator {
        let navi = UINavigationController()
        return makeOnboardingCoordinator(
            navigationController: navi,
            onboardingService: onboardingService,
            userInfoService: userInfoService,
            dailyService: dailyService
        )
    }
}

@MainActor
final class AppCoordinatorImpl: AppCoordinator {
    
    // MARK: - Properties
    
    var window: UIWindow
    private let dependency: AppCoordinatorDependency
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
            userInfoService: dependency.userInfoService,
            keychain: dependency.keychain
        )
        splash.delegate = self
        childCoordinators.append(splash)
        return splash.start()
    }
    
    @discardableResult
    private func showLogin() -> UIViewController {
        let loginCoordinator = dependency.loginCoordinator
        loginCoordinator.delegate = self
        childCoordinators.append(loginCoordinator)
        
        let loginVC = loginCoordinator.start()
        replaceRootViewController(with: loginVC, animated: true)
        return loginVC
    }
    
    @discardableResult
    private func showTabBar() -> UIViewController {
        let tabBarCoordinator = dependency.tabBarCoordinator
        tabBarCoordinator.delegate = self
        childCoordinators.append(tabBarCoordinator)
        
        let tabBarVC = tabBarCoordinator.start()
        replaceRootViewController(with: tabBarVC, animated: true)
        return tabBarVC
    }
    
    @discardableResult
    private func showOnboarding() -> UIViewController {
        let onboardingCoordinator = dependency.onboardingCoordinator
        onboardingCoordinator.delegate = self
        childCoordinators.append(onboardingCoordinator)

        let onboardingVC = onboardingCoordinator.start()
        replaceRootViewController(with: onboardingVC, animated: true)
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
        showLogin()
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
        if isLoggedIn { showTabBar() } else { showLogin() }
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinatorImpl: LoginCoordinatorDelegate {
    func didLogin(_ coordinator: LoginCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        if UserInfoManager.shared.previewTestStatus == .notStarted {
            showOnboarding()
        } else {
            showTabBar()
        }
    }
}

// MARK: - OnboardingCoordinatorDelegate

extension AppCoordinatorImpl: OnboardingCoordinatorDelegate {
    func didFinishOnboarding(_ coordinator: any OnboardingCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        showTabBar()
    }
}

// MARK: - TabBarCoordinatorDelegate

extension AppCoordinatorImpl: TabBarCoordinatorDelegate {
    func didLogout(_ coordinator: TabBarCoordinator) {
        childCoordinators.removeAll()
        dependency.keychain.deleteToken(forKey: TokenKey.accessToken.rawValue)
        showLogin()
    }
}
