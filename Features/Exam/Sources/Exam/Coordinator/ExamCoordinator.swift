import UIKit
import QRIZUtils
import Network

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol ExamCoordinator: Coordinator {
    var delegate: ExamCoordinatorDelegate? { get set }
}

@MainActor
public protocol ExamCoordinatorDelegate: AnyObject {
    func didQuitExam(_ coordinator: any ExamCoordinator)
    func moveFromExamToConcept(_ coordinator: any ExamCoordinator)
}

@MainActor
public func makeExamCoordinator(
    navigationController: UINavigationController,
    examService: any ExamService
) -> any ExamCoordinator {
    ExamCoordinatorImpl(navigationController: navigationController, examService: examService)
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol ExamNavigating: ExamCoordinator {
    func showExamList()
    func showExamSummary(examId: Int)
    func showExamTest(examId: Int)
    func showExamResult(examId: Int)
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func cancelExamList()
    func quitExam()
}
