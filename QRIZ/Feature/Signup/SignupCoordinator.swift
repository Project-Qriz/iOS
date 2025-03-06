//
//  SignupCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 3/5/25.
//

import UIKit
import Combine

@MainActor
protocol SignUpCoordinatorDelegate: AnyObject {
    func didFinishSignUp(_ coordinator: SignUpCoordinator)
}

@MainActor
protocol SignUpCoordinator: Coordinator {
    var delegate: SignUpCoordinatorDelegate? { get set }
}

final class SignUpCoordinatorImpl: SignUpCoordinator {
    
    weak var delegate: SignUpCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() -> UIViewController {
        let verificationVM = SignUpVerificationViewModel()
        let verificationVC = SignUpVerificationViewController(signUpVerificationVM: verificationVM)
        navigationController.pushViewController(verificationVC, animated: true)
        return navigationController
    }
}
