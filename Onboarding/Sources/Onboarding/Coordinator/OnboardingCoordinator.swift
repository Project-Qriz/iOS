import UIKit
import Combine
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

public extension OnboardingCoordinator {
    static func make(
        navigationController: UINavigationController,
        onboardingService: OnboardingService,
        userInfoService: UserInfoService
    ) -> any OnboardingCoordinator {
        OnboardingCoordinatorImpl(
            navigationController: navigationController,
            onboardingService: onboardingService,
            userInfoService: userInfoService
        )
    }
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol OnboardingNavigating: AnyObject {
    func showBeginOnboarding()
    func showCheckConcept()
    func showBeginPreviewTest()
    func showPreviewTest()
    func showPreviewResult()
    func showGreeting()
    var delegate: OnboardingCoordinatorDelegate? { get }
}
