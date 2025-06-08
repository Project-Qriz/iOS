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
    func showOnboarding()
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
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService
    private var homeVM: HomeViewModel?
    
    var childCoordinators: [Coordinator] = []
    private var onboardingCoordinator: OnboardingCoordinator?
    
    init(
        examService: ExamScheduleService,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService
    ) {
        self.examService = examService
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
    }
    
    func start() -> UIViewController {
        let viewModel = HomeViewModel(examScheduleService: examService)
        homeVM = viewModel
        let homeVC = HomeViewController(homeVM: viewModel)
        homeVC.coordinator = self
        
        let navi = UINavigationController(rootViewController: homeVC)
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
    
    func showOnboarding() {
        guard let navi = navigationController else { return }
        let onboarding = OnboardingCoordinatorImpl(
            navigationController: navi,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
        onboarding.delegate = self
        childCoordinators.append(onboarding)
        _ = onboarding.start()
    }
}

// MARK: - ExamSelectionDelegate

extension HomeCoordinatorImpl: ExamSelectionDelegate {
    func didUpdateExamSchedule() {
        homeVM?.reloadExamSchedule()
    }
}

// MARK: - OnboardingCoordinatorDelegate

extension HomeCoordinatorImpl: OnboardingCoordinatorDelegate {
    func didFinishOnboarding(_ coordinator: OnboardingCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
        homeVM?.reloadUserState()
    }
}
