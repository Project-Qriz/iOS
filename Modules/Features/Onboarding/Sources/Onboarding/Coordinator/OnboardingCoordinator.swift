import UIKit
import QRIZUtils
import Network

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol OnboardingCoordinator: Coordinator {
    var delegate: OnboardingCoordinatorDelegate? { get set }
}

@MainActor
public protocol OnboardingCoordinatorDelegate: AnyObject {
    func didFinishOnboarding(_ coordinator: any OnboardingCoordinator)
}

@MainActor
public func makeOnboardingCoordinator(
    navigationController: UINavigationController,
    onboardingService: OnboardingService,
    userInfoService: UserInfoService,
    dailyService: any DailyService
) -> any OnboardingCoordinator {
    OnboardingCoordinatorImpl(
        navigationController: navigationController,
        onboardingService: onboardingService,
        userInfoService: userInfoService,
        dailyService: dailyService
    )
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol OnboardingNavigating: OnboardingCoordinator {
    func showBeginOnboarding()
    func showCheckConcept()
    func showBeginPreviewTest()
    func showPreviewTest()
    func showPreviewResult()
    func showPlanDurationSelection()
    func showGreeting()
}
