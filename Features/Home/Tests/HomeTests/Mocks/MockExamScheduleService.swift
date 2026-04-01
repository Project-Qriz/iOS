import Foundation
import Network
import QRIZUtils

@MainActor
final class MockExamScheduleService: ExamScheduleService {

    var fetchAppliedExamsResult: Result<AppliedExamsResponse, Error> = .success(.make())
    var fetchExamListResult: Result<ExamScheduleListResponse, Error> = .success(.make())
    var applyExamScheduleResult: Result<ApplyExamScheduleResponse, Error> = .success(.make())
    var updateExamScheduleResult: Result<UpdateExamScheduleResponse, Error> = .success(.make())

    private(set) var applyExamScheduleCallCount = 0
    private(set) var updateExamScheduleCallCount = 0
    private(set) var lastApplyId: Int?
    private(set) var lastUpdateUserApplyId: Int?
    private(set) var lastUpdateNewApplyId: Int?

    func fetchAppliedExams() async throws -> AppliedExamsResponse {
        try fetchAppliedExamsResult.get()
    }

    func fetchExamList() async throws -> ExamScheduleListResponse {
        try fetchExamListResult.get()
    }

    func applyExamSchedule(applyId: Int) async throws -> ApplyExamScheduleResponse {
        applyExamScheduleCallCount += 1
        lastApplyId = applyId
        return try applyExamScheduleResult.get()
    }

    func updateExamSchedule(userApplyId: Int, newApplyId: Int) async throws -> UpdateExamScheduleResponse {
        updateExamScheduleCallCount += 1
        lastUpdateUserApplyId = userApplyId
        lastUpdateNewApplyId = newApplyId
        return try updateExamScheduleResult.get()
    }
}
