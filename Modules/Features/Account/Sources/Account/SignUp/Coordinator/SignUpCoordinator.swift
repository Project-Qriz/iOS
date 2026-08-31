//
//  SignUpCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 3/5/25.
//

import UIKit
import SwiftUI
import DesignSystem
import Combine
import QRIZUtils
import QRIZNetwork

@MainActor
public protocol SignUpCoordinator: Coordinator {
    var delegate: SignUpCoordinatorDelegate? { get set }
    func showEmailVerification()
    func showNameInput()
    func showIDInput()
    func showPasswordInput()
    func showTermsDetail(for term: TermItem)
    func showSignUpCompleteAlert()
    func dismissView()
}

@MainActor
public protocol SignUpCoordinatorDelegate: AnyObject {
    func didFinishSignUp(_ coordinator: SignUpCoordinator)
}

@MainActor
public final class SignUpCoordinatorImpl: SignUpCoordinator, NavigationGuard {

    public weak var delegate: SignUpCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let signUpFlowVM: SignUpFlowViewModel
    private let signUpService: SignUpService
    private let termsService: TermsService
    private var cancellables = Set<AnyCancellable>()

    // NavigationGuard
    public var isNavigating: Bool = false

    public init(navigationController: UINavigationController, signUpService: SignUpService, termsService: TermsService) {
        self.navigationController = navigationController
        self.signUpFlowVM = SignUpFlowViewModel(signUpService: signUpService)
        self.signUpService = signUpService
        self.termsService = termsService
    }
    
    public func start() -> UIViewController {
        let viewModel = TermsAgreementViewModel(
            signUpFlowViewModel: signUpFlowVM,
            termsService: termsService,
            onDismiss: { [weak self] in self?.dismissView() },
            onTermsAgreed: { [weak self] in self?.showEmailVerification() }
        )
        let view = TermsAgreementView(
            viewModel: viewModel,
            onShowTermsDetail: { [weak self] term in self?.showTermsDetail(for: term) }
        )
        let rootVC = TermsAgreementHostingController(rootView: view)
        navigationController.pushViewController(rootVC, animated: true)
        return navigationController
    }

    public func showEmailVerification() {
        guardNavigation {
            let verificationVM = SignUpVerificationViewModel(
                signUpFlowViewModel: signUpFlowVM,
                signUpService: signUpService
            )
            let verificationVC = SignUpVerificationViewController(signUpVerificationVM: verificationVM)
            verificationVC.coordinator = self
            navigationController.pushViewController(verificationVC, animated: true)
        }
    }

    public func showNameInput() {
        guardNavigation {
            let nameInputVM = NameInputViewModel(signUpFlowViewModel: signUpFlowVM)
            let nameInputVC = NameInputViewController(nameInputVM: nameInputVM)
            nameInputVC.coordinator = self
            navigationController.pushViewController(nameInputVC, animated: true)
        }
    }

    public func showIDInput() {
        guardNavigation {
            let idInputVM = IDInputViewModel(
                signUpFlowViewModel: signUpFlowVM,
                signUpService: signUpService
            )
            let idInputVC = IDInputViewController(idInputVM: idInputVM)
            idInputVC.coordinator = self
            navigationController.pushViewController(idInputVC, animated: true)
        }
    }

    public func showPasswordInput() {
        guardNavigation {
            let passwordInputVM = PasswordInputViewModel(signUpFlowViewModel: signUpFlowVM)
            let passwordInputVC = PasswordInputViewController(passwordInputVM: passwordInputVM)
            passwordInputVC.coordinator = self
            navigationController.pushViewController(passwordInputVC, animated: true)
        }
    }

    public func showTermsDetail(for term: TermItem) {
        guardNavigation {
            let viewModel = TermsDetailViewModel(termItem: term)
            let vc = TermsDetailViewController(viewModel: viewModel)
            vc.dismissDelegate = self
            vc.modalPresentationStyle = .fullScreen
            navigationController.present(vc, animated: true)
        }
    }
    
    public func showSignUpCompleteAlert() {
        if let presented = navigationController.presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.presentSignUpAlert()
            }
        } else {
            presentSignUpAlert()
        }
    }
    
    private func presentSignUpAlert() {
        let alert = OneButtonCustomAlertViewController(
            title: "회원가입 완료!",
            description: "회원가입이 완료되었습니다.\n합격을 향한 여정을 함께 시작해봐요!"
        )
        
        alert.confirmButtonTappedPublisher
            .first()
            .sink { [weak self] _ in
                alert.dismiss(animated: true) {
                    guard let self else { return }
                    self.delegate?.didFinishSignUp(self)
                }
            }
            .store(in: &cancellables)
        
        navigationController.present(alert, animated: true)
    }
    
    public func dismissView() {
        // 약관동의 화면이 회원가입 플로우의 첫 화면(루트)이라, "X" 취소는 전체 회원가입을 취소하고
        // 회원가입 시작 전 화면(로그인)으로 돌아가는 것을 의미한다.
        // 성공 경로(presentSignUpAlert → didFinishSignUp)와 동일하게 delegate를 통해 정리해야
        // LoginCoordinatorImpl.childCoordinators에서도 이 코디네이터가 제거된다.
        delegate?.didFinishSignUp(self)
    }
}

// MARK: - TermsDetailDismissible

extension SignUpCoordinatorImpl: TermsDetailDismissible {
    public func dismissTermsDetail() {
        navigationController.dismiss(animated: true)
    }
}

/// 약관동의 화면은 회원가입 push 스택의 첫 화면으로, 자체 헤더에 X 버튼을 두고 시스템 내비게이션 바는 숨긴다.
/// 이후 화면(이메일 인증 등)은 기본 내비게이션 바를 그대로 사용하므로, 숨김 처리는 이 화면이 보이는 동안만 적용한다.
private final class TermsAgreementHostingController: UIHostingController<TermsAgreementView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
