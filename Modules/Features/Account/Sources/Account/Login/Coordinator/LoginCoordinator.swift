//
//  LoginCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/21/25.
//

import UIKit
import QRIZUtils
import QRIZNetwork

@MainActor
public protocol LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate? { get set }
    func showSignUp()
    func showFindId()
    func showFindPassword()
    func showSocialSignUp(with onboarding: SocialOnboarding)
    func popToRootViewController()
}

@MainActor
public protocol LoginCoordinatorDelegate: AnyObject {
    func didLogin(_ coordinator: LoginCoordinator, reAgreementRequired: Bool, ageVerificationRequired: Bool)
}

@MainActor
public func makeLoginCoordinator(
    navigationController: UINavigationController,
    loginService: any LoginService,
    userInfoService: any UserInfoService,
    signUpService: any SignUpService,
    termsService: any TermsService,
    accountRecoveryService: any AccountRecoveryService,
    socialLoginService: any SocialLoginService,
    socialJoinService: any SocialJoinService
) -> any LoginCoordinator {
    LoginCoordinatorImpl(
        navigationController: navigationController,
        loginService: loginService,
        userInfoService: userInfoService,
        signUpService: signUpService,
        termsService: termsService,
        accountRecoveryService: accountRecoveryService,
        socialLoginService: socialLoginService,
        socialJoinService: socialJoinService
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
    private let termsService: TermsService
    private let accountRecoveryService: AccountRecoveryService
    private let socialLoginService: SocialLoginService
    private let socialJoinService: SocialJoinService

    // NavigationGuard
    public var isNavigating: Bool = false

    public init(
        navigationController: UINavigationController,
        loginService: LoginService,
        userInfoService: UserInfoService,
        signUpService: SignUpService,
        termsService: TermsService,
        accountRecoveryService: AccountRecoveryService,
        socialLoginService: SocialLoginService,
        socialJoinService: SocialJoinService
    ) {
        self.navigationController = navigationController
        self.loginService = loginService
        self.userInfoService = userInfoService
        self.signUpService = signUpService
        self.termsService = termsService
        self.accountRecoveryService = accountRecoveryService
        self.socialLoginService = socialLoginService
        self.socialJoinService = socialJoinService
    }
    
    public func start() -> UIViewController {
        let loginVM = LoginViewModel(loginService: loginService, userInfoService: userInfoService, socialLoginService: socialLoginService, userInfo: .shared)
        let loginVC = LoginViewController(loginVM: loginVM)
        loginVC.coordinator = self
        navigationController.viewControllers = [loginVC]
        return navigationController
    }
    
    public func showSignUp() {
        guardNavigation {
            let signUpCoordinator = SignUpCoordinatorImpl(
                navigationController: navigationController,
                signUpService: signUpService,
                termsService: termsService
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
    
    /// 엄격 모드 신규 소셜 회원: 약관 동의 화면을 띄우고, 동의하면 가입을 완료한 뒤 로그인 성공으로 이어간다.
    /// 서버에 회원이 아직 없으므로 X로 닫으면 로그인 화면으로 돌아가기만 한다.
    public func showSocialSignUp(with onboarding: SocialOnboarding) {
        guardNavigation {
            let submitter = SocialJoinTermsSubmitter(
                onboarding: onboarding,
                socialJoinService: socialJoinService,
                userInfo: .shared,
                onJoined: { [weak self] response in
                    guard let self else { return }
                    delegate?.didLogin(
                        self,
                        reAgreementRequired: response.data.resolvedReAgreementRequired,
                        ageVerificationRequired: response.data.resolvedAgeVerificationRequired
                    )
                }
            )
            let viewModel = TermsAgreementViewModel(
                termsService: termsService,
                submitter: submitter,
                onDismiss: { [weak self] in self?.popToRootViewController() }
            )
            let view = TermsAgreementView(
                viewModel: viewModel,
                progress: nil,
                onShowTermsDetail: { [weak self] term in self?.showTermsDetail(for: term) }
            )
            navigationController.pushViewController(TermsAgreementHostingController(rootView: view), animated: true)
        }
    }

    private func showTermsDetail(for term: TermItem) {
        let viewModel = TermsDetailViewModel(termItem: term)
        let vc = TermsDetailViewController(viewModel: viewModel)
        vc.dismissDelegate = self
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
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

// MARK: - TermsDetailDismissible

extension LoginCoordinatorImpl: TermsDetailDismissible {
    public func dismissTermsDetail() {
        navigationController.dismiss(animated: true)
    }
}
