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
final class TabBarCoordinatorDependencyImp: TabBarCoordinatorDependency {
    
    var homeCoordinator: HomeCoordinator {
        return HomeCoordinatorImp()
    }
    
    var textbookCoordinator: TextbookCoordinator {
        return TextbookCoordinatorImp()
    }
    
    var mistakeNoteCoordinator: MistakeNoteCoordinator {
        return MistakeNoteCoordinatorImp()
    }
    
    var myPageCoordinator: MyPageCoordinator {
        return MyPageCoordinatorImp()
    }
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
        
        childCoordinators.append(contentsOf: [
            homeCoordinator,
            textbookCoordinator,
            mistakeNoteCoordinator,
            myPageCoordinator
        ])
        
        var viewControllers: [UIViewController] = []
        viewControllers.append(homeCoordinator.start())
        viewControllers.append(textbookCoordinator.start())
        viewControllers.append(mistakeNoteCoordinator.start())
        viewControllers.append(myPageCoordinator.start())
        setupTabBarItems(for: &viewControllers)
        
        tabBarController.viewControllers = viewControllers
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
    
    private func setupTabBarItems(for viewControllers: inout [UIViewController]) {
        guard viewControllers.count >= 4 else { return }
        
        viewControllers[0].tabBarItem = UITabBarItem(
            title: "홈",
            image: .home,
            selectedImage: .home
        )
        viewControllers[1].tabBarItem = UITabBarItem(
            title: "개념서",
            image: .textBook,
            selectedImage: .selectedTextbook
        )
        viewControllers[2].tabBarItem = UITabBarItem(
            title: "오답노트",
            image: .mistakeNote,
            selectedImage: .selectedMistakeNote
        )
        viewControllers[3].tabBarItem = UITabBarItem(
            title: "마이",
            image: .myPage,
            selectedImage: .myPage
        )
    }
    
    func logout() {
        delegate?.didLogout(self)
    }
}
