import Testing
import Foundation
@testable import QRIZNetwork
import QRIZUtils

@MainActor
@Suite("ExamScheduleRepository 테스트", .serialized)
struct ExamScheduleRepositoryTests {

    private func makeSUT(service: MockExamScheduleService) -> (ExamScheduleRepositoryImpl, ExamScheduleCacheStoreImpl) {
        let defaults = UserDefaults(suiteName: "ExamScheduleRepositoryTests-\(UUID().uuidString)")!
        let cacheStore = ExamScheduleCacheStoreImpl(defaults: defaults)
        let repository = ExamScheduleRepositoryImpl(service: service, cacheStore: cacheStore, userInfo: .shared)
        return (repository, cacheStore)
    }

    init() {
        UserInfoManager.shared.update(name: "tester", userId: "user-1", email: "t@test.com", previewTestStatus: .previewCompleted, provider: nil)
    }

    @Test("캐시가 없으면 fetch 후 저장하고 .registered를 반환한다")
    func currentExamState_whenNoCache_fetchesAndStores() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .success(.make(examDate: "2026-12-31"))
        let (sut, cacheStore) = makeSUT(service: service)

        let value = try await sut.currentExamState()

        guard case .registered(let detail) = value else {
            Issue.record("registered가 아님: \(value)")
            return
        }
        #expect(detail.examDateText == "2026-12-31")
        #expect(service.fetchAppliedExamsCallCount == 1)
        #expect(cacheStore.load(userId: "user-1")?.value == value)
    }

    @Test("캐시가 있으면 서비스를 호출하지 않고 캐시값을 반환한다")
    func currentExamState_whenCached_doesNotCallService() async throws {
        let service = MockExamScheduleService()
        let (sut, cacheStore) = makeSUT(service: service)
        cacheStore.save(CachedExamState(value: .unregistered, fetchedAt: Date()), userId: "user-1")

        let value = try await sut.currentExamState()

        #expect(value == .unregistered)
        #expect(service.fetchAppliedExamsCallCount == 0)
    }

    @Test("'등록된 일정 없음'(serverCode -1) 400 응답은 .unregistered로 캐시된다")
    func currentExamState_onUnregistered400_cachesUnregistered() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: -1, message: "등록된 일정이 없어요", reason: nil, detailCode: nil)
        )
        let (sut, cacheStore) = makeSUT(service: service)

        let value = try await sut.currentExamState()

        #expect(value == .unregistered)
        #expect(cacheStore.load(userId: "user-1")?.value == .unregistered)
    }

    @Test("serverCode는 -1이지만 메시지가 다르면 캐시하지 않고 그대로 던진다")
    func currentExamState_onDashOneWithDifferentMessage_throwsWithoutCaching() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: -1, message: "알 수 없는 오류예요", reason: nil, detailCode: nil)
        )
        let (sut, cacheStore) = makeSUT(service: service)

        await #expect(throws: (any Error).self) {
            _ = try await sut.currentExamState()
        }
        #expect(cacheStore.load(userId: "user-1") == nil)
    }

    @Test("미등록 코드가 아닌 400 응답은 캐시하지 않고 그대로 던진다")
    func currentExamState_onOther400_throwsWithoutCaching() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: 0, message: "요청이 잘못됐어요", reason: nil, detailCode: nil)
        )
        let (sut, cacheStore) = makeSUT(service: service)

        await #expect(throws: (any Error).self) {
            _ = try await sut.currentExamState()
        }
        #expect(cacheStore.load(userId: "user-1") == nil)
    }

    @Test("400이 아닌 에러는 캐시하지 않고 그대로 던진다")
    func currentExamState_onNon400Error_throwsWithoutCaching() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .failure(URLError(.notConnectedToInternet))
        let (sut, cacheStore) = makeSUT(service: service)

        await #expect(throws: (any Error).self) {
            _ = try await sut.currentExamState()
        }
        #expect(cacheStore.load(userId: "user-1") == nil)
    }

    @Test("404 clientError는 캐시하지 않고 그대로 던진다 (400만 특별 취급)")
    func currentExamState_on404Error_throwsWithoutCaching() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .failure(
            NetworkError.clientError(httpStatus: 404, serverCode: 0, message: "not found", reason: nil, detailCode: nil)
        )
        let (sut, cacheStore) = makeSUT(service: service)

        await #expect(throws: (any Error).self) {
            _ = try await sut.currentExamState()
        }
        #expect(cacheStore.load(userId: "user-1") == nil)
    }

    @Test("applyWriteResult는 재조회 없이 캐시를 즉시 덮어쓴다")
    func applyWriteResult_overwritesCacheDirectly() async throws {
        let service = MockExamScheduleService()
        let (sut, cacheStore) = makeSUT(service: service)
        let detail = ExamDetail(examDateText: "2026-11-30", examName: "2026년 2회", applyPeriod: "2026.02.01~2026.02.10")

        sut.applyWriteResult(detail)

        #expect(service.fetchAppliedExamsCallCount == 0)
        #expect(cacheStore.load(userId: "user-1")?.value == .registered(detail))
    }

    @Test("clearCache 후에는 다시 캐시가 없는 상태로 돌아간다")
    func clearCache_removesStoredValue() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .success(.make(examDate: "2026-12-31"))
        let (sut, cacheStore) = makeSUT(service: service)
        _ = try await sut.currentExamState()
        #expect(cacheStore.load(userId: "user-1") != nil)

        sut.clearCache()

        #expect(cacheStore.load(userId: "user-1") == nil)
    }

    @Test("동시에 두 번 호출해도 서비스는 한 번만 호출된다 (in-flight 합류)")
    func currentExamState_concurrentCalls_dedupesInFlightRequest() async throws {
        let service = MockExamScheduleService()
        service.fetchAppliedExamsResult = .success(.make(examDate: "2026-12-31"))
        let (sut, _) = makeSUT(service: service)

        async let first = sut.currentExamState()
        async let second = sut.currentExamState()
        _ = try await (first, second)

        #expect(service.fetchAppliedExamsCallCount == 1)
    }
}
