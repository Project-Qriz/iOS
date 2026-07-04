import UIKit
import SwiftUI
import QRIZUtils
import QRIZNetwork
import OnboardingInterface

@MainActor
final class OnboardingCoordinatorImpl: OnboardingNavigating, NavigationGuard {

    // MARK: - Properties

    weak var delegate: OnboardingCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService
    private let dailyService: any DailyService

    private var previewTestStatus: PreviewTestStatus {
        UserInfoManager.shared.previewTestStatus
    }

    // MARK: - NavigationGuard

    var isNavigating: Bool = false

    // MARK: - Initializer

    init(
        navigationController: UINavigationController,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService,
        dailyService: any DailyService
    ) {
        self.navigationController = navigationController
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
        self.dailyService = dailyService
    }

    // MARK: - Coordinator

    func start() -> UIViewController {
        switch previewTestStatus {
        case .notStarted:
            showBeginOnboarding()
        case .surveyCompleted:
            showBeginPreviewTest()
        case .previewSkipped, .previewCompleted:
            assertionFailure("OnboardingCoordinator previewSkipped/previewCompleted 상태에서 시작 오류")
            break
        }
        return navigationController
    }

    // MARK: - Navigation

    func showBeginOnboarding() {
        guardNavigation {
            let vm = BeginOnboardingViewModel(onNavigate: { [weak self] in self?.showCheckConcept() })
            let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showCheckConcept() {
        guardNavigation {
            let vm = CheckConceptViewModel(
                onboardingService: onboardingService,
                onNavigate: { [weak self] destination in
                    switch destination {
                    case .previewTest: self?.showBeginPreviewTest()
                    case .greeting: self?.showPlanDurationSelection()
                    }
                },
                userInfo: .shared
            )
            let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showBeginPreviewTest() {
        guardNavigation {
            let vm = BeginPreviewTestViewModel(onNavigate: { [weak self] in self?.showPreviewTest() })
            let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewTest() {
        guardNavigation {
            let vm = PreviewTestViewModel(onboardingService: onboardingService)
            let vc = PreviewTestViewController(
                viewModel: vm,
                onNavigateToResult: { [weak self] in self?.showPreviewResult() },
                onNavigateToHome: { [weak self] in self?.finishOnboarding() }
            )
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewResult() {
        guardNavigation {
            let vm = PreviewResultViewModel(
                onboardingService: onboardingService,
                onNavigateToGreeting: { [weak self] in self?.showPlanDurationSelection() },
                userInfo: .shared
            )
            let vc = UIHostingController(rootView: PreviewResultView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPlanDurationSelection() {
        guardNavigation {
            let vm = PlanDurationSelectionViewModel(
                dailyService: dailyService,
                onNavigate: { [weak self] in self?.showGreeting() }
            )
            let vc = UIHostingController(rootView: PlanDurationSelectionView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showGreeting() {
        guardNavigation {
            let vm = GreetingViewModel(
                userInfoService: userInfoService,
                onNavigate: { [weak self] in self?.finishOnboarding() },
                userInfo: .shared
            )
            let vc = UIHostingController(rootView: GreetingView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Private

private extension OnboardingCoordinatorImpl {

    func finishOnboarding() {
        delegate?.didFinishOnboarding(self)
    }
}
