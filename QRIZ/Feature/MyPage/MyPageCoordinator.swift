//
//  MyPageCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MyPageCoordinator: Coordinator {
    func showTermsDetail(for term: TermItem)
    func showExamSelectionSheet()
}

@MainActor
final class MyPageCoordinatorImp: MyPageCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let examService: ExamScheduleService
    var childCoordinators: [Coordinator] = []
    
    init(examService: ExamScheduleService) {
        self.examService = examService
    }
    
    func start() -> UIViewController {
        let viewModel = MyPageViewModel(userName: UserInfoManager.shared.name)
        let myPageVC = MyPageViewController(viewModel: viewModel)
        myPageVC.coordinator = self
        
        let navi = UINavigationController(rootViewController: myPageVC)
        self.navigationController = navi
        return navi
    }
    
    func showExamSelectionSheet() {
        let viewModel = ExamScheduleSelectionViewModel(examScheduleService: examService)
        let vc = ExamScheduleSelectionViewController(examScheduleSelectionVM: viewModel)
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
    
    func showTermsDetail(for term: TermItem) {
        let viewModel = TermsDetailViewModel(termItem: term)
        let vc = TermsDetailViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.dismissDelegate = self
        navigationController?.present(vc, animated: true)
    }
}

// MARK: - TermsDetailDismissible

extension MyPageCoordinatorImp: TermsDetailDismissible {
    func dismissTermsDetail() {
        navigationController?.dismiss(animated: true)
    }
}
