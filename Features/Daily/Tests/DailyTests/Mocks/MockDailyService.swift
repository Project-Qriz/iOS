import Foundation
@testable import Network
import QRIZUtils

@MainActor
final class MockDailyService: DailyService {

    var getDailyDetailAndStatusResult: Result<DailyDetailAndStatusResponse, Error> = .success(
        DailyDetailAndStatusResponse(
            code: 1,
            msg: "ok",
            data: DailyDetailAndStatusResponse.DataInfo(
                dayNumber: "1",
                skills: [],
                status: DailyDetailAndStatusResponse.DataInfo.StatusInfo(
                    attemptCount: 0,
                    passed: false,
                    retestEligible: false,
                    totalScore: 0,
                    available: true
                )
            )
        )
    )

    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse {
        try getDailyDetailAndStatusResult.get()
    }

    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        fatalError("not implemented in mock")
    }

    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        fatalError("not implemented in mock")
    }

    var getDailyTestResultResult: Result<DailyResultResponse, Error> = .success(
        DailyResultResponse(
            code: 1,
            msg: "ok",
            data: DailyResultResponse.DataInfo(
                dayNumber: "1",
                passed: false,
                reviewDay: false,
                comprehensiveReviewDay: false,
                items: [],
                subjectResultsList: [],
                totalScore: 0
            )
        )
    )

    var getDailyWeeklyScoreResult: Result<DailyWeeklyScoreResponse, Error> = .success(
        DailyWeeklyScoreResponse(
            code: 1,
            msg: "ok",
            data: DailyWeeklyScoreResponse.DataInfo(subjects: [], totalScore: 0)
        )
    )

    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse {
        try getDailyTestResultResult.get()
    }

    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse {
        try getDailyWeeklyScoreResult.get()
    }

    func getDailyPlan() async throws -> DailyPlanResponse {
        fatalError("not implemented in mock")
    }

    func resetPlan() async throws -> DailyResetResponse {
        fatalError("not implemented in mock")
    }

    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse {
        fatalError("not implemented in mock")
    }
}
