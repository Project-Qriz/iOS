//
//  DailyCoordinator.swift
//  QRIZ
//
//  Created by 이창현 on 6/12/25.
//

import UIKit

@MainActor
protocol DailyCoordinator: Coordinator {
    var delegate: DailyCoordinatorDelegate? { get set }
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()
}

@MainActor
protocol DailyCoordinatorDelegate: AnyObject {
    /// DailyCoordinator 자체를 벗어나 홈으로 이동하는 메서드
    func didQuitDaily(_ coordinator: DailyCoordinator)
    func moveFromDailyToConcept(_ coordinator: DailyCoordinator)
}

@MainActor
final class DailyCoordinatorImpl: DailyCoordinator, NavigationGuard {

    // MARK: - Properties
    weak var delegate: DailyCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var dailyLearnViewController: DailyLearnViewController?
    private var dailyLearnViewModel: DailyLearnViewModel?
    private let service: DailyService
    private let day: Int
    private let type: DailyLearnType

    // NavigationGuard
    var isNavigating: Bool = false
    
    // MARK: - Initializers
    init(
        navigationController: UINavigationController,
        dailyService: DailyService,
        day: Int,
        type: DailyLearnType) {
            self.navigationController = navigationController
            self.service = dailyService
            self.day = day
            self.type = type
        }
    
    // MARK: - Methods
    func start() -> UIViewController {
        showDailyLearn()
        return navigationController
    }
    
    func showDailyLearn() {
        guardNavigation {
            let vm = DailyLearnViewModel(day: day, type: type, dailyService: service)
            let vc = DailyLearnViewController(dailyLearnViewModel: vm)
            dailyLearnViewController = vc
            dailyLearnViewModel = vm
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        guardNavigation {
            let vm = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
            let vc = ConceptPDFViewController(conceptPDFViewModel: vm)
            let appearance = UINavigationBar.defaultBackButtonStyle()

            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance

            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showDailyTest() {
        guardNavigation {
            let vm = DailyTestViewModel(dailyTestType: type, day: day, dailyService: service)
            let vc = DailyTestViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showDailyResult() {
        guardNavigation {
            let vm = DailyResultViewModel(dailyTestType: type, day: day, dailyService: service)
            let vc = DailyResultViewController(viewModel: vm)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showResultDetail(resultDetailData: ResultDetailData) {
        guardNavigation {
            let vm = TestResultDetailViewModel(resultDetailData: resultDetailData)
            let vc = TestResultDetailViewController(viewModel: vm)
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func showProblemExplanation(questionId: Int) {
        guardNavigation {
            let viewModel = ProblemDetailViewModel(
                service: service,
                questionId: questionId,
                dayNumber: day
            )
            let vc = ProblemDetailViewController(viewModel: viewModel)
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        }
    }

    /// Daily 내부 테스트나 결과에서 DailyLearn으로 이동하는 메서드
    func quitDaily() {
        if let dailyLearnVC = dailyLearnViewController, let dailyLearnVM = dailyLearnViewModel {
            _ = self.navigationController.popToViewController(dailyLearnVC, animated: true)
            dailyLearnVM.reloadData()
        }
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
