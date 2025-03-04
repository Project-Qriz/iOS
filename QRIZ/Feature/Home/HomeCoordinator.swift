//
//  HomeCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol HomeCoordinator: Coordinator {
}

@MainActor
final class HomeCoordinatorImp: HomeCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let homeVC = HomeViewController()
        let navi = UINavigationController(rootViewController: homeVC)
        return navi
    }
}
