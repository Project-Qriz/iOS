import Foundation
import Testing
import Combine
@testable import Home
import QRIZNetwork
import QRIZUtils

@MainActor
@Suite("ExamScheduleSelectionViewModel 테스트", .serialized)
struct ExamScheduleSelectionViewModelTests {

    // MARK: - Test Harness

    @MainActor
    private final class MockExamSelectionDelegate: ExamSelectionDelegate {
        private(set) var didUpdateExamScheduleCallCount = 0

        func didUpdateExamSchedule() {
            didUpdateExamScheduleCallCount += 1
        }
    }

    @MainActor
    private final class TestHarness {
        let sut: ExamScheduleSelectionViewModel
        let mockDelegate = MockExamSelectionDelegate()
        let repository: MockExamScheduleRepository
        private(set) var received: [ExamScheduleSelectionViewModel.Output] = []
        private let inputSubject = PassthroughSubject<ExamScheduleSelectionViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(service: MockExamScheduleService, repository: MockExamScheduleRepository = MockExamScheduleRepository()) {
            self.repository = repository
            self.sut = ExamScheduleSelectionViewModel(examScheduleService: service, examScheduleRepository: repository)
            sut.delegate = mockDelegate
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: ExamScheduleSelectionViewModel.Input) {
            inputSubject.send(input)
        }

        func sendViewDidLoad() async throws {
            inputSubject.send(.viewDidLoad)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func resetReceived() { received.removeAll() }

        var loadedRows: [[ExamRowState]] {
            received.compactMap {
                if case .loadExamList(let rows) = $0 { return rows }
                return nil
            }
        }

        var errorMessages: [String] {
            received.compactMap {
                if case .showErrorAlert(let msg) = $0 { return msg }
                return nil
            }
        }
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad 성공 → loadExamList emit")
    func viewDidLoad_success_emitsLoadExamList() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            applications: [.make(applicationId: 1), .make(applicationId: 2)]
        ))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()

