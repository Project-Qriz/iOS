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

    var getDailyTestListResult: Result<DailyTestListResponse, Error> = .success(
        DailyTestListResponse(code: 1, msg: "ok", data: MockDailyService.sampleTestList)
    )
    var submitDailyResult: Result<Void, Error> = .success(())
    var capturedSubmitData: [DailySubmitData]?

    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        try getDailyTestListResult.get()
    }

    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        capturedSubmitData = dailySubmitData
        try submitDailyResult.get()
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

    func selectPlan(planType: Int) async throws -> DailyPlanSelectResponse {
        fatalError("not implemented in mock")
    }

    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse {
        fatalError("not implemented in mock")
    }

    static let sampleTestList: [DailyTestInfo] = [
        DailyTestInfo(
            questionId: 1, skillId: 1, category: 1,
            question: "다음 중 엔터티의 특징으로 옳지 않은 것은?",
            description: nil,
            options: [
                .init(id: 11, content: "반드시 속성을 가져야 한다.", contentType: "TEXT"),
                .init(id: 12, content: "유일한 식별자가 있어야 한다.", contentType: "TEXT"),
                .init(id: 13, content: "두 개 이상의 인스턴스가 존재해야 한다.", contentType: "TEXT"),
                .init(id: 14, content: "업무에서 관리해야 하는 정보여야 한다.", contentType: "TEXT"),
            ],
            timeLimit: 70, difficulty: 1
        ),
        DailyTestInfo(
            questionId: 2, skillId: 2, category: 1,
            question: "정규화의 목적으로 가장 적절하지 않은 것은?",
            description: nil,
            options: [
                .init(id: 21, content: "삽입 이상 제거", contentType: "TEXT"),
                .init(id: 22, content: "삭제 이상 제거", contentType: "TEXT"),
                .init(id: 23, content: "갱신 이상 제거", contentType: "TEXT"),
                .init(id: 24, content: "조회 성능 향상", contentType: "TEXT"),
            ],
            timeLimit: 70, difficulty: 1
        ),
        DailyTestInfo(
            questionId: 3, skillId: 3, category: 2,
            question: "다음 SQL 중 DDL에 해당하지 않는 것은?",
            description: nil,
            options: [
                .init(id: 31, content: "CREATE", contentType: "SQL"),
                .init(id: 32, content: "ALTER", contentType: "SQL"),
                .init(id: 33, content: "DROP", contentType: "SQL"),
                .init(id: 34, content: "SELECT", contentType: "SQL"),
            ],
            timeLimit: 1, difficulty: 1
        ),
    ]
}
