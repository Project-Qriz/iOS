// MistakeNote/Tests/MistakeNoteTests/Mocks/SnapshotServiceStubs.swift

import Foundation
import Network

final class StubMistakeNoteService: MistakeNoteService, @unchecked Sendable {
    func getCompletedDays() async throws -> CompletedDailyDaysResponse {
        try await neverReturns()
    }
    func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse {
        try await neverReturns()
    }
    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse {
        try await neverReturns()
    }
    func getClipDetail(clipId: Int) async throws -> ClipDetailResponse {
        try await neverReturns()
    }
}

func neverReturns<T>() async throws -> T {
    try await withTaskCancellationHandler(
        operation: {
            let _: Void = try await Task.sleep(nanoseconds: .max)
            throw CancellationError()
        },
        onCancel: {}
    )
    throw CancellationError()
}
