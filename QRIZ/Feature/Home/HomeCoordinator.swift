//
//  HomeCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol HomeCoordinator: Coordinator {
    func showExamSelectionSheet()
}

@MainActor
final class HomeCoordinatorImp: HomeCoordinator {
    
    private let examService: ExamScheduleService
    private weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    
    init(examService: ExamScheduleService) {
        self.examService = examService
    }
    
    func start() -> UIViewController {
        let homeVM = HomeViewModel(examScheduleService: examService)
        let homeVC = HomeViewController(homeVM: homeVM)
        let navi = UINavigationController(rootViewController: homeVC)
        navigationController = navi
        return navi
    }
    
    func showExamSelectionSheet() {
        let vm = ExamScheduleSelectionViewModel(examScheduleService: examService)
        let vc = ExamScheduleSelectionViewController(examScheduleSelectionVM: vm)
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            
            let fit = UISheetPresentationController.Detent.custom(
                identifier: .init("fit")
            ) { context in min(540, context.maximumDetentValue) }
            
            sheet.detents = [fit]
            sheet.selectedDetentIdentifier = .init("fit")
        }
        
        navigationController?.present(vc, animated: true)
    }
}
