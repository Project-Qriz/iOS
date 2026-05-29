import Foundation
import Testing
import Combine
@testable import Daily
import QRIZNetwork
import QRIZUtils

@MainActor
@Suite("DailyLearnViewModel 테스트", .serialized)
struct DailyLearnViewModelTests {

    // MARK: - Test Harness

    @MainActor
    private final class TestHarness {
        private let sut: DailyLearnViewModel
        private(set) var received: [DailyLearnViewModel.Output] = []
        private let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(service: DailyService, type: DailyLearnType = .daily) {
            self.sut = DailyLearnViewModel(day: 1, type: type, dailyService: service)
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: DailyLearnViewModel.Input) {
            inputSubject.send(input)
        }

        func sendViewDidLoad() async throws {
            inputSubject.send(.viewDidLoad)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func resetReceived() { received.removeAll() }
    }

    // MARK: - Factories

    private func makeService(
        attemptCount: Int = 0,
        passed: Bool = false,
        retestEligible: Bool = false,
        totalScore: Double = 0,
        available: Bool = true
    ) -> MockDailyService {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(
            DailyDetailAndStatusResponse(
                code: 1,
                msg: "ok",
                data: DailyDetailAndStatusResponse.DataInfo(
                    dayNumber: "1",
                    skills: [],
                    status: DailyDetailAndStatusResponse.DataInfo.StatusInfo(
                        attemptCount: attemptCount,
                        passed: passed,
                        retestEligible: retestEligible,
                        totalScore: totalScore,
                        available: available
                    )
                )
            )
        )
        return service
    }

    private func makeFailingService(_ error: Error) -> MockDailyService {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .failure(error)
        return service
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad 성공 → fetchSuccess + updateContent 순서로 emit")
    func viewDidLoad_success_emitsFetchSuccessAndUpdateContent() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()

        guard h.received.count == 2 else {
            Issue.record("Expected 2 outputs, got \(h.received.count)")
            return
        }
        if case .fetchSuccess = h.received[0] { } else {
            Issue.record("Expected .fetchSuccess first, got \(h.received[0])")
        }
        if case .updateContent = h.received[1] { } else {
            Issue.record("Expected .updateContent second, got \(h.received[1])")
        }
    }

    @Test("viewDidLoad 서버 에러 → fetchFailed(isServerError: true)")
    func viewDidLoad_serverError_emitsFetchFailedServer() async throws {
        let h = TestHarness(service: makeFailingService(NetworkError.serverError(httpStatus: 500)))
        try await h.sendViewDidLoad()

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        guard case .fetchFailed(let isServer) = first else {
            Issue.record("Expected .fetchFailed, got \(first)")
            return
        }
        #expect(isServer == true)
    }

    @Test("viewDidLoad 일반 에러 → fetchFailed(isServerError: false)")
    func viewDidLoad_genericError_emitsFetchFailedGeneric() async throws {
        let h = TestHarness(service: makeFailingService(URLError(.notConnectedToInternet)))
        try await h.sendViewDidLoad()

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        guard case .fetchFailed(let isServer) = first else {
            Issue.record("Expected .fetchFailed, got \(first)")
            return
        }
        #expect(isServer == false)
    }

    // MARK: - testNavigatorButtonClicked

    @Test("testNavigatorButtonClicked — unavailable → 아무것도 emit 안 함")
    func testNavigatorButtonClicked_unavailable_emitsNothing() async throws {
        let h = TestHarness(service: makeService(available: false))
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.testNavigatorButtonClicked)

        #expect(h.received.isEmpty)
    }

