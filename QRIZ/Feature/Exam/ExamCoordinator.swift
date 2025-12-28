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
    /// ExamCoordinator 자체를 벗어나 홈으로 이동하는 메서드
    func didQuitExam(_ coordinator: ExamCoordinator)
    func moveFromExamToConcept(_ coordinator: ExamCoordinator)
}

@MainActor
final class ExamCoordinatorImpl: ExamCoordinator, NavigationGuard {

    // MARK: - Properties
    weak var delegate: ExamCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var examListViewController: UIViewController?
    private var examListViewModel: ExamListViewModel?
    private let service: ExamService

    // NavigationGuard
    var isNavigating: Bool = false
    
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
        guardNavigation {
            let vm = ExamListViewModel(examService: service)
            let vc = ExamListViewController(viewModel: vm)
            vc.coordinator = self
            examListViewController = vc
            examListViewModel = vm
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showExamSummary(examId: Int) {
        guardNavigation {
            let vm = ExamSummaryViewModel(examId: examId)
            let vc = ExamSummaryViewController(viewModel: vm)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showExamTest(examId: Int) {
        guardNavigation {
            let vm = ExamTestViewModel(examId: examId, examService: service)
            let vc = ExamTestViewController(viewModel: vm)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showExamResult(examId: Int) {
        guardNavigation {
            let vm = ExamResultViewModel(examId: examId, examService: service)
            let vc = ExamResultViewController(viewModel: vm)
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
    
    /// Exam 내부 테스트나 결과에서 ExamList로 이동하는 메서드
    func quitExam() {
        if let examListVC = examListViewController, let examListVM = examListViewModel {
            _ = self.navigationController.popToViewController(examListVC, animated: true)
            examListVM.reloadList()
        }
    }
}
