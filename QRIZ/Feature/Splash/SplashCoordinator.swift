//
//  SplashCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 6/2/25.
//

import UIKit
import QRIZUtils
import QRIZNetwork

@MainActor
protocol SplashCoordinator: Coordinator {
    var delegate: SplashCoordinatorDelegate? { get set }
}

@MainActor
protocol SplashCoordinatorDelegate: AnyObject {
    func didFinishSplash(_ coordinator: SplashCoordinator, isLoggedIn: Bool)
}

@MainActor
final class SplashCoordinatorImpl: SplashCoordinator {

    // MARK: - Properties

    weak var delegate: SplashCoordinatorDelegate?
    private let userInfoService: UserInfoService
    private let keychain: KeychainManager

    // MARK: - Initialization

    init(
        userInfoService: UserInfoService,
        keychain: KeychainManager
    ) {
        self.userInfoService = userInfoService
        self.keychain = keychain
    }

    // MARK: - Methods

    func start() -> UIViewController {
        let viewModel = SplashViewModel(userInfoService: userInfoService, keychain: keychain, userInfo: .shared)
        let splashVC = SplashViewController(viewModel: viewModel)

        splashVC.didFinish = { [weak self] isLoggedIn in
            guard let self else { return }
            self.delegate?.didFinishSplash(self, isLoggedIn: isLoggedIn)
        }

        return splashVC
    }
}
