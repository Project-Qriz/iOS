import UIKit
import QRIZUtils
import QRIZNetwork
import DailyInterface

// MARK: - Public (메인 앱에 노출)

@MainActor
public func makeDailyCoordinator(
    navigationController: UINavigationController,
    dailyService: any DailyService,
    day: Int,
    type: DailyLearnType,
    adService: any AdService
) -> any DailyCoordinator {
    DailyCoordinatorImpl(
        navigationController: navigationController,
        dailyService: dailyService,
        day: day,
        type: type,
        adService: adService
    )
}

public struct DefaultDailyCoordinatorFactory: DailyCoordinatorFactory {
    public init() {}

    @MainActor
    public func makeDailyCoordinator(
        navigationController: UINavigationController,
        dailyService: any DailyService,
        day: Int,
        type: DailyLearnType,
        adService: any AdService
    ) -> any DailyCoordinator {
        DailyCoordinatorImpl(
            navigationController: navigationController,
            dailyService: dailyService,
            day: day,
            type: type,
            adService: adService
        )
    }
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
