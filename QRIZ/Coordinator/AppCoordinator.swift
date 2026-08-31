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
import OnboardingInterface

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
    var termsService: TermsService { get }
    var accountRecoveryService: AccountRecoveryService { get }
    var examScheduleService: ExamScheduleService { get }
    var examTestService: ExamService { get }
    var dailyService: DailyService { get }
    var userInfoService: UserInfoService { get }
    var onboardingService: OnboardingService { get }
    var weeklyRecommendService: WeeklyRecommendService { get }
    var socialLoginService: SocialLoginService { get }
    var consentsService: ConsentsService { get }
    var myPageService: MyPageService { get }

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
    lazy var termsService: TermsService = TermsServiceImpl(network: network)
    lazy var accountRecoveryService: AccountRecoveryService = AccountRecoveryServiceImpl(network: network)
    lazy var examScheduleService: ExamScheduleService = ExamScheduleServiceImpl(network: network, keychain: keychain)
    lazy var examTestService: ExamService = ExamServiceImpl(network: network, keychainManager: keychain)
    lazy var dailyService: DailyService = DailyServiceImpl(network: network, keychainManager: keychain)
    lazy var myPageService: MyPageService = MyPageServiceImpl(network: network, keychain: keychain)
    lazy var userInfoService: UserInfoService = UserInfoServiceImpl(network: network, keychainManager: keychain)
    lazy var onboardingService: OnboardingService = OnboardingServiceImpl(network: network, keychainManager: keychain)
    lazy var weeklyRecommendService: WeeklyRecommendService = WeeklyRecommendServiceImpl(network: network, keychain: keychain)
    lazy var socialLoginService: SocialLoginService = SocialLoginServiceImpl()
    lazy var consentsService: ConsentsService = ConsentsServiceImpl(network: network)
    lazy var adService: any AdService = AdServiceImpl()

    lazy var loginCoordinator: LoginCoordinator = {
        let navi = UINavigationController()
        return makeLoginCoordinator(
            navigationController: navi,
            loginService: loginService,
            userInfoService: userInfoService,
            signUpService: signUpService,
            termsService: termsService,
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
            termsService: termsService,
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

    /// 팝업이 떠 있는 동안 살아있어야 하므로 강한 참조로 보관한다.
    private var existingUserTermsUpdatePresenter: ExistingUserTermsUpdatePresenter?

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
    
    /// - Parameter completion: 루트 전환 애니메이션이 완전히 끝난 뒤 호출된다(전환된 뷰컨트롤러 전달).
    ///   전환 도중 그 위에 모달을 띄우면 애니메이션이 겹치므로, 후속 모달 프레젠테이션은 항상 이 completion 안에서 해야 한다.
    @discardableResult
    private func showTabBar(completion: @escaping (UIViewController) -> Void = { _ in }) -> UIViewController {
        let tabBarCoordinator = dependency.tabBarCoordinator
        tabBarCoordinator.delegate = self
        childCoordinators.append(tabBarCoordinator)

        let tabBarVC = tabBarCoordinator.start()
        replaceRootViewController(with: tabBarVC, animated: true) { completion(tabBarVC) }
        return tabBarVC
    }

    /// - Parameter completion: 루트 전환 애니메이션이 완전히 끝난 뒤 호출된다(전환된 뷰컨트롤러 전달).
    ///   전환 도중 그 위에 모달을 띄우면 애니메이션이 겹치므로, 후속 모달 프레젠테이션은 항상 이 completion 안에서 해야 한다.
    @discardableResult
    private func showOnboarding(completion: @escaping (UIViewController) -> Void = { _ in }) -> UIViewController {
        let onboardingCoordinator = dependency.onboardingCoordinator
        onboardingCoordinator.delegate = self
        childCoordinators.append(onboardingCoordinator)

        let onboardingVC = onboardingCoordinator.start()
        replaceRootViewController(with: onboardingVC, animated: true) { completion(onboardingVC) }
        return onboardingVC
    }

    /// 재동의/연령확인이 필요할 때 화면(홈 또는 온보딩) 위에 약관 업데이트 팝업을 띄운다.
    private func presentExistingUserTermsUpdate(over presentingVC: UIViewController) {
        let presenter = ExistingUserTermsUpdatePresenter(
            termsService: dependency.termsService,
            consentsService: dependency.consentsService,
            accessTokenProvider: { [weak self] in self?.dependency.keychain.retrieveToken(forKey: TokenKey.accessToken.rawValue) }
        )
        existingUserTermsUpdatePresenter = presenter
        let vc = presenter.makeViewController { [weak self, weak presentingVC] in
            presentingVC?.dismiss(animated: true)
            self?.existingUserTermsUpdatePresenter = nil
        }
        presentingVC.present(vc, animated: true)
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
        animated: Bool = true,
        completion: @escaping () -> Void = {}
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
                completion: { _ in completion() }
            )
        } else {
            win.rootViewController = vc
            win.makeKeyAndVisible()
            completion()
        }
    }
}

// MARK: - SplashCoordinatorDelegate

extension AppCoordinatorImpl: SplashCoordinatorDelegate {
    func didFinishSplash(_ coordinator: SplashCoordinator, isLoggedIn: Bool, reAgreementRequired: Bool, ageVerificationRequired: Bool) {
        childCoordinators.removeAll { $0 === coordinator }
        guard isLoggedIn else { showLogin(); return }
        showTabBar { [weak self] tabBarVC in
            guard reAgreementRequired || ageVerificationRequired else { return }
            self?.presentExistingUserTermsUpdate(over: tabBarVC)
        }
    }
}

// MARK: - LoginCoordinatorDelegate

extension AppCoordinatorImpl: LoginCoordinatorDelegate {
    func didLogin(_ coordinator: LoginCoordinator, reAgreementRequired: Bool, ageVerificationRequired: Bool) {
        childCoordinators.removeAll { $0 === coordinator }
        let presentPopupIfNeeded: (UIViewController) -> Void = { [weak self] destinationVC in
            guard reAgreementRequired || ageVerificationRequired else { return }
            self?.presentExistingUserTermsUpdate(over: destinationVC)
        }
        if UserInfoManager.shared.previewTestStatus == .notStarted {
            showOnboarding(completion: presentPopupIfNeeded)
        } else {
            showTabBar(completion: presentPopupIfNeeded)
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
