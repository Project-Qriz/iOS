import UIKit
import QRIZUtils
import Network
import ExamKit
import Conceptbook
import MistakeNote

@MainActor
final class DailyCoordinatorImpl: DailyNavigating, NavigationGuard {

    // MARK: - Properties
    weak var delegate: DailyCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var dailyLearnViewController: DailyLearnViewController?
    private var dailyLearnViewModel: DailyLearnViewModel?
    private let service: any DailyService
    private let day: Int
    private let type: DailyLearnType

    // NavigationGuard
    var isNavigating: Bool = false

    // MARK: - Initializer
    init(
        navigationController: UINavigationController,
        dailyService: any DailyService,
        day: Int,
        type: DailyLearnType
    ) {
        self.navigationController = navigationController
        self.service = dailyService
        self.day = day
        self.type = type
    }

    // MARK: - Coordinator
    func start() -> UIViewController {
        showDailyLearn()
        return navigationController
    }

    // MARK: - DailyNavigating
    func showDailyLearn() {
        guardNavigation {
            let vm = DailyLearnViewModel(day: self.day, type: self.type, dailyService: self.service)
            let vc = DailyLearnViewController(dailyLearnViewModel: vm)
            self.dailyLearnViewController = vc
            self.dailyLearnViewModel = vm
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        guardNavigation {
            let vc = makeConceptPDFViewController(chapter: chapter, conceptItem: conceptItem)
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showDailyTest() {
        guardNavigation {
            let vm = DailyTestViewModel(dailyTestType: self.type, day: self.day, dailyService: self.service)
            let vc = DailyTestViewController(viewModel: vm)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showDailyResult() {
        guardNavigation {
            let vm = DailyResultViewModel(dailyTestType: self.type, day: self.day, dailyService: self.service)
            let vc = DailyResultViewController(viewModel: vm)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showResultDetail(resultDetailData: ResultDetailData) {
        guardNavigation {
            let vm = TestResultDetailViewModel(resultDetailData: resultDetailData)
            let vc = TestResultDetailViewController(viewModel: vm)
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showProblemExplanation(questionId: Int) {
        guardNavigation { [service = self.service, day = self.day] in
            let viewModel = ProblemDetailViewModel {
                let response = try await service.getDailyResultDetail(
                    dayNumber: day,
                    questionId: questionId
                )
                return response.data.toEntity()
            }
            let vc = ProblemDetailViewController(viewModel: viewModel)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func quitDaily() {
        if let dailyLearnVC = dailyLearnViewController, let dailyLearnVM = dailyLearnViewModel {
            _ = navigationController.popToViewController(dailyLearnVC, animated: true)
            dailyLearnVM.reloadData()
        }
    }

    func finishDaily() {
        delegate?.didQuitDaily(self)
    }
}

// MARK: - ProblemDetailCoordinating
extension DailyCoordinatorImpl: ProblemDetailCoordinating {
    func navigateToConceptTab() {
        delegate?.moveFromDailyToConcept(self)
    }

    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem) {
        showConcept(chapter: chapter, conceptItem: conceptItem)
    }
}
