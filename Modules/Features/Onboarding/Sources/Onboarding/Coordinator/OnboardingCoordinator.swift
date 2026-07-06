import UIKit
import QRIZUtils
import QRIZNetwork
import OnboardingInterface

// MARK: - Public (메인 앱에 노출)

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

public struct DefaultOnboardingCoordinatorFactory: OnboardingCoordinatorFactory {
    private let onboardingService: OnboardingService
    private let userInfoService: UserInfoService
    private let dailyService: any DailyService

    public init(
        onboardingService: OnboardingService,
        userInfoService: UserInfoService,
        dailyService: any DailyService
    ) {
        self.onboardingService = onboardingService
        self.userInfoService = userInfoService
        self.dailyService = dailyService
    }

    @MainActor
    public func makeOnboardingCoordinator(
        navigationController: UINavigationController
    ) -> any OnboardingCoordinator {
        OnboardingCoordinatorImpl(
            navigationController: navigationController,
            onboardingService: onboardingService,
            userInfoService: userInfoService,
            dailyService: dailyService
        )
    }
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
