//
//  TabBarCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/24/25.
//

import UIKit

@MainActor
protocol TabBarCoordinator: Coordinator {
    var delegate: TabBarCoordinatorDelegate? { get set }
}

@MainActor
protocol TabBarCoordinatorDelegate: AnyObject {
    func didLogout(_ coordinator: TabBarCoordinator)
}

@MainActor
protocol TabBarCoordinatorDependency {
    var homeCoordinator: HomeCoordinator { get }
    var textbookCoordinator: TextbookCoordinator { get }
    var mistakeNoteCoordinator: MistakeNoteCoordinator { get }
    var myPageCoordinator: MyPageCoordinator { get }
}

@MainActor
final class TabBarCoordinatorImp: TabBarCoordinator {
    
    weak var delegate: TabBarCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    private let dependency: TabBarCoordinatorDependency
    
    init(dependency: TabBarCoordinatorDependency) {
        self.dependency = dependency
    }
    
    func start() -> UIViewController {
        let tabBarController = UITabBarController()
        configureTabBarController(tabBarController)
        
        let homeCoordinator = dependency.homeCoordinator
        let textbookCoordinator = dependency.textbookCoordinator
        let mistakeNoteCoordinator = dependency.mistakeNoteCoordinator
        let myPageCoordinator = dependency.myPageCoordinator
        [
            homeCoordinator,
            textbookCoordinator,
            mistakeNoteCoordinator,
            myPageCoordinator
        ].forEach { childCoordinators.append($0) }
        
        tabBarController.viewControllers = [
            homeCoordinator.start(),
            textbookCoordinator.start(),
            mistakeNoteCoordinator.start(),
            myPageCoordinator.start()
        ]
        
        return tabBarController
    }
    
    private func configureTabBarController(_ tabBarController: UITabBarController) {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.unselectedItemTintColor = .coolNeutral500
        tabBarController.tabBar.layer.borderColor = UIColor.customBlue100.cgColor
        tabBarController.tabBar.layer.borderWidth = 1.0
        tabBarController.tabBar.layer.masksToBounds = true
    }
    
    func logout() {
        delegate?.didLogout(self)
    }
}
