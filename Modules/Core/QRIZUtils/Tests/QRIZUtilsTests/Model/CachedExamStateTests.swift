import Testing
import Foundation
@testable import QRIZUtils

@Suite("CachedExamState 테스트")
struct CachedExamStateTests {

    @Test("registered 값이 JSON 왕복 후에도 동일하다")
    func registeredValue_roundTripsThroughJSON() throws {
        let detail = ExamDetail(examDateText: "2026-12-31", examName: "2026년 1회", applyPeriod: "2026.01.01~2026.01.10")
        let state = CachedExamState(value: .registered(detail), fetchedAt: Date(timeIntervalSince1970: 0))

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(state)
        let decoded = try decoder.decode(CachedExamState.self, from: data)

        #expect(decoded == state)
    }

    @Test("unregistered 값이 JSON 왕복 후에도 동일하다")
    func unregisteredValue_roundTripsThroughJSON() throws {
        let state = CachedExamState(value: .unregistered, fetchedAt: Date(timeIntervalSince1970: 0))

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(state)
        let decoded = try decoder.decode(CachedExamState.self, from: data)

        #expect(decoded == state)
    }
}
