import Testing
import Foundation
@testable import QRIZUtils

@MainActor
@Suite("ExamScheduleCacheStore 테스트")
struct ExamScheduleCacheStoreTests {

    private func makeSUT() -> ExamScheduleCacheStoreImpl {
        let defaults = UserDefaults(suiteName: "ExamScheduleCacheStoreTests-\(UUID().uuidString)")!
        return ExamScheduleCacheStoreImpl(defaults: defaults)
    }

    @Test("저장한 적 없으면 nil을 반환한다")
    func load_whenNeverSaved_returnsNil() {
        let sut = makeSUT()

        #expect(sut.load(userId: "user-1") == nil)
    }

    @Test("저장 후 같은 userId로 읽으면 같은 값이 나온다")
    func save_thenLoad_returnsSameValue() {
        let sut = makeSUT()
        let detail = ExamDetail(examDateText: "2026-12-31", examName: "2026년 1회", applyPeriod: "2026.01.01~2026.01.10")
        let state = CachedExamState(value: .registered(detail), fetchedAt: Date(timeIntervalSince1970: 1_700_000_000))

        sut.save(state, userId: "user-1")

        #expect(sut.load(userId: "user-1") == state)
    }

    @Test("다른 userId의 캐시끼리는 서로 영향을 주지 않는다")
    func save_isolatesByUserId() {
        let sut = makeSUT()
        let stateA = CachedExamState(value: .unregistered, fetchedAt: Date(timeIntervalSince1970: 1_700_000_000))
        let detail = ExamDetail(examDateText: "2026-12-31", examName: "2026년 1회", applyPeriod: "2026.01.01~2026.01.10")
        let stateB = CachedExamState(value: .registered(detail), fetchedAt: Date(timeIntervalSince1970: 1_700_000_001))

        sut.save(stateA, userId: "user-A")
        sut.save(stateB, userId: "user-B")

        #expect(sut.load(userId: "user-A") == stateA)
        #expect(sut.load(userId: "user-B") == stateB)
    }

    @Test("clear 후에는 nil을 반환한다")
    func clear_removesStoredValue() {
        let sut = makeSUT()
        let state = CachedExamState(value: .unregistered, fetchedAt: Date())
        sut.save(state, userId: "user-1")

        sut.clear(userId: "user-1")

        #expect(sut.load(userId: "user-1") == nil)
    }
}
