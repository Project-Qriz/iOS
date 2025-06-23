//
//  MistakeNoteCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MistakeNoteCoordinator: Coordinator {
}

@MainActor
final class MistakeNoteCoordinatorImpl: MistakeNoteCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let mistakeNoteVC = MistakeNoteViewController()
        let nav = UINavigationController(rootViewController: mistakeNoteVC)
        return nav
    }
}
