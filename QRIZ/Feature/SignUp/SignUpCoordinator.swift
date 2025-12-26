//
//  SignUpCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 3/5/25.
//

import UIKit
import Combine

@MainActor
protocol SignUpCoordinator: Coordinator {
    var delegate: SignUpCoordinatorDelegate? { get set }
    func showNameInput()
    func showIDInput()
    func showPasswordInput()
    func showTermsAgreementModal()
    func showTermsDetail(for term: TermItem)
    func showSignUpCompleteAlert()
    func dismissView()
}

@MainActor
protocol SignUpCoordinatorDelegate: AnyObject {
    func didFinishSignUp(_ coordinator: SignUpCoordinator)
}

@MainActor
final class SignUpCoordinatorImpl: SignUpCoordinator, NavigationGuard {

    weak var delegate: SignUpCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let signUpFlowVM: SignUpFlowViewModel
    private let signUpService: SignUpService

    // NavigationGuard
    var isNavigating: Bool = false
    
    init(navigationController: UINavigationController, signUpService: SignUpService) {
        self.navigationController = navigationController
        self.signUpFlowVM = SignUpFlowViewModel(signUpService: signUpService)
        self.signUpService = signUpService
    }
    
    func start() -> UIViewController {
        let verificationVM = SignUpVerificationViewModel(
            signUpFlowViewModel: signUpFlowVM,
            signUpService: signUpService
        )
        let verificationVC = SignUpVerificationViewController(signUpVerificationVM: verificationVM)
        verificationVC.coordinator = self
        navigationController.pushViewController(verificationVC, animated: true)
        return navigationController
    }
    
    func showNameInput() {
        guardNavigation {
            let nameInputVM = NameInputViewModel(signUpFlowViewModel: signUpFlowVM)
            let nameInputVC = NameInputViewController(nameInputVM: nameInputVM)
            nameInputVC.coordinator = self
            navigationController.pushViewController(nameInputVC, animated: true)
        }
    }

    func showIDInput() {
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

    func showPasswordInput() {
        guardNavigation {
            let passwordInputVM = PasswordInputViewModel(signUpFlowViewModel: signUpFlowVM)
            let passwordInputVC = PasswordInputViewController(passwordInputVM: passwordInputVM)
            passwordInputVC.coordinator = self
            navigationController.pushViewController(passwordInputVC, animated: true)
        }
    }

    func showTermsAgreementModal() {
        guardNavigation {
            let viewModel = TermsAgreementModalViewModel(signUpFlowViewModel: signUpFlowVM)
            let rootVC = TermsAgreementModalViewController(viewModel: viewModel)
            rootVC.coordinator = self

            let sheetNavi = UINavigationController(rootViewController: rootVC)
            sheetNavi.setNavigationBarHidden(true, animated: false)
            sheetNavi.modalPresentationStyle = .pageSheet

            if let sheet = sheetNavi.sheetPresentationController {
                if UIScreen.main.isSESize {
                    sheet.detents = [.medium()]
                    sheet.selectedDetentIdentifier = .medium
                } else {
                    let halfDetent = UISheetPresentationController.Detent
                        .custom(identifier: .init("half")) { ctx in
                            ctx.maximumDetentValue * 0.4
                        }
                    sheet.detents = [halfDetent]
                    sheet.selectedDetentIdentifier = halfDetent.identifier
                }

                sheet.preferredCornerRadius = 24
            }

            navigationController.present(sheetNavi, animated: true)
        }
    }

    func showTermsDetail(for term: TermItem) {
        guardNavigation {
            guard let sheetNav = navigationController.presentedViewController
                    as? UINavigationController else { return }

            let viewModel = TermsDetailViewModel(termItem: term)
            let vc = TermsDetailViewController(viewModel: viewModel)
            vc.coordinator = self
            vc.dismissDelegate = self
            vc.modalPresentationStyle = .fullScreen
            sheetNav.present(vc, animated: true)
        }
    }
    
    func showSignUpCompleteAlert() {
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
            .sink { [weak self] _ in
                alert.dismiss(animated: true) {
                    guard let self else { return }
                    self.delegate?.didFinishSignUp(self)
                }
            }
            .store(in: &alert.cancellables)
        
        navigationController.present(alert, animated: true)
    }
    
    func dismissView() {
        navigationController.dismiss(animated: true)
    }
}

// MARK: - TermsDetailDismissible

extension SignUpCoordinatorImpl: TermsDetailDismissible {
    func dismissTermsDetail() {
        navigationController.dismiss(animated: true)
    }
}
