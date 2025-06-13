//
//  ExamCoordinator.swift
//  QRIZ
//
//  Created by 이창현 on 6/12/25.
//

import UIKit

@MainActor
protocol ExamCoordinator: Coordinator {
    var delegate: ExamCoordinatorDelegate? { get set }
    func showExamList()
    func showExamSummary(examId: Int)
    func showExamTest(examId: Int)
    func showExamResult(examId: Int)
    func showResultDetail(resultDetailData: ResultDetailData)
    func quitExam()
}

@MainActor
protocol ExamCoordinatorDelegate: AnyObject {
    func didQuitExam(_ coordinator: ExamCoordinator)
    func moveFromExamToConcept(_ coordinator: ExamCoordinator)
}

@MainActor
final class ExamCoordinatorImpl: ExamCoordinator {
    
    // MARK: - Properties
    weak var delegate: ExamCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var examListViewController: UIViewController?
    private var examListViewModel: ExamListViewModel?
    private let service: ExamService
    
    // MARK: - Initializers
    init(navigationController: UINavigationController, examService: ExamService) {
        self.navigationController = navigationController
        self.service = examService
    }
    
    // MARK: - Methods
    func start() -> UIViewController {
        showExamList()
        return navigationController
    }
    
    func showExamList() {
        let vm = ExamListViewModel(examService: service)
        let vc = ExamListViewController(viewModel: vm)
        vc.coordinator = self
        examListViewController = vc
        examListViewModel = vm
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showExamSummary(examId: Int) {
        let vm = ExamSummaryViewModel(examId: examId)
        let vc = ExamSummaryViewController(viewModel: vm)
        vc.coordinator = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showExamTest(examId: Int) {
        let vm = ExamTestViewModel(examId: examId, examService: service)
        let vc = ExamTestViewController(viewModel: vm)
        vc.coordinator = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showExamResult(examId: Int) {
        let vm = ExamResultViewModel(examId: examId, examService: service)
        let vc = ExamResultViewController(viewModel: vm)
        vc.coordinator = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showResultDetail(resultDetailData: ResultDetailData) {
        let vm = TestResultDetailViewModel(resultDetailData: resultDetailData)
        let vc = TestResultDetailViewController(viewModel: vm)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func quitExam() {
        if let examListVC = examListViewController, let examListVM = examListViewModel {
            _ = self.navigationController.popToViewController(examListVC, animated: true)
            examListVM.reloadList()
        }
    }
}
