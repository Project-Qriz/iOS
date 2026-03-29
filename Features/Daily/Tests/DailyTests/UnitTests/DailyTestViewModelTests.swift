//
//  DailyTestViewModelTests.swift
//  QRIZ
//

import Testing
import Combine
@testable import Daily
@testable import Network
import QRIZUtils

@MainActor
@Suite struct DailyTestViewModelTests {

    @MainActor
    final class TestHarness {
        let sut: DailyTestViewModel
        let service: MockDailyService
        var received: [DailyTestViewModel.Output] = []
        private let inputSubject = PassthroughSubject<DailyTestViewModel.Input, Never>()
        private var subscriptions = Set<AnyCancellable>()

        init(service: MockDailyService = MockDailyService()) {
            self.service = service
            sut = DailyTestViewModel(day: 1, dailyService: service)
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] output in self?.received.append(output) }
                .store(in: &subscriptions)
        }

        func send(_ input: DailyTestViewModel.Input) {
            inputSubject.send(input)
        }

        func sendViewDidLoad() async {
            send(.viewDidLoad)
            try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func sendViewDidAppear() {
            send(.viewDidAppear)
        }

        func resetReceived() {
            received = []
        }
    }

    // MARK: - fetchData

    @Test func fetchData_success_emitsUpdateTotalPageAndUpdateQuestion() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .updateTotalPage(let total) = $0 { return total == 3 }
            return false
        })
        #expect(harness.received.contains {
            if case .updateQuestion(let q) = $0 { return q.questionNumber == 1 }
            return false
        })
    }

    @Test func fetchData_serverError_emitsFetchFailedIsServerError() async {
        let service = MockDailyService()
        service.getDailyTestListResult = .failure(NetworkError.serverError)
        let harness = TestHarness(service: service)
        await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .fetchFailed(let isServerError) = $0 { return isServerError }
            return false
        })
    }

    @Test func fetchData_genericError_emitsFetchFailedNotServerError() async {
        let service = MockDailyService()
        service.getDailyTestListResult = .failure(URLError(.timedOut))
        let harness = TestHarness(service: service)
        await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .fetchFailed(let isServerError) = $0 { return !isServerError }
            return false
        })
    }

    @Test func fetchData_emptyData_emitsFetchFailed() async {
        let service = MockDailyService()
        service.getDailyTestListResult = .success(DailyTestListResponse(code: 1, msg: "ok", data: []))
        let harness = TestHarness(service: service)
        await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .fetchFailed = $0 { return true }
            return false
        })
    }
}
