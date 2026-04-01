import Foundation
import Network
import QRIZUtils

// 100ms: fire-and-forget Task{ }가 완료되기에 충분한 대기 시간
let asyncSleepNanoseconds: UInt64 = 100_000_000

// MARK: - Sample Data Factories

extension DailyPlan {
    static func make(
        id: Int = 1,
        dayNumber: String = "Day1",
        completed: Bool = false,
        planDate: String = "2026-04-01",
        plannedSkills: [PlannedSkill] = [.make()],
        reviewDay: Bool = false,
        comprehensiveReviewDay: Bool = false,
        today: Bool = false,
        lastDay: Bool = false
    ) -> DailyPlan {
        DailyPlan(
            id: id,
            dayNumber: dayNumber,
            completed: completed,
            planDate: planDate,
            completionDate: nil,
            plannedSkills: plannedSkills,
            reviewDay: reviewDay,
            comprehensiveReviewDay: comprehensiveReviewDay,
            today: today,
            lastDay: lastDay
        )
    }
}

extension PlannedSkill {
    static func make(id: Int = 1) -> PlannedSkill {
        PlannedSkill(id: id, type: "DDL", keyConcept: "테이블 생성", description: "CREATE TABLE")
    }
}

extension DailyPlanResponse {
    static func make(plans: [DailyPlan] = [.make()]) -> DailyPlanResponse {
        DailyPlanResponse(code: 1, msg: "ok", data: plans)
    }
}

extension DailyResetResponse {
    static func make(msg: String = "초기화 성공") -> DailyResetResponse {
        DailyResetResponse(code: 1, msg: msg)
    }
}

extension AppliedExamsResponse {
    static func make(
        examName: String = "2026년 1회",
        period: String = "2026.01.01~2026.01.10",
        examDate: String = "2026-12-31"
    ) -> AppliedExamsResponse {
        AppliedExamsResponse(
            code: 1,
            msg: "ok",
            data: .init(examName: examName, period: period, examDate: examDate)
        )
    }
}

extension ExamScheduleListResponse {
    static func make(
        registeredApplicationId: Int? = nil,
        registeredUserApplyId: Int? = nil,
        applications: [ExamInfo] = [.make()]
    ) -> ExamScheduleListResponse {
        ExamScheduleListResponse(
            code: 1,
            msg: "ok",
            data: ExamListData(
                registeredApplicationId: registeredApplicationId,
                registeredUserApplyId: registeredUserApplyId,
                applications: applications
            )
        )
    }
}

extension ExamInfo {
    static func make(
        applicationId: Int = 1,
        userApplyId: Int? = nil,
        examName: String = "2026년 1회",
        period: String = "2026.01.01~2026.01.10",
        examDate: String = "2026-12-31",
        releaseDate: String = "2026-12-31"
    ) -> ExamInfo {
        ExamInfo(
            applicationId: applicationId,
            userApplyId: userApplyId,
            examName: examName,
            period: period,
            examDate: examDate,
            releaseDate: releaseDate
        )
    }
}

extension WeeklyRecommendResponse {
    static func make() -> WeeklyRecommendResponse {
        WeeklyRecommendResponse(
            code: 1,
            msg: "ok",
            data: RecommendData(recommendationType: "WEAK", recommendations: [])
        )
    }
}

extension ApplyExamScheduleResponse {
    static func make() -> ApplyExamScheduleResponse {
        ApplyExamScheduleResponse(code: 1, msg: "ok", data: nil)
    }
}

extension UpdateExamScheduleResponse {
    static func make() -> UpdateExamScheduleResponse {
        UpdateExamScheduleResponse(code: 1, msg: "ok", data: nil)
    }
}
