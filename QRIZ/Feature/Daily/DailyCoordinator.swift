//
//  DailyCoordinator.swift
//  QRIZ
//
//  Created by 이창현 on 6/12/25.
//

import UIKit

@MainActor
protocol DailyCoordinator: Coordinator {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func dismissModal()
}

@MainActor
final class DailyCoordinatorImpl: DailyCoordinator {
    
    // MARK: - Properties
    private let navigationController: UINavigationController
    private var modalNavigationController: UINavigationController?
    private let service: DailyService
    private let day: Int
    private let type: DailyLearnType
    
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
        let vm = DailyLearnViewModel(day: day, type: type, dailyService: service)
        let vc = DailyLearnViewController(dailyLearnViewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        let vm = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        let vc = ConceptPDFViewController(conceptPDFViewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDailyTest() {
        let vm = DailyTestViewModel(dailyTestType: type, day: day, dailyService: service)
        let vc = DailyTestViewController(viewModel: vm)
        vc.coordinator = self
        modalNavigationController = nil
        modalNavigationController = UINavigationController(rootViewController: vc)
        modalNavigationController?.modalPresentationStyle = .fullScreen
        if let modal = modalNavigationController {
            navigationController.present(modal, animated: true)
        }
    }
    
    func showDailyResult() {
        let vm = DailyResultViewModel(dailyTestType: type, day: day, dailyService: service)
        let vc = DailyResultViewController(viewModel: vm)
        vc.coordinator = self
        if let modal = modalNavigationController {
            modal.pushViewController(vc, animated: true)
        } else {
            modalNavigationController = UINavigationController(rootViewController: vc)
            modalNavigationController?.modalPresentationStyle = .fullScreen
            if let modalNavi = modalNavigationController {
                navigationController.pushViewController(modalNavi, animated: true)
            }
        }
    }
    
    func showResultDetail(resultDetailData: ResultDetailData) {
        let vm = TestResultDetailViewModel(resultDetailData: resultDetailData)
        let vc = TestResultDetailViewController(viewModel: vm)
        if let modal = modalNavigationController {
            modal.pushViewController(vc, animated: true)
        }
    }
    
    func dismissModal() {
        if let modal = modalNavigationController {
            modal.dismiss(animated: true)
            modalNavigationController = nil
        }
    }
}
