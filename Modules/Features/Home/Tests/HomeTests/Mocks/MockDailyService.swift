import Foundation
import QRIZNetwork
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

    func selectPlan(planType: Int) async throws -> DailyPlanSelectResponse {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }

    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }

    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }

    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }

    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }

    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }

    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse {
        throw NSError(domain: "MockDailyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "not implemented"])
    }
}
