import UIKit
import SwiftUI
import Combine
import QRIZUtils
import Network

@MainActor
final class OnboardingCoordinatorImpl: OnboardingNavigating, NavigationGuard {

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
            vm.onNavigate = { [weak self] in self?.showCheckConcept() }
            let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
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
            vm.onNavigate = { [weak self] in self?.showPreviewTest() }
            let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
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
            vm.onNavigate = { [weak self] in
                guard let self else { return }
                self.delegate?.didFinishOnboarding(self)
            }
            let vc = UIHostingController(rootView: GreetingView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
