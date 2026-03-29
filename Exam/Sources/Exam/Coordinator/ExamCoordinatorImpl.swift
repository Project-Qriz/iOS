import UIKit
import SwiftUI
import QRIZUtils
import Network
import ExamKit
import Conceptbook
import MistakeNote

@MainActor
final class ExamCoordinatorImpl: ExamNavigating, NavigationGuard {

    // MARK: - Properties
    weak var delegate: ExamCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var examListViewController: UIViewController?
    private var examListViewModel: ExamListViewModel?
    // ExamResultView는 @ObservedObject로 ViewModel을 참조하므로 소유권이 없음.
    // 코디네이터가 강한 참조를 유지해 조기 해제를 방지함.
    private var examResultViewModel: ExamResultViewModel?
    private let service: any ExamService
    private var currentExamId: Int = 0

    // NavigationGuard
    var isNavigating: Bool = false

    // MARK: - Initializers
    init(navigationController: UINavigationController, examService: any ExamService) {
        self.navigationController = navigationController
        self.service = examService
    }

    // MARK: - Coordinator
    func start() -> UIViewController {
        showExamList()
        return navigationController
    }

    // MARK: - ExamNavigating
    func showExamList() {
        guardNavigation {
            let vm = ExamListViewModel(examService: self.service)
            let vc = ExamListViewController(viewModel: vm)
            vc.coordinator = self
            self.examListViewController = vc
            self.examListViewModel = vm
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
            let vm = ExamTestViewModel(examId: examId, examService: self.service)
            let vc = ExamTestViewController(viewModel: vm)
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    func showExamResult(examId: Int) {
        self.currentExamId = examId
        guardNavigation {
            let vm = ExamResultViewModel(examId: examId, examService: self.service)
            vm.delegate = self
            self.examResultViewModel = vm
            let vc = UIHostingController(rootView: ExamResultView(viewModel: vm))
            vc.hidesBottomBarWhenPushed = true
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
        guardNavigation { [service = self.service, currentExamId = self.currentExamId] in
            let viewModel = ProblemDetailViewModel {
                let response = try await service.getExamResultDetail(
                    examId: currentExamId,
                    questionId: questionId
                )
                return response.data.toEntity()
            }
            let vc = ProblemDetailViewController(viewModel: viewModel)
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

    func quitExam() {
        if let examListVC = examListViewController, let examListVM = examListViewModel {
            _ = self.navigationController.popToViewController(examListVC, animated: true)
            examListVM.reloadList()
        }
    }
}

// MARK: - ExamResultViewModelDelegate

extension ExamCoordinatorImpl: ExamResultViewModelDelegate {
    func didRequestQuitExam() {
        quitExam()
    }

    func didRequestMoveToConcept() {
        navigationController.tabBarController?.tabBar.isHidden = false
        delegate?.moveFromExamToConcept(self)
    }

    func didRequestMoveToResultDetail() {
        guard let resultDetailData = examResultViewModel?.resultDetailData else { return }
        showResultDetail(resultDetailData: resultDetailData)
    }

    func didRequestShowProblemDetail(questionId: Int) {
        showProblemExplanation(questionId: questionId)
    }
}

// MARK: - ProblemDetailCoordinating

extension ExamCoordinatorImpl: ProblemDetailCoordinating {
    func navigateToConceptTab() {
        delegate?.moveFromExamToConcept(self)
    }

    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem) {
        showConcept(chapter: chapter, conceptItem: conceptItem)
    }
}
