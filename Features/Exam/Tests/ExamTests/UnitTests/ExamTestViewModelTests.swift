//
//  ExamTestViewModelTests.swift
//  QRIZ
//

import Foundation
import Testing
import Combine
@testable import Exam
import Network
import QRIZUtils

@MainActor
@Suite("ExamTestViewModel 테스트", .serialized)
struct ExamTestViewModelTests {

    // MARK: - TestHarness

    @MainActor
    private final class TestHarness {
        private let sut: ExamTestViewModel
        private let inputSubject = PassthroughSubject<ExamTestViewModel.Input, Never>()
        private(set) var received: [ExamTestViewModel.Output] = []
        private var cancellables = Set<AnyCancellable>()

        init(service: any ExamService, examId: Int = 1) {
            sut = ExamTestViewModel(examId: examId, examService: service)
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: ExamTestViewModel.Input) { inputSubject.send(input) }
        func resetReceived() { received.removeAll() }

        func sendViewDidLoad() async throws {
            inputSubject.send(.viewDidLoad)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func sendAlertSubmit() async throws {
            inputSubject.send(.didTapAlertSubmit)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        // MARK: - Output Helpers

        var totalPageOutputs: [Int] {
            received.compactMap { if case .updateTotalPage(let n) = $0 { return n }; return nil }
        }

        var questionOutputs: [QuestionData] {
            received.compactMap { if case .updateQuestion(let q) = $0 { return q }; return nil }
        }

        var optionStateOutputs: [(optionIdx: Int, isSelected: Bool)] {
            received.compactMap {
                if case .updateOptionState(let idx, let sel) = $0 { return (idx, sel) }
                return nil
            }
        }

        var prevButtonOutputs: [Bool] {
            received.compactMap { if case .updatePrevButton(let v) = $0 { return v }; return nil }
        }

        var nextButtonOutputs: [(isVisible: Bool, isTextSubmit: Bool)] {
            received.compactMap {
                if case .updateNextButton(let v, let t) = $0 { return (v, t) }
                return nil
            }
        }
    }

    // MARK: - Factories

    private func makeService(
        questionCount: Int = 2,
        totalTimeLimit: Int = 100
    ) -> MockExamService {
        let service = MockExamService()
        service.getExamQuestionResult = .success(
            MockExamService.makeExamQuestion(questionCount: questionCount, totalTimeLimit: totalTimeLimit)
        )
        return service
    }

    private func makeEmptyQuestionService() -> MockExamService {
        let service = MockExamService()
        service.getExamQuestionResult = .success(MockExamService.makeExamQuestion(questionCount: 0))
        return service
    }

    private func makeFailingService(_ error: Error) -> MockExamService {
        let service = MockExamService()
        service.getExamQuestionResult = .failure(error)
        return service
    }

    // MARK: - viewDidLoad 성공

    @Test("viewDidLoad 성공 → updateTotalPage에 문제 수 전달")
    func viewDidLoad_success_emitsUpdateTotalPage() async throws {
        let h = TestHarness(service: makeService(questionCount: 3))
        try await h.sendViewDidLoad()

        #expect(h.totalPageOutputs.last == 3)
    }

    @Test("viewDidLoad 성공 → 첫 번째 문제 emit")
    func viewDidLoad_success_emitsFirstQuestion() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()

        guard let question = h.questionOutputs.last else {
            Issue.record("updateQuestion output이 발행되지 않음")
            return
        }
        #expect(question.questionNumber == 1)
    }

    @Test("viewDidLoad 성공 → 첫 페이지 prevButton hidden")
    func viewDidLoad_success_firstPage_prevButtonHidden() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()

        #expect(h.prevButtonOutputs.last == false)
    }

    @Test("viewDidLoad 성공 → 첫 페이지 선택 없음 nextButton hidden")
    func viewDidLoad_success_firstPage_noSelection_nextButtonHidden() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()

