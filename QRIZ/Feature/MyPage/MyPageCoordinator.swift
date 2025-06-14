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
    func showResetAlert(confirm: @escaping () -> Void)
    func showExamSelectionSheet()
}

@MainActor
final class MyPageCoordinatorImpl: MyPageCoordinator {
    
    private weak var navigationController: UINavigationController?
    weak var examDelegate: ExamSelectionDelegate?
    private let examService: ExamScheduleService
    private let myPageService: MyPageService
    var childCoordinators: [Coordinator] = []
    
    init(
        examService: ExamScheduleService,
        myPageService: MyPageService
    ) {
        self.examService = examService
        self.myPageService = myPageService
    }
    
    func start() -> UIViewController {
        let viewModel = MyPageViewModel(
            userName: UserInfoManager.shared.name,
            myPageService: myPageService
        )
        let myPageVC = MyPageViewController(viewModel: viewModel)
        myPageVC.coordinator = self
        
        let navi = UINavigationController(rootViewController: myPageVC)
        self.navigationController = navi
        return navi
    }
    
    func showResetAlert(confirm: @escaping () -> Void) {
        let alert = TwoButtonCustomAlertViewController(
            title: "플랜을 초기화 할까요?",
            description: "지금까지의 플랜이 초기화되며,\nDay1부터 다시 시작됩니다.",
            confirmAction: UIAction { [weak self] _ in
                confirm()
                self?.navigationController?.dismiss(animated: true)
            },
            cancelAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )
        navigationController?.present(alert, animated: true)
    }
    
    func showExamSelectionSheet() {
        let viewModel = ExamScheduleSelectionViewModel(examScheduleService: examService)
        viewModel.delegate = examDelegate
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

extension MyPageCoordinatorImpl: TermsDetailDismissible {
    func dismissTermsDetail() {
        navigationController?.dismiss(animated: true)
    }
}
