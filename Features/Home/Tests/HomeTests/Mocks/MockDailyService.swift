import Foundation
import Network
import QRIZUtils

@MainActor
final class MockDailyService: DailyService {

    var getDailyPlanResult: Result<DailyPlanResponse, Error> = .success(.make())
    var resetPlanResult: Result<DailyResetResponse, Error> = .success(.make())

    private(set) var resetPlanCallCount = 0

    func getDailyPlan() async throws -> DailyPlanResponse {
        try getDailyPlanResult.get()
    }

    func resetPlan() async throws -> DailyResetResponse {
        resetPlanCallCount += 1
        return try resetPlanResult.get()
    }

    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse {
        fatalError("not implemented")
    }

    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        fatalError("not implemented")
    }

    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        fatalError("not implemented")
    }

    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse {
        fatalError("not implemented")
    }

    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse {
        fatalError("not implemented")
    }

    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse {
        fatalError("not implemented")
    }
}