        guard let last = h.nextButtonOutputs.last else {
            Issue.record("updateNextButton output이 발행되지 않음")
            return
        }
        #expect(last.isVisible == false)
        #expect(last.isTextSubmit == false)
    }

    // MARK: - viewDidLoad 에러

    @Test("viewDidLoad 빈 문제 리스트 → fetchFailed(isServerError: false)")
    func viewDidLoad_emptyQuestions_emitsFetchFailed() async throws {
        let h = TestHarness(service: makeEmptyQuestionService())
        try await h.sendViewDidLoad()

        guard case .fetchFailed(let isServerError) = h.received.first else {
            Issue.record("fetchFailed output이 발행되지 않음")
            return
        }
        #expect(isServerError == false)
    }

    @Test("viewDidLoad 서버 에러 → fetchFailed(isServerError: true)")
    func viewDidLoad_serverError_emitsFetchFailed_isServerErrorTrue() async throws {
        let h = TestHarness(service: makeFailingService(NetworkError.serverError))
        try await h.sendViewDidLoad()

        guard case .fetchFailed(let isServerError) = h.received.first else {
            Issue.record("fetchFailed output이 발행되지 않음")
            return
        }
        #expect(isServerError == true)
    }

    @Test("viewDidLoad 일반 에러 → fetchFailed(isServerError: false)")
    func viewDidLoad_genericError_emitsFetchFailed_isServerErrorFalse() async throws {
        let h = TestHarness(service: makeFailingService(URLError(.notConnectedToInternet)))
        try await h.sendViewDidLoad()

        guard case .fetchFailed(let isServerError) = h.received.first else {
            Issue.record("fetchFailed output이 발행되지 않음")
            return
        }
        #expect(isServerError == false)
    }

    // MARK: - didTapOption

    @Test("didTapOption → updateOptionState(isSelected: true) emit")
    func didTapOption_selectsOption_emitsSelected() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.didTapOption(optionIdx: 2))

        #expect(h.optionStateOutputs.last?.optionIdx == 2)
        #expect(h.optionStateOutputs.last?.isSelected == true)
    }

    @Test("didTapOption 같은 옵션 두 번 → 선택 해제")
    func didTapOption_sameTwice_deselects() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.didTapOption(optionIdx: 1))
        h.send(.didTapOption(optionIdx: 1))

        let states = h.optionStateOutputs.filter { $0.optionIdx == 1 }
        guard states.count >= 2 else {
            Issue.record("옵션 1의 상태 변화가 2번 이상 발행되지 않음")
            return
        }
        #expect(states[0].isSelected == true)
        #expect(states[1].isSelected == false)
    }

    @Test("didTapOption 다른 옵션 선택 → 이전 옵션 해제 후 새 옵션 선택")
    func didTapOption_differentOption_switchesSelection() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.didTapOption(optionIdx: 1))
        h.resetReceived()

        h.send(.didTapOption(optionIdx: 3))

        guard h.optionStateOutputs.count >= 2 else {
            Issue.record("옵션 상태 변화가 2번 이상 발행되지 않음")
            return
        }
        #expect(h.optionStateOutputs[0] == (optionIdx: 1, isSelected: false))
        #expect(h.optionStateOutputs[1] == (optionIdx: 3, isSelected: true))
    }

    @Test("1번 문제에서 옵션 선택 → nextButton visible")
    func didTapOption_onFirstPage_nextButtonBecomesVisible() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.didTapOption(optionIdx: 2))

        #expect(h.nextButtonOutputs.last?.isVisible == true)
        #expect(h.nextButtonOutputs.last?.isTextSubmit == false)
    }

    @Test("1번 문제에서 옵션 해제 → nextButton hidden")
    func didTapOption_onFirstPage_deselect_nextButtonHidden() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.send(.didTapOption(optionIdx: 2))
        h.resetReceived()

        h.send(.didTapOption(optionIdx: 2))

        #expect(h.nextButtonOutputs.last?.isVisible == false)
    }

    // MARK: - 버튼 내비게이션

    @Test("didTapNextButton → 다음 문제 emit")
    func didTapNextButton_movesToNextQuestion() async throws {
        let h = TestHarness(service: makeService(questionCount: 3))
        try await h.sendViewDidLoad()
        h.send(.didTapOption(optionIdx: 1))
        h.resetReceived()

        h.send(.didTapNextButton)

        #expect(h.questionOutputs.last?.questionNumber == 2)
    }

    @Test("didTapPrevButton → 이전 문제 emit")
    func didTapPrevButton_movesToPrevQuestion() async throws {
        let h = TestHarness(service: makeService(questionCount: 3))
        try await h.sendViewDidLoad()
        h.send(.didTapOption(optionIdx: 1))
        h.send(.didTapNextButton)
        h.resetReceived()

        h.send(.didTapPrevButton)

        #expect(h.questionOutputs.last?.questionNumber == 1)
    }

    @Test("마지막 페이지에서 didTapNextButton → popSubmitAlert emit")
    func didTapNextButton_onLastPage_emitsPopSubmitAlert() async throws {
        let h = TestHarness(service: makeService(questionCount: 2))
        try await h.sendViewDidLoad()
        h.send(.didTapOption(optionIdx: 1))
        h.send(.didTapNextButton)

        #expect(h.questionOutputs.last?.questionNumber == 2)
        h.resetReceived()

        h.send(.didTapNextButton)

        guard case .popSubmitAlert = h.received.first else {
            Issue.record("popSubmitAlert output이 발행되지 않음")
            return
        }
    }

    @Test("2번째 페이지 진입 → prevButton visible")
    func navigateToSecondPage_prevButtonVisible() async throws {
        let h = TestHarness(service: makeService(questionCount: 3))
        try await h.sendViewDidLoad()
        h.send(.didTapOption(optionIdx: 1))
        h.resetReceived()

        h.send(.didTapNextButton)

        #expect(h.prevButtonOutputs.last == true)
    }

    @Test("마지막 페이지 진입 → nextButton isVisible: true, isTextSubmit: true")
    func navigateToLastPage_nextButtonShowsSubmit() async throws {
        let h = TestHarness(service: makeService(questionCount: 2))
        try await h.sendViewDidLoad()
        h.send(.didTapOption(optionIdx: 1))
        h.resetReceived()

        h.send(.didTapNextButton)

        #expect(h.nextButtonOutputs.last?.isVisible == true)
        #expect(h.nextButtonOutputs.last?.isTextSubmit == true)
    }

    // MARK: - 제출

    @Test("didTapAlertSubmit 성공 → submitSuccess + moveToExamResult(examId:) emit")
    func didTapAlertSubmit_success_emitsSubmitSuccessAndMoveToResult() async throws {
        let h = TestHarness(service: makeService(), examId: 7)
        try await h.sendViewDidLoad()
        h.resetReceived()

        try await h.sendAlertSubmit()

        let hasSubmitSuccess = h.received.contains { if case .submitSuccess = $0 { return true }; return false }
        #expect(hasSubmitSuccess)
        guard case .moveToExamResult(let examId) = h.received.last else {
            Issue.record("moveToExamResult output이 발행되지 않음")
            return
        }
        #expect(examId == 7)
    }

    @Test("didTapAlertSubmit 실패 → submitFailed emit")
    func didTapAlertSubmit_failure_emitsSubmitFailed() async throws {
        let service = makeService()
        service.submitTestResult = .failure(URLError(.notConnectedToInternet))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoad()
        h.resetReceived()

        try await h.sendAlertSubmit()

        guard case .submitFailed = h.received.first else {
            Issue.record("submitFailed output이 발행되지 않음")
            return
        }
    }

    @Test("didTapAlertSubmit 두 번 호출 → 한 번만 제출")
    func didTapAlertSubmit_calledTwice_preventsDoubleSubmit() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.didTapAlertSubmit)
        try await h.sendAlertSubmit()

        let submitSuccessCount = h.received.filter { if case .submitSuccess = $0 { return true }; return false }.count
        #expect(submitSuccessCount == 1)
    }

    // MARK: - 취소 / 알럿

    @Test("didTapCancelButton → moveToExamList emit")
    func didTapCancelButton_emitsMoveToExamList() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.didTapCancelButton)

        guard case .moveToExamList = h.received.first else {
            Issue.record("moveToExamList output이 발행되지 않음")
            return
        }
    }

    @Test("didTapAlertCancel → cancelAlert emit")
    func didTapAlertCancel_emitsCancelAlert() {
        let h = TestHarness(service: MockExamService())
        h.send(.didTapAlertCancel)

        guard case .cancelAlert = h.received.first else {
            Issue.record("cancelAlert output이 발행되지 않음")
            return
        }
    }
}
