import UIKit
import SwiftUI
import QRIZUtils
import Network

@MainActor
final class OnboardingCoordinatorImpl: OnboardingNavigating, NavigationGuard {

    // MARK: - Properties

    weak var delegate: OnboardingCoordinatorDelegate?
    private let navigationController: UINavigationController
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService

    private var previewTestStatus: PreviewTestStatus {
        UserInfoManager.shared.previewTestStatus
    }

    // MARK: - NavigationGuard

    var isNavigating: Bool = false

    // MARK: - Initializer

    init(
        navigationController: UINavigationController,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService
    ) {
        self.navigationController = navigationController
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
    }

    // MARK: - Coordinator

    func start() -> UIViewController {
        switch previewTestStatus {
        case .notStarted:
            showBeginOnboarding()
        case .surveyCompleted:
            showBeginPreviewTest()
        case .previewSkipped, .previewCompleted:
            break
        }
        return navigationController
    }

    // MARK: - Navigation

    func showBeginOnboarding() {
        guardNavigation {
            let vm = BeginOnboardingViewModel(onNavigate: { [weak self] in self?.showCheckConcept() })
            let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showCheckConcept() {
        guardNavigation {
            let vm = CheckConceptViewModel(
                onboardingService: onboardingService,
                onNavigateToPreviewTest: { [weak self] in self?.showBeginPreviewTest() },
                onNavigateToGreeting: { [weak self] in self?.showGreeting() }
            )
            let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showBeginPreviewTest() {
        guardNavigation {
            let vm = BeginPreviewTestViewModel(onNavigate: { [weak self] in self?.showPreviewTest() })
            let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showPreviewTest() {
        guardNavigation {
            let vc = PreviewTestViewController(
                onboardingService: onboardingService,
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
                onNavigateToGreeting: { [weak self] in self?.showGreeting() }
            )
            let vc = UIHostingController(rootView: PreviewResultView(viewModel: vm))
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showGreeting() {
        guardNavigation {
            let vm = GreetingViewModel(
                userInfoService: userInfoService,
                onNavigate: { [weak self] in self?.finishOnboarding() }
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
