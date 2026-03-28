import Foundation
import Testing
import Combine
@testable import Daily
import Network
import QRIZUtils

@MainActor
@Suite("DailyLearnViewModel 테스트", .serialized)
struct DailyLearnViewModelTests {

    // MARK: - SUT Factory

    private func makeSUT(
        day: Int = 1,
        type: DailyLearnType = .daily,
        service: MockDailyService? = nil
    ) -> DailyLearnViewModel {
        DailyLearnViewModel(
            day: day,
            type: type,
            dailyService: service ?? MockDailyService()
        )
    }

    private func makeResponse(
        attemptCount: Int = 0,
        passed: Bool = false,
        retestEligible: Bool = false,
        totalScore: Double = 0,
        available: Bool = true,
        skills: [DailyDetailAndStatusResponse.DataInfo.SkillInfo] = []
    ) -> DailyDetailAndStatusResponse {
        DailyDetailAndStatusResponse(
            code: 1,
            msg: "ok",
            data: DailyDetailAndStatusResponse.DataInfo(
                dayNumber: "1",
                skills: skills,
                status: DailyDetailAndStatusResponse.DataInfo.StatusInfo(
                    attemptCount: attemptCount,
                    passed: passed,
                    retestEligible: retestEligible,
                    totalScore: totalScore,
                    available: available
                )
            )
        )
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad 성공 → fetchSuccess + updateContent 순서로 emit")
    func viewDidLoad_success_emitsFetchSuccessAndUpdateContent() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse())
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 2)
        guard case .fetchSuccess = received[0] else {
            Issue.record("Expected .fetchSuccess first, got \(received[0])")
            return
        }
        guard case .updateContent = received[1] else {
            Issue.record("Expected .updateContent second, got \(received[1])")
            return
        }
    }

    @Test("viewDidLoad 서버 에러 → fetchFailed(isServerError: true)")
    func viewDidLoad_serverError_emitsFetchFailedServer() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .failure(NetworkError.serverError)
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .fetchFailed(let isServer) = first, isServer == true else {
            Issue.record("Expected .fetchFailed(isServerError: true), got \(first)")
            return
        }
    }

    @Test("viewDidLoad 일반 에러 → fetchFailed(isServerError: false)")
    func viewDidLoad_genericError_emitsFetchFailedGeneric() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .fetchFailed(let isServer) = first, isServer == false else {
            Issue.record("Expected .fetchFailed(isServerError: false), got \(first)")
            return
        }
    }

    // MARK: - testNavigatorButtonClicked

    @Test("testNavigatorButtonClicked — unavailable → 아무것도 emit 안 함")
    func testNavigatorButtonClicked_unavailable_emitsNothing() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(available: false))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        received.removeAll()

        inputSubject.send(.testNavigatorButtonClicked)

        #expect(received.isEmpty)
    }

    @Test("testNavigatorButtonClicked — zeroAttempt → moveToDailyTest emit")
    func testNavigatorButtonClicked_zeroAttempt_emitsMoveToDailyTest() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 0, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        received.removeAll()

        inputSubject.send(.testNavigatorButtonClicked)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .moveToDailyTest = first else {
            Issue.record("Expected .moveToDailyTest, got \(first)")
            return
        }
    }

    @Test("testNavigatorButtonClicked — retestRequired → showRetestAlert emit")
    func testNavigatorButtonClicked_retestRequired_emitsShowRetestAlert() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, retestEligible: true, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        received.removeAll()

        inputSubject.send(.testNavigatorButtonClicked)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .showRetestAlert = first else {
            Issue.record("Expected .showRetestAlert, got \(first)")
            return
        }
    }

    @Test("testNavigatorButtonClicked — passed → moveToDailyTestResult emit")
    func testNavigatorButtonClicked_passed_emitsMoveToDailyTestResult() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, passed: true, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        received.removeAll()

        inputSubject.send(.testNavigatorButtonClicked)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .moveToDailyTestResult = first else {
            Issue.record("Expected .moveToDailyTestResult, got \(first)")
            return
        }
    }

    @Test("testNavigatorButtonClicked — failed → moveToDailyTestResult emit")
    func testNavigatorButtonClicked_failed_emitsMoveToDailyTestResult() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, passed: false, retestEligible: false, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        received.removeAll()

        inputSubject.send(.testNavigatorButtonClicked)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .moveToDailyTestResult = first else {
            Issue.record("Expected .moveToDailyTestResult, got \(first)")
            return
        }
    }

    // MARK: - 동기 이벤트

    @Test("alertMoveClicked → dismissAlert 후 moveToDailyTest 순서로 emit")
    func alertMoveClicked_emitsDismissAlertThenMoveToDailyTest() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.alertMoveClicked)

        #expect(received.count == 2)
        guard case .dismissAlert = received[0] else {
            Issue.record("Expected .dismissAlert first, got \(received[0])")
            return
        }
        guard case .moveToDailyTest = received[1] else {
            Issue.record("Expected .moveToDailyTest second, got \(received[1])")
            return
        }
    }

    @Test("alertCancelClicked → dismissAlert emit")
    func alertCancelClicked_emitsDismissAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.alertCancelClicked)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .dismissAlert = first else {
            Issue.record("Expected .dismissAlert, got \(first)")
            return
        }
    }

    @Test("backButtonClicked → moveToHome emit")
    func backButtonClicked_emitsMoveToHome() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.backButtonClicked)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .moveToHome = first else {
            Issue.record("Expected .moveToHome, got \(first)")
            return
        }
    }

    @Test("toConceptClicked → moveToConcept emit")
    func toConceptClicked_emitsMoveToConcept() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.toConceptClicked(conceptIdx: 1))

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count)")
            return
        }
        guard case .moveToConcept = first else {
            Issue.record("Expected .moveToConcept, got \(first)")
            return
        }
    }

    // MARK: - state 결정 로직

    @Test("available=false → state=.unavailable")
    func stateDecision_unavailable() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(available: false))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(state == .unavailable)
    }

    @Test("passed=true → state=.passed")
    func stateDecision_passed() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, passed: true, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(state == .passed)
    }

    @Test("retestEligible=true → state=.retestRequired")
    func stateDecision_retestRequired() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, retestEligible: true, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(state == .retestRequired)
    }

    @Test("attemptCount=0, available=true → state=.zeroAttempt")
    func stateDecision_zeroAttempt() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 0, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(state == .zeroAttempt)
    }

    @Test("attemptCount>0, passed=false, retestEligible=false → state=.failed")
    func stateDecision_failed() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, passed: false, retestEligible: false, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(let state, _, _) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(state == .failed)
    }

    // MARK: - score 결정 로직

    @Test("attemptCount=0 → score=nil")
    func scoreDecision_zeroAttempt_scoreIsNil() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 0, totalScore: 80, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(_, _, let score) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(score == nil)
    }

    @Test("attemptCount>0 → score=totalScore")
    func scoreDecision_withAttempt_scoreEqualsTotalScore() async throws {
        let service = MockDailyService()
        service.getDailyDetailAndStatusResult = .success(makeResponse(attemptCount: 1, passed: true, totalScore: 85.5, available: true))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<DailyLearnViewModel.Input, Never>()
        var received: [DailyLearnViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard let first = received.first, case .fetchSuccess(_, _, let score) = first else {
            Issue.record("Expected .fetchSuccess"); return
        }
        #expect(score == 85.5)
    }
}
