//
//  ConceptBookCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol ConceptBookCoordinator: Coordinator {
}

@MainActor
final class ConceptBookCoordinatorImp: ConceptBookCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let conceptBookVM = ConceptBookViewModel()
        let conceptBookVC = ConceptBookViewController(conceptBookVM: conceptBookVM)
        let nav = UINavigationController(rootViewController: conceptBookVC)
        return nav
    }
}
