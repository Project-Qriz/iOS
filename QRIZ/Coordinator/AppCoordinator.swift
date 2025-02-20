//
//  AppCoordinator.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    func start() -> UIViewController
}

@MainActor
protocol AppCoordinator: Coordinator {
    var window: UIWindow { get set }
}

@MainActor
protocol AppCoordinatorDependency {
    /// 임시 선언
//    var loginCoordinator: LoginCoordinator { get }
//    var tabBarCoordinator: TabBarCoordinator { get }
}

@MainActor
final class AppCoordinatorImp: AppCoordinator {
    
    var window: UIWindow
    private let dependency: AppCoordinatorDependency
    var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow, dependency: AppCoordinatorDependency) {
        self.window = window
        self.dependency = dependency
    }
    
    func start() -> UIViewController {
        /// 임시 선언 추후 로그인 분기 처리 필요
        let login = LoginViewController(loginVM: LoginViewModel())
        window.rootViewController = login
        window.makeKeyAndVisible()
        return login
    }
}
