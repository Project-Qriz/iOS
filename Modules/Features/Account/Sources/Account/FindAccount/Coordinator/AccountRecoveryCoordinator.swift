//
//  AccountRecoveryCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 6/21/25.
//

import UIKit
import QRIZUtils
import QRIZNetwork

@MainActor
public protocol AccountRecoveryCoordinator: Coordinator {
    var delegate: AccountRecoveryCoordinatorDelegate? { get set }
    func showResetPassword()
    func popToRootViewController()
}

@MainActor
public protocol AccountRecoveryCoordinatorDelegate: AnyObject {
    /// 비밀번호 재설정 플로우가 모두 끝났을 때 호출
    func didFinishPasswordReset(_ coordinator: AccountRecoveryCoordinator)
}

@MainActor
public final class AccountRecoveryCoordinatorImpl: AccountRecoveryCoordinator, NavigationGuard {

    // MARK: - Properties

    public weak var delegate: AccountRecoveryCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let accountRecoveryService: AccountRecoveryService
    private var childCoordinators: [Coordinator] = []

    // NavigationGuard
    public var isNavigating: Bool = false

    // MARK: - Initialization

    public init(
        navigationController: UINavigationController,
        accountRecoveryService: AccountRecoveryService
    ) {
        self.navigationController = navigationController
        self.accountRecoveryService = accountRecoveryService
    }

    public func start() -> UIViewController {
        let vm = FindPasswordVerificationViewModel(accountRecoveryService: accountRecoveryService)
        let vc = FindPasswordVerificationViewController(findPasswordVerificationVM: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
        return navigationController
    }

    public func showResetPassword() {
        guardNavigation {
            let vm = ResetPasswordViewModel(accountRecoveryService: accountRecoveryService)
            let vc = ResetPasswordViewController(resetPasswordVM: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    public func popToRootViewController() {
        delegate?.didFinishPasswordReset(self)
    }
}
