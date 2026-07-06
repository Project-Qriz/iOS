import UIKit
import QRIZUtils

@MainActor
public protocol OnboardingCoordinator: Coordinator {
    var delegate: OnboardingCoordinatorDelegate? { get set }
}

@MainActor
public protocol OnboardingCoordinatorDelegate: AnyObject {
    func didFinishOnboarding(_ coordinator: any OnboardingCoordinator)
}

@MainActor
public protocol OnboardingCoordinatorFactory {
    func makeOnboardingCoordinator(
        navigationController: UINavigationController
    ) -> any OnboardingCoordinator
}