        #expect(h.loadedRows.count == 1)
        #expect(h.loadedRows[0].count == 2)
    }

    @Test("viewDidLoad 실패 → showErrorAlert emit")
    func viewDidLoad_failure_emitsErrorAlert() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .failure(URLError(.notConnectedToInternet))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()

        #expect(!h.errorMessages.isEmpty)
    }

    // MARK: - examTapped (신규 등록)

    @Test("examTapped — 미등록 상태 → applyExamSchedule 호출 후 loadExamList emit")
    func examTapped_noExistingRegistration_callsApply() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: nil,
            registeredUserApplyId: nil,
            applications: [.make(applicationId: 10)]
        ))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(10))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(service.applyExamScheduleCallCount == 1)
        #expect(service.lastApplyId == 10)
        #expect(!h.loadedRows.isEmpty)
    }

    @Test("examTapped — 이미 등록된 id → 아무것도 호출 안 함")
    func examTapped_sameAsRegistered_doesNothing() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: 5,
            registeredUserApplyId: 1,
            applications: [.make(applicationId: 5)]
        ))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(5))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(service.applyExamScheduleCallCount == 0)
        #expect(service.updateExamScheduleCallCount == 0)
        #expect(h.received.isEmpty)
    }

    @Test("examTapped — 기등록 상태에서 다른 id → updateExamSchedule 호출")
    func examTapped_withExistingRegistration_callsUpdate() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: 1,
            registeredUserApplyId: 99,
            applications: [
                .make(applicationId: 1),
                .make(applicationId: 2)
            ]
        ))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(2))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(service.updateExamScheduleCallCount == 1)
        #expect(service.lastUpdateUserApplyId == 99)
        #expect(service.lastUpdateNewApplyId == 2)
    }

    @Test("examTapped — 신규 등록 성공 → delegate didUpdateExamSchedule 호출")
    func examTapped_success_callsDelegate() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: nil,
            registeredUserApplyId: nil,
            applications: [.make(applicationId: 10)]
        ))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()

        h.send(.examTapped(10))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.mockDelegate.didUpdateExamScheduleCallCount == 1)
    }

    @Test("examTapped 명확한 실패(4xx) → 롤백 + showErrorAlert emit")
    func examTapped_clientError_rollsBackAndEmitsErrorAlert() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: nil,
            registeredUserApplyId: nil,
            applications: [.make(applicationId: 3)]
        ))
        service.applyExamScheduleResult = .failure(
            NetworkError.clientError(httpStatus: 409, serverCode: 0, message: "이미 접수가 마감됐어요.", reason: nil, detailCode: nil)
        )
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(3))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(!h.errorMessages.isEmpty)
        // 롤백: 마지막으로 emit된 rows에서 3번은 선택되지 않은 채여야 한다
        let lastRows = h.loadedRows.last
        #expect(lastRows?.first(where: { $0.id == 3 })?.isSelected == false)
    }

    @Test("examTapped — apply 성공 후 동일 id 재탭 → no-op")
    func examTapped_afterApplySuccess_sameId_doesNothing() async throws {
        let service = MockExamScheduleService()
        // 첫 번째 fetchExamList: 미등록 상태
        // 두 번째 fetchExamList(apply 후 재조회): id 10이 등록된 상태
        service.fetchExamListResultQueue = [
            .success(.make(registeredApplicationId: nil, registeredUserApplyId: nil, applications: [.make(applicationId: 10)])),
            .success(.make(registeredApplicationId: 10, registeredUserApplyId: 99, applications: [.make(applicationId: 10)]))
        ]
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()

        h.send(.examTapped(10))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect(service.applyExamScheduleCallCount == 1)

        // apply 성공 후 registeredApplicationId == 10이므로 재탭 시 no-op
        h.send(.examTapped(10))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect(service.applyExamScheduleCallCount == 1)
        #expect(service.updateExamScheduleCallCount == 0)
    }

    // MARK: - 낙관적 반영 / reconciling

    @Test("examTapped — 탭 직후 네트워크 응답 전에 낙관적으로 선택 상태를 먼저 반영한다")
    func examTapped_beforeNetworkResolves_emitsOptimisticSelection() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: nil,
            registeredUserApplyId: nil,
            applications: [.make(applicationId: 10)]
        ))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(10))
        // MockExamScheduleService는 인위적 지연이 없고 Combine은 순서대로 전달되므로
        // loadedRows.first는 항상 낙관적 emit이다 (재조회 결과는 그 뒤에만 쌓인다) —
        // 표준 asyncSleepNanoseconds로도 레이스 없이 검증 가능하다
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        let optimisticRows = h.loadedRows.first
        #expect(optimisticRows?.first(where: { $0.id == 10 })?.isSelected == true)
    }

    @Test("examTapped — 타임아웃이면 롤백하지 않고 목록을 재조회해 서버 상태로 동기화한다")
    func examTapped_timeout_reconcilesInsteadOfRollingBack() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResultQueue = [
            .success(.make(registeredApplicationId: nil, registeredUserApplyId: nil, applications: [.make(applicationId: 7)])),
            .success(.make(registeredApplicationId: 7, registeredUserApplyId: 42, applications: [.make(applicationId: 7)]))
        ]
        service.applyExamScheduleResult = .failure(URLError(.timedOut))
        let repository = MockExamScheduleRepository()
        let h = TestHarness(service: service, repository: repository)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(7))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        // 목록 재조회가 한 번 더 일어났다 (최초 viewDidLoad 1회 + reconcile 1회)
        #expect(service.fetchExamListCallCount == 2)
        // 재조회 결과 서버가 실제로 등록했음을 확인했으므로 캐시에 직접 반영된다
        #expect(repository.appliedWriteResults.count == 1)
        // 캐시에 쓰인 내용이 재조회된 ExamInfo와 정확히 일치해야 한다 (필드 매핑 검증)
        #expect(repository.appliedWriteResults.first?.examName == "2026년 1회")
        #expect(repository.appliedWriteResults.first?.applyPeriod == "2026.01.01~2026.01.10")
        #expect(repository.appliedWriteResults.first?.examDateText == "2026-12-31")
        // 타임아웃을 실패로 보고하지 않는다 (서버 상태 확인으로 끝남)
        #expect(h.errorMessages.isEmpty)
    }
}
