import Foundation
import QRIZNetwork
import QRIZUtils

@MainActor
final class MockExamScheduleRepository: ExamScheduleRepository {
    var currentExamStateResult: Result<CachedExamValue, Error> = .success(.unregistered)
    private(set) var currentExamStateCallCount = 0
    private(set) var appliedWriteResults: [ExamDetail] = []
    private(set) var clearCacheCallCount = 0

    func currentExamState() async throws -> CachedExamValue {
        currentExamStateCallCount += 1
        return try currentExamStateResult.get()
    }

    func applyWriteResult(_ detail: ExamDetail) {
        appliedWriteResults.append(detail)
    }

    func clearCache() {
        clearCacheCallCount += 1
    }
}
