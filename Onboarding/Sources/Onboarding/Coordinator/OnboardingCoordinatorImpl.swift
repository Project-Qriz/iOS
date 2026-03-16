import UIKit
import Combine
import QRIZUtils
import Network

@MainActor
final class OnboardingCoordinatorImpl: OnboardingCoordinator, OnboardingNavigating, NavigationGuard {

    // MARK: - Properties
    weak var delegate: OnboardingCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService

    var previewTestStatus: PreviewTestStatus {
        UserInfoManager.shared.previewTestStatus
    }

    // NavigationGuard
    var isNavigating: Bool = false

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
        guardNavigation {
            let vm = BeginOnboardingViewModel()
            let vc = BeginOnboardingViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showCheckConcept() {
        guardNavigation {
            let vm = CheckConceptViewModel(onboardingService: onboardingService)
            let vc = CheckConceptViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showBeginPreviewTest() {
        guardNavigation {
            let vm = BeginPreviewTestViewModel()
            let vc = BeginPreviewTestViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewTest() {
        guardNavigation {
            let vm = PreviewTestViewModel(onboardingService: onboardingService)
            let vc = PreviewTestViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewResult() {
        guardNavigation {
            let vm = PreviewResultViewModel(onboardingService: onboardingService)
            let vc = PreviewResultViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showGreeting() {
        guardNavigation {
            let vm = GreetingViewModel(userInfoService: userInfoService)
            let vc = GreetingViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