    @Test("testNavigatorButtonClicked — zeroAttempt → moveToDailyTest emit")
    func testNavigatorButtonClicked_zeroAttempt_emitsMoveToDailyTest() async throws {
        let h = TestHarness(service: makeService(attemptCount: 0))
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.testNavigatorButtonClicked)

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .moveToDailyTest = first { } else {
            Issue.record("Expected .moveToDailyTest, got \(first)")
        }
    }

    @Test("testNavigatorButtonClicked — retestRequired → showRetestAlert emit")
    func testNavigatorButtonClicked_retestRequired_emitsShowRetestAlert() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1, retestEligible: true))
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.testNavigatorButtonClicked)

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .showRetestAlert = first { } else {
            Issue.record("Expected .showRetestAlert, got \(first)")
        }
    }

    @Test("testNavigatorButtonClicked — passed → moveToDailyTestResult emit")
    func testNavigatorButtonClicked_passed_emitsMoveToDailyTestResult() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1, passed: true))
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.testNavigatorButtonClicked)

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .moveToDailyTestResult = first { } else {
            Issue.record("Expected .moveToDailyTestResult, got \(first)")
        }
    }

    @Test("testNavigatorButtonClicked — failed → moveToDailyTestResult emit")
    func testNavigatorButtonClicked_failed_emitsMoveToDailyTestResult() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1))
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.testNavigatorButtonClicked)

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .moveToDailyTestResult = first { } else {
            Issue.record("Expected .moveToDailyTestResult, got \(first)")
        }
    }

    // MARK: - 동기 이벤트

    @Test("alertMoveClicked → dismissAlert 후 moveToDailyTest 순서로 emit")
    func alertMoveClicked_emitsDismissAlertThenMoveToDailyTest() {
        let h = TestHarness(service: MockDailyService())
        h.send(.alertMoveClicked)

        guard h.received.count == 2 else {
            Issue.record("Expected 2 outputs, got \(h.received.count)")
            return
        }
        if case .dismissAlert = h.received[0] { } else {
            Issue.record("Expected .dismissAlert first, got \(h.received[0])")
        }
        if case .moveToDailyTest = h.received[1] { } else {
            Issue.record("Expected .moveToDailyTest second, got \(h.received[1])")
        }
    }

    @Test("alertCancelClicked → dismissAlert emit")
    func alertCancelClicked_emitsDismissAlert() {
        let h = TestHarness(service: MockDailyService())
        h.send(.alertCancelClicked)

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .dismissAlert = first { } else {
            Issue.record("Expected .dismissAlert, got \(first)")
        }
    }

    @Test("backButtonClicked → moveToHome emit")
    func backButtonClicked_emitsMoveToHome() {
        let h = TestHarness(service: MockDailyService())
        h.send(.backButtonClicked)

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .moveToHome = first { } else {
            Issue.record("Expected .moveToHome, got \(first)")
        }
    }

    @Test("toConceptClicked → moveToConcept emit")
    func toConceptClicked_emitsMoveToConcept() {
        let h = TestHarness(service: MockDailyService())
        h.send(.toConceptClicked(conceptIdx: 1))

        guard h.received.count == 1, let first = h.received.first else {
            Issue.record("Expected 1 output, got \(h.received.count)")
            return
        }
        if case .moveToConcept = first { } else {
            Issue.record("Expected .moveToConcept, got \(first)")
        }
    }

    // MARK: - state 결정 로직

    @Test("available=false → state=.unavailable")
    func stateDecision_unavailable() async throws {
        let h = TestHarness(service: makeService(available: false))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(state == .unavailable)
    }

    @Test("passed=true → state=.passed")
    func stateDecision_passed() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1, passed: true))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(state == .passed)
    }

    @Test("retestEligible=true → state=.retestRequired")
    func stateDecision_retestRequired() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1, retestEligible: true))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(state == .retestRequired)
    }

    @Test("attemptCount=0, available=true → state=.zeroAttempt")
    func stateDecision_zeroAttempt() async throws {
        let h = TestHarness(service: makeService(attemptCount: 0))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(state == .zeroAttempt)
    }

    @Test("attemptCount>0, passed=false, retestEligible=false → state=.failed")
    func stateDecision_failed() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(state == .failed)
    }

    // MARK: - score 결정 로직

    @Test("attemptCount=0 → score=nil")
    func scoreDecision_zeroAttempt_scoreIsNil() async throws {
        let h = TestHarness(service: makeService(attemptCount: 0, totalScore: 80))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(_, _, let score) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(score == nil)
    }

    @Test("attemptCount>0 → score=totalScore")
    func scoreDecision_withAttempt_scoreEqualsTotalScore() async throws {
        let h = TestHarness(service: makeService(attemptCount: 1, passed: true, totalScore: 85.5))
        try await h.sendViewDidLoad()

        guard let first = h.received.first, case .fetchSuccess(_, _, let score) = first else {
            Issue.record("Expected .fetchSuccess")
            return
        }
        #expect(score == 85.5)
    }
}
