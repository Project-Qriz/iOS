//
//  SignupCoordinator.swift
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
}

@MainActor
protocol SignUpCoordinatorDelegate: AnyObject {
    func didFinishSignUp(_ coordinator: SignUpCoordinator)
}

@MainActor
final class SignUpCoordinatorImpl: SignUpCoordinator {
    
    weak var delegate: SignUpCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let signUpFlowVM: SignUpFlowViewModel
    private let signUpService: SignUpService
    
    init(navigationController: UINavigationController, signUpService: SignUpService) {
        self.navigationController = navigationController
        self.signUpFlowVM = SignUpFlowViewModel(signUpService: signUpService)
        self.signUpService = signUpService
    }
    
    func start() -> UIViewController {
        let verificationVM = SignUpVerificationViewModel()
        let verificationVC = SignUpVerificationViewController(signUpVerificationVM: verificationVM)
        verificationVC.coordinator = self
        navigationController.pushViewController(verificationVC, animated: true)
        return navigationController
    }
    
    func showNameInput() {
        let nameInputVM = NameInputViewModel(signUpFlowViewModel: signUpFlowVM)
        let nameInputVC = NameInputViewController(nameInputVM: nameInputVM)
        nameInputVC.coordinator = self
        navigationController.pushViewController(nameInputVC, animated: true)
    }
    
    func showIDInput() {
        let idInputVM = IDInputViewModel(
            signUpFlowViewModel: signUpFlowVM,
            signUpService: signUpService
        )
        let idInputVC = IDInputViewController(idInputVM: idInputVM)
        idInputVC.coordinator = self
        navigationController.pushViewController(idInputVC, animated: true)
    }
    
    func showPasswordInput() {
        let passwordInputVM = PasswordInputViewModel(
            signUpFlowViewModel: signUpFlowVM,
            signUpService: signUpService
        )
        let passwordInputVC = PasswordInputViewController(passwordInputVM: passwordInputVM)
        passwordInputVC.coordinator = self
        navigationController.pushViewController(passwordInputVC, animated: true)
    }
}
