// MistakeNote/Tests/MistakeNoteTests/Mocks/SnapshotServiceStubs.swift

import Foundation
import Network

final class StubMistakeNoteService: MistakeNoteService, @unchecked Sendable {
    func getCompletedDays() async throws -> CompletedDailyDaysResponse { fatalError("stub") }
    func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse { fatalError("stub") }
    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse { fatalError("stub") }
    func getClipDetail(clipId: Int) async throws -> ClipDetailResponse { fatalError("stub") }
}
