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

    // MARK: - optionSelectHandler

    @Test func optionTapped_Q1_firstTap_selectsOptionAndShowsButton() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.resetReceived()
        harness.send(.optionTapped(optionIdx: 1))
        #expect(harness.received.contains {
            if case .updateOptionState(let idx, let selected) = $0 { return idx == 1 && selected }
            return false
        })
        #expect(harness.received.contains {
            if case .setButtonVisibility(let visible) = $0 { return visible }
            return false
        })
    }

    @Test func optionTapped_Q1_sameTap_deselectsAndHidesButton() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.optionTapped(optionIdx: 1))
        harness.resetReceived()
        harness.send(.optionTapped(optionIdx: 1))
        #expect(harness.received.contains {
            if case .updateOptionState(let idx, let selected) = $0 { return idx == 1 && !selected }
            return false
        })
        #expect(harness.received.contains {
            if case .setButtonVisibility(let visible) = $0 { return !visible }
            return false
        })
    }

    @Test func optionTapped_Q1_differentTap_switchesSelection() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.optionTapped(optionIdx: 1))
        harness.resetReceived()
        harness.send(.optionTapped(optionIdx: 2))
        #expect(harness.received.contains {
            if case .updateOptionState(let idx, let selected) = $0 { return idx == 1 && !selected }
            return false
        })
        #expect(harness.received.contains {
            if case .updateOptionState(let idx, let selected) = $0 { return idx == 2 && selected }
            return false
        })
    }

    @Test func optionTapped_Q2_doesNotEmitSetButtonVisibility() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.optionTapped(optionIdx: 1))
        #expect(!harness.received.contains {
            if case .setButtonVisibility = $0 { return true }
            return false
        })
    }

    // MARK: - handleNextButton / buttonStateHandler

    @Test func nextButton_notLastQuestion_advancesToNextQuestion() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.resetReceived()
        harness.send(.nextButtonClicked)
        #expect(harness.received.contains {
            if case .updateQuestion(let q) = $0 { return q.questionNumber == 2 }
            return false
        })
    }

    @Test func nextButton_lastQuestion_emitsPopSubmitAlert() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.nextButtonClicked)
        #expect(harness.received.contains {
            if case .popSubmitAlert = $0 { return true }
            return false
        })
    }

    @Test func lastQuestion_emitsAlterButtonText() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.nextButtonClicked)
        #expect(harness.received.contains {
            if case .alterButtonText = $0 { return true }
            return false
        })
    }

    // MARK: - sendSubmitData

    @Test func alertSubmit_success_emitsSubmitSuccessAndMoveToDailyResult() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.send(.nextButtonClicked)
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.alertSubmitButtonClicked)
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect(harness.received.contains {
            if case .submitSuccess = $0 { return true }
            return false
        })
        #expect(harness.received.contains {
            if case .moveToDailyResult = $0 { return true }
            return false
        })
    }

    @Test func alertSubmit_failure_emitsSubmitFailed() async {
        let service = MockDailyService()
        service.submitDailyResult = .failure(URLError(.notConnectedToInternet))
        let harness = TestHarness(service: service)
        await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.send(.nextButtonClicked)
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.alertSubmitButtonClicked)
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect(harness.received.contains {
            if case .submitFailed = $0 { return true }
            return false
        })
    }

    @Test func alertCancel_emitsCancelAlert() {
        let harness = TestHarness()
        harness.send(.alertCancelButtonClicked)
        #expect(harness.received.contains {
            if case .cancelAlert = $0 { return true }
            return false
        })
    }

    @Test func cancelButton_emitsMoveToHomeView() {
        let harness = TestHarness()
        harness.send(.cancelButtonClicked)
        #expect(harness.received.contains {
            if case .moveToHomeView = $0 { return true }
            return false
        })
    }

    // MARK: - Timer

    @Test func timer_timeout_autoSubmitsWhenLastQuestionExpires() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked) // Q1 → Q2
        harness.send(.nextButtonClicked) // Q2 → Q3 (timeLimit = 1)
        harness.sendViewDidAppear()      // 타이머 시작
        harness.resetReceived()
        // timeLimit=1: t=1s → timeRemaining=0 (유지), t=2s → timeRemaining=-1 → 자동 제출
        try? await Task.sleep(nanoseconds: 2_100_000_000)
        #expect(harness.received.contains {
            if case .submitSuccess = $0 { return true }
            return false
        })
        #expect(harness.received.contains {
            if case .moveToDailyResult = $0 { return true }
            return false
        })
    }

    @Test func timer_recordsTimeSpentOnQuestionAdvance() async {
        let harness = TestHarness()
        await harness.sendViewDidLoad()
        harness.sendViewDidAppear()
        // 타이머 1회 발화(1s) 대기: timeRemaining이 timeLimit(70)보다 1 감소함
        // asyncSleepNanoseconds(100ms)는 타이머 발화 전이므로 1_100_000_000(1.1s) 사용
        try? await Task.sleep(nanoseconds: 1_100_000_000)
        harness.send(.nextButtonClicked) // Q1 → Q2: submitData[0].timeSpent = 70 - 69 = 1
        harness.send(.nextButtonClicked) // Q2 → Q3
        harness.send(.nextButtonClicked) // popSubmitAlert
        harness.send(.alertSubmitButtonClicked)
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect((harness.service.capturedSubmitData?[0].timeSpent ?? 0) > 0)
    }
}
