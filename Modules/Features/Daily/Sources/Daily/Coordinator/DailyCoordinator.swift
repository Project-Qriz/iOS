import UIKit
import QRIZUtils
import Network

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol DailyCoordinator: Coordinator {
    var delegate: DailyCoordinatorDelegate? { get set }
}

@MainActor
public protocol DailyCoordinatorDelegate: AnyObject {
    func didQuitDaily(_ coordinator: any DailyCoordinator)
    func moveFromDailyToConcept(_ coordinator: any DailyCoordinator)
}

@MainActor
public func makeDailyCoordinator(
    navigationController: UINavigationController,
    dailyService: any DailyService,
    day: Int,
    type: DailyLearnType
) -> any DailyCoordinator {
    DailyCoordinatorImpl(
        navigationController: navigationController,
        dailyService: dailyService,
        day: day,
        type: type
    )
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol DailyNavigating: DailyCoordinator {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()       // DailyTest/DailyResult → DailyLearn 복귀
    func finishDaily()     // DailyLearn 뒤로가기 → Daily 세션 전체 종료
}
