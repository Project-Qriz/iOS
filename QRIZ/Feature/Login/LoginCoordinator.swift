//
//  LoginCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/21/25.
//

import UIKit

/// 로그인 성공 시 상위에게 알리기 위한 델리게이트
@MainActor
protocol LoginCoordinatorDelegate: AnyObject {
    func didLogin(_ coordinator: LoginCoordinator)
}

@MainActor
protocol LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate? { get set }
}

@MainActor
final class LoginCoordinatorImp: LoginCoordinator {
    
    weak var delegate: LoginCoordinatorDelegate?
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() -> UIViewController {
        let loginVC = LoginViewController(loginVM: LoginViewModel())
        navigationController.viewControllers = [loginVC]
        return navigationController
    }
}

