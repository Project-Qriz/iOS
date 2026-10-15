import Foundation
import QRIZNetwork
import QRIZUtils

@MainActor
final class MockExamScheduleService: ExamScheduleService {

    var fetchAppliedExamsResult: Result<AppliedExamsResponse, Error> = .success(.make())
    var fetchExamListResult: Result<ExamScheduleListResponse, Error> = .success(.make())
    var fetchExamListResultQueue: [Result<ExamScheduleListResponse, Error>] = []
    var applyExamScheduleResult: Result<ApplyExamScheduleResponse, Error> = .success(.make())
    var updateExamScheduleResult: Result<UpdateExamScheduleResponse, Error> = .success(.make())

    private(set) var fetchAppliedExamsCallCount = 0
    private(set) var fetchExamListCallCount = 0
    private(set) var applyExamScheduleCallCount = 0
    private(set) var updateExamScheduleCallCount = 0
    private(set) var lastApplyId: Int?
    private(set) var lastUpdateUserApplyId: Int?
    private(set) var lastUpdateNewApplyId: Int?

    /// true면 `resumeFetchAppliedExams()` 전까지 응답을 보류
    var holdsFetchAppliedExams = false
    private var heldFetchAppliedExams: CheckedContinuation<Void, Never>?

    func fetchAppliedExams() async throws -> AppliedExamsResponse {
        fetchAppliedExamsCallCount += 1
        if holdsFetchAppliedExams {
            await withCheckedContinuation { heldFetchAppliedExams = $0 }
        }
        return try fetchAppliedExamsResult.get()
    }

    func resumeFetchAppliedExams() {
        heldFetchAppliedExams?.resume()
        heldFetchAppliedExams = nil
    }

    func fetchExamList() async throws -> ExamScheduleListResponse {
        fetchExamListCallCount += 1
        if !fetchExamListResultQueue.isEmpty {
            return try fetchExamListResultQueue.removeFirst().get()
        }
        return try fetchExamListResult.get()
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
