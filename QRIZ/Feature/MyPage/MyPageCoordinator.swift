//
//  MyPageCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MyPageCoordinator: Coordinator {
}

@MainActor
final class MyPageCoordinatorImp: MyPageCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let myPageVC = MyPageViewController()
        let nav = UINavigationController(rootViewController: myPageVC)
        return nav
    }
}
