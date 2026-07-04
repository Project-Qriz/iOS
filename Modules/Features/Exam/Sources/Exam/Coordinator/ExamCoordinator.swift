import UIKit
import QRIZUtils
import QRIZNetwork
import ExamInterface

// MARK: - Public (메인 앱에 노출)

@MainActor
public func makeExamCoordinator(
    navigationController: UINavigationController,
    examService: any ExamService,
    adService: any AdService
) -> any ExamCoordinator {
    ExamCoordinatorImpl(navigationController: navigationController, examService: examService, adService: adService)
}

public struct DefaultExamCoordinatorFactory: ExamCoordinatorFactory {
    public init() {}

    @MainActor
    public func makeExamCoordinator(
        navigationController: UINavigationController,
        examService: any ExamService,
        adService: any AdService
    ) -> any ExamCoordinator {
        ExamCoordinatorImpl(navigationController: navigationController, examService: examService, adService: adService)
    }
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
