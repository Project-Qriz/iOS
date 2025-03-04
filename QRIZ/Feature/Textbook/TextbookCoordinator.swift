//
//  TextbookCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol TextbookCoordinator: Coordinator {
}

@MainActor
final class TextbookCoordinatorImp: TextbookCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let textbookVC = TextbookViewController()
        let nav = UINavigationController(rootViewController: textbookVC)
        return nav
    }
}
