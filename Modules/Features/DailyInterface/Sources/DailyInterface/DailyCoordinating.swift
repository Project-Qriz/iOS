import UIKit
import QRIZUtils
import QRIZNetwork

@MainActor
public protocol DailyCoordinator: Coordinator {
    var delegate: DailyCoordinatorDelegate? { get set }
}

@MainActor
public protocol DailyCoordinatorDelegate: AnyObject {
    func didQuitDaily(_ coordinator: any DailyCoordinator)
    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator)
    func conceptPDFViewController(chapter: Chapter, conceptItem: ConceptItem) -> UIViewController
}

@MainActor
public protocol DailyCoordinatorFactory {
    func makeDailyCoordinator(
        navigationController: UINavigationController,
        dailyService: any DailyService,
        day: Int,
        type: DailyLearnType,
        adService: any AdService
    ) -> any DailyCoordinator
}
