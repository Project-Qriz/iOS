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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() -> UIViewController {
        let verificationVM = SignUpVerificationViewModel()
        let verificationVC = SignUpVerificationViewController(signUpVerificationVM: verificationVM)
        verificationVC.coordinator = self
        navigationController.pushViewController(verificationVC, animated: true)
        return navigationController
    }
    
    func showNameInput() {
        let nameInputVM = NameInputViewModel()
        let nameInputVC = NameInputViewController(nameInputVM: nameInputVM)
        nameInputVC.coordinator = self
        navigationController.pushViewController(nameInputVC, animated: true)
    }
    
    func showIDInput() {
        let idInputVM = IDInputViewModel()
        let idInputVC = IDInputViewController(idInputVM: idInputVM)
        idInputVC.coordinator = self
        navigationController.pushViewController(idInputVC, animated: true)
    }
    
    func showPasswordInput() {
        let passwordInputVM = PasswordInputViewModel()
        let passwordInputVC = PasswordInputViewController(passwordInputVM: passwordInputVM)
        passwordInputVC.coordinator = self
        navigationController.pushViewController(passwordInputVC, animated: true)
    }
}
