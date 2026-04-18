import Testing
import Foundation
import Combine
@testable import Daily
@testable import Network
import QRIZUtils

@MainActor
@Suite("DailyTestViewModel 테스트", .serialized)
struct DailyTestViewModelTests {

    @MainActor
    final class TestHarness {
        private let sut: DailyTestViewModel
        let service: MockDailyService
        private(set) var received: [DailyTestViewModel.Output] = []
        private let inputSubject = PassthroughSubject<DailyTestViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(service: MockDailyService) {
            self.service = service
            sut = DailyTestViewModel(day: 1, dailyService: service)
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] output in self?.received.append(output) }
                .store(in: &cancellables)
        }

        func send(_ input: DailyTestViewModel.Input) {
            inputSubject.send(input)
        }

        func sendViewDidLoad() async throws {
            send(.viewDidLoad)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func sendViewDidAppear() {
            send(.viewDidAppear)
        }

        func resetReceived() {
            received.removeAll()
        }
    }

    // MARK: - fetchData

    @Test("viewDidLoad 성공 → updateTotalPage(3) + updateQuestion(Q1) emit")
    func fetchData_success_emitsUpdateTotalPageAndUpdateQuestion() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .updateTotalPage(let total) = $0 { return total == 3 }
            return false
        })
        #expect(harness.received.contains {
            if case .updateQuestion(let q) = $0 { return q.questionNumber == 1 }
            return false
        })
    }

    @Test("viewDidLoad 서버 에러 → fetchFailed(isServerError: true)")
    func fetchData_serverError_emitsFetchFailedIsServerError() async throws {
        let service = MockDailyService()
        service.getDailyTestListResult = .failure(NetworkError.serverError(httpStatus: 500))
        let harness = TestHarness(service: service)
        try await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .fetchFailed(let isServerError) = $0 { return isServerError }
            return false
        })
    }

    @Test("viewDidLoad 일반 에러 → fetchFailed(isServerError: false)")
    func fetchData_genericError_emitsFetchFailedNotServerError() async throws {
        let service = MockDailyService()
        service.getDailyTestListResult = .failure(URLError(.timedOut))
        let harness = TestHarness(service: service)
        try await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .fetchFailed(let isServerError) = $0 { return !isServerError }
            return false
        })
    }

    @Test("viewDidLoad data=[] → fetchFailed(isServerError: false) emit")
    func fetchData_emptyData_emitsFetchFailed() async throws {
        let service = MockDailyService()
        service.getDailyTestListResult = .success(DailyTestListResponse(code: 1, msg: "ok", data: []))
        let harness = TestHarness(service: service)
        try await harness.sendViewDidLoad()
        #expect(harness.received.contains {
            if case .fetchFailed(let isServerError) = $0 { return !isServerError }
            return false
        })
    }

    // MARK: - optionSelectHandler

    @Test("Q1 옵션 첫 탭 → updateOptionState(1, true) + setButtonVisibility(true)")
    func optionTapped_Q1_firstTap_selectsOptionAndShowsButton() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
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

    @Test("Q1 같은 옵션 재탭 → 선택 해제 + setButtonVisibility(false)")
    func optionTapped_Q1_sameTap_deselectsAndHidesButton() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
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

    @Test("Q1 다른 옵션 탭 → 이전 선택 해제 + 새 옵션 선택")
    func optionTapped_Q1_differentTap_switchesSelection() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
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

    @Test("Q2에서 옵션 탭 → setButtonVisibility 미방출")
    func optionTapped_Q2_doesNotEmitSetButtonVisibility() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.optionTapped(optionIdx: 1))
        #expect(!harness.received.contains {
            if case .setButtonVisibility = $0 { return true }
            return false
        })
    }

    // MARK: - handleNextButton / buttonStateHandler

    @Test("마지막 문항 아닐 때 다음 버튼 → updateQuestion(Q2)")
    func nextButton_notLastQuestion_advancesToNextQuestion() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.resetReceived()
        harness.send(.nextButtonClicked)
        #expect(harness.received.contains {
            if case .updateQuestion(let q) = $0 { return q.questionNumber == 2 }
            return false
        })
    }

    @Test("마지막 문항에서 다음 버튼 → popSubmitAlert emit")
    func nextButton_lastQuestion_emitsPopSubmitAlert() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.nextButtonClicked)
        #expect(harness.received.contains {
            if case .popSubmitAlert = $0 { return true }
            return false
        })
    }

    @Test("마지막 문항 진입 → alterButtonText emit")
    func lastQuestion_emitsAlterButtonText() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked)
        harness.resetReceived()
        harness.send(.nextButtonClicked)
        #expect(harness.received.contains {
            if case .alterButtonText = $0 { return true }
            return false
        })
    }

    // MARK: - sendSubmitData

    @Test("제출 성공 → submitSuccess + moveToDailyResult emit")
    func alertSubmit_success_emitsSubmitSuccessAndMoveToDailyResult() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
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

    @Test("제출 실패 → submitFailed emit")
    func alertSubmit_failure_emitsSubmitFailed() async throws {
        let service = MockDailyService()
        service.submitDailyResult = .failure(URLError(.notConnectedToInternet))
        let harness = TestHarness(service: service)
        try await harness.sendViewDidLoad()
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

    @Test("옵션 선택 후 제출 시 올바른 optionId 기록")
    func alertSubmit_recordsCorrectOptionId() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        // Q1 두 번째 옵션 선택: sampleTestList 기준 options[1].id = 12
        harness.send(.optionTapped(optionIdx: 2))
        harness.send(.nextButtonClicked) // Q2
        harness.send(.nextButtonClicked) // Q3
        harness.send(.nextButtonClicked) // popSubmitAlert
        harness.send(.alertSubmitButtonClicked)
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect(harness.service.capturedSubmitData?[0].optionId == 12)
    }

    @Test("얼럿 취소 버튼 → cancelAlert emit")
    func alertCancel_emitsCancelAlert() {
        let harness = TestHarness(service: MockDailyService())
        harness.send(.alertCancelButtonClicked)
        #expect(harness.received.contains {
            if case .cancelAlert = $0 { return true }
            return false
        })
    }

    @Test("취소 버튼 → moveToHomeView emit")
    func cancelButton_emitsMoveToHomeView() {
        let harness = TestHarness(service: MockDailyService())
        harness.send(.cancelButtonClicked)
        #expect(harness.received.contains {
            if case .moveToHomeView = $0 { return true }
            return false
        })
    }

    @Test("취소 버튼 → 타이머 정지 (이후 updateTime 미방출)")
    func cancelButton_stopsTimer() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.sendViewDidAppear() // 타이머 시작
        harness.send(.cancelButtonClicked) // exitTimer() 호출
        harness.resetReceived()
        // 타이머가 살아있다면 1초 후 updateTime이 방출됨
        try? await Task.sleep(nanoseconds: 1_100_000_000)
        #expect(!harness.received.contains {
            if case .updateTime = $0 { return true }
            return false
        })
    }

    // MARK: - Timer

    @Test("마지막 문항 타이머 만료 → 자동 제출 후 submitSuccess + moveToDailyResult")
    func timer_timeout_autoSubmitsWhenLastQuestionExpires() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.send(.nextButtonClicked) // Q1 → Q2
        harness.send(.nextButtonClicked) // Q2 → Q3 (timeLimit = 1)
        harness.sendViewDidAppear()      // 타이머 시작
        harness.resetReceived()
        // timeLimit=1: t=1s → timeRemaining=0 (유지), t=2s → timeRemaining=-1 → 자동 제출
        // 2.5s: 2.1s 대비 400ms 여유를 두어 느린 CI에서의 flake 방지
        try? await Task.sleep(nanoseconds: 2_500_000_000)
        #expect(harness.received.contains {
            if case .submitSuccess = $0 { return true }
            return false
        })
        #expect(harness.received.contains {
            if case .moveToDailyResult = $0 { return true }
            return false
        })
    }

    @Test("문항 이동 시 타이머 경과 시간 기록")
    func timer_recordsTimeSpentOnQuestionAdvance() async throws {
        let harness = TestHarness(service: MockDailyService())
        try await harness.sendViewDidLoad()
        harness.sendViewDidAppear()
        // 타이머 1회 발화(1s) 대기: timeRemaining이 timeLimit(70)보다 1 감소함
        // asyncSleepNanoseconds(100ms)는 타이머 발화 전이므로 1_100_000_000(1.1s) 사용
        try? await Task.sleep(nanoseconds: 1_100_000_000)
        harness.send(.nextButtonClicked) // Q1 → Q2: submitData[0].timeSpent = 70 - 69 = 1
        harness.send(.nextButtonClicked) // Q2 → Q3
        harness.send(.nextButtonClicked) // popSubmitAlert
        harness.send(.alertSubmitButtonClicked)
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        let timeSpent = harness.service.capturedSubmitData?[0].timeSpent ?? 0
        #expect(timeSpent >= 1)
        #expect(timeSpent < 70) // 타이머 만료 없이 문항 이동했음을 확인
    }
}
