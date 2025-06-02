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
protocol ExamSelectionDelegate: AnyObject {
    /// 시험을 등록 및 업데이트 시 호출되는 델리게이트
    func didUpdateExamSchedule()
}

@MainActor
final class HomeCoordinatorImpl: HomeCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let examService: ExamScheduleService
    private var homeVM: HomeViewModel?
    var childCoordinators: [Coordinator] = []
    
    init(examService: ExamScheduleService) {
        self.examService = examService
    }
    
    func start() -> UIViewController {
        let viewModel = HomeViewModel(examScheduleService: examService)
        homeVM = viewModel
        let homeVC = HomeViewController(homeVM: viewModel)
        let navi = UINavigationController(rootViewController: homeVC)
        homeVC.coordinator = self
        navigationController = navi
        return navi
    }
    
    func showExamSelectionSheet() {
        let viewModel = ExamScheduleSelectionViewModel(examScheduleService: examService)
        let vc = ExamScheduleSelectionViewController(examScheduleSelectionVM: viewModel)
        viewModel.delegate = self
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

// MARK: - ExamSelectionDelegate

extension HomeCoordinatorImpl: ExamSelectionDelegate {
    func didUpdateExamSchedule() {
        homeVM?.reloadExamSchedule()
    }
}
