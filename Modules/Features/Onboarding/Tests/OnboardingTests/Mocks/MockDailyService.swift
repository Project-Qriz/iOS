import Foundation
import Network
import QRIZUtils
@testable import Onboarding

@MainActor
final class MockDailyService: DailyService {
    var selectPlanResult: Result<DailyPlanSelectResponse, Error> = .success(
        DailyPlanSelectResponse(code: 1, msg: "ok")
    )
    private(set) var capturedPlanType: Int?

    func selectPlan(planType: Int) async throws -> DailyPlanSelectResponse {
        capturedPlanType = planType
        return try selectPlanResult.get()
    }

    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func getDailyPlan() async throws -> DailyPlanResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func resetPlan() async throws -> DailyResetResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
    func getChangeavailablePlans() async throws -> DailyPlanChangeAvailableResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }

    func changePlan(planType: Int) async throws -> DailyPlanChangeResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }

    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse {
        throw NSError(domain: "MockDailyService", code: -1)
    }
}
