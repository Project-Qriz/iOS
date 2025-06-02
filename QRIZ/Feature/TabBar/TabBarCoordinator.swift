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
    var conceptBookCoordinator: ConceptBookCoordinator { get }
    var mistakeNoteCoordinator: MistakeNoteCoordinator { get }
    var myPageCoordinator: MyPageCoordinator { get }
}

@MainActor
final class TabBarCoordinatorDependencyImp: TabBarCoordinatorDependency {
    
    private let examService: ExamScheduleService
    
    var homeCoordinator: HomeCoordinator {
        return HomeCoordinatorImpl(examService: examService)
    }
    
    var conceptBookCoordinator: ConceptBookCoordinator {
        return ConceptBookCoordinatorImp()
    }
    
    var mistakeNoteCoordinator: MistakeNoteCoordinator {
        return MistakeNoteCoordinatorImp()
    }
    
    var myPageCoordinator: MyPageCoordinator {
        return MyPageCoordinatorImp()
    }
    
    init(examService: ExamScheduleService) {
        self.examService = examService
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
        let conceptBookCoordinator = dependency.conceptBookCoordinator
        let mistakeNoteCoordinator = dependency.mistakeNoteCoordinator
        let myPageCoordinator = dependency.myPageCoordinator
        
        childCoordinators.append(contentsOf: [
            homeCoordinator,
            conceptBookCoordinator,
            mistakeNoteCoordinator,
            myPageCoordinator
        ])
        
        var viewControllers: [UIViewController] = []
        viewControllers.append(homeCoordinator.start())
        viewControllers.append(conceptBookCoordinator.start())
        viewControllers.append(mistakeNoteCoordinator.start())
        viewControllers.append(myPageCoordinator.start())
        setupTabBarItems(for: &viewControllers)
        
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }
    
    private func configureTabBarController(_ tabBarController: UITabBarController) {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .customBlue500
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
            selectedImage: nil
        )
        viewControllers[1].tabBarItem = UITabBarItem(
            title: "개념서",
            image: .conceptBook,
            selectedImage: .selectedConceptBook
        )
        viewControllers[2].tabBarItem = UITabBarItem(
            title: "오답노트",
            image: .mistakeNote,
            selectedImage: .selectedMistakeNote
        )
        viewControllers[3].tabBarItem = UITabBarItem(
            title: "마이",
            image: .myPage,
            selectedImage: nil
        )
    }
    
    func logout() {
        delegate?.didLogout(self)
    }
}
