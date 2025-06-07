//
//  OnboardingCoordinator.swift
//  QRIZ
//
//  Created by ch on 6/6/25.
//

import UIKit
import Combine

@MainActor
protocol OnboardingCoordinator: Coordinator {
    var delegate: OnboardingCoordinatorDelegate? { get set }
    func showBeginOnboarding()
    func showCheckConcept()
    func showBeginPreviewTest()
    func showPreviewTest()
    func showPreviewResult()
    func showGreeting()
}

@MainActor
protocol OnboardingCoordinatorDelegate: AnyObject {
    func didFinishOnboarding(_ coordinator: OnboardingCoordinator)
}

@MainActor
final class OnboardingCoordinatorImpl: OnboardingCoordinator {
    
    // MARK: - Properties
    weak var delegate: OnboardingCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService
    
    var previewTestStatus: PreviewTestStatus {
        UserInfoManager.shared.previewTestStatus
    }
    
    // MARK: - Initializers
    init(navigationController: UINavigationController, onboardingService: OnboardingService, userInfoService: UserInfoService) {
        self.navigationController = navigationController
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
    }
    
    func start() -> UIViewController {
        switch previewTestStatus {
        case .notStarted:
            showBeginOnboarding()
        case .surveyCompleted:
            showBeginPreviewTest()
        default:
            // case : previewSkipped, previewCompleted
            break
        }
        return navigationController
    }
    
    func showBeginOnboarding() {
        let vm = BeginOnboardingViewModel()
        let vc = BeginOnboardingViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCheckConcept() {
        let vm = CheckConceptViewModel(onboardingService: onboardingService)
        let vc = CheckConceptViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showBeginPreviewTest() {
        let vm = BeginPreviewTestViewModel()
        let vc = BeginPreviewTestViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPreviewTest() {
        let vm = PreviewTestViewModel(onboardingService: onboardingService)
        let vc = PreviewTestViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPreviewResult() {
        let vm = PreviewResultViewModel(onboardingService: onboardingService)
        let vc = PreviewResultViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showGreeting() {
        let vm = GreetingViewModel(userInfoService: userInfoService)
        let vc = GreetingViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
