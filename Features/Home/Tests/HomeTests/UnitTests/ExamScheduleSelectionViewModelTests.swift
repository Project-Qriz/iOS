import Foundation
import Testing
import Combine
@testable import Home
import Network
import QRIZUtils

@MainActor
@Suite("ExamScheduleSelectionViewModel 테스트", .serialized)
struct ExamScheduleSelectionViewModelTests {

    // MARK: - Test Harness

    @MainActor
    private final class TestHarness {
        let sut: ExamScheduleSelectionViewModel
        private(set) var received: [ExamScheduleSelectionViewModel.Output] = []
        private let inputSubject = PassthroughSubject<ExamScheduleSelectionViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(service: MockExamScheduleService) {
            self.sut = ExamScheduleSelectionViewModel(examScheduleService: service)
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

    @Test("examTapped 실패 → showErrorAlert emit")
    func examTapped_failure_emitsErrorAlert() async throws {
        let service = MockExamScheduleService()
        service.fetchExamListResult = .success(.make(
            registeredApplicationId: nil,
            registeredUserApplyId: nil,
            applications: [.make(applicationId: 3)]
        ))
        service.applyExamScheduleResult = .failure(URLError(.notConnectedToInternet))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.examTapped(3))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(!h.errorMessages.isEmpty)
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
}
