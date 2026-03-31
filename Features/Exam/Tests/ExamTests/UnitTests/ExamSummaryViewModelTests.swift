//
//  ExamSummaryViewModelTests.swift
//  QRIZ
//

import Foundation
import Testing
import Combine
@testable import Exam

@MainActor
@Suite("ExamSummaryViewModel 테스트", .serialized)
struct ExamSummaryViewModelTests {

    // MARK: - TestHarness

    @MainActor
    private final class TestHarness {
        private let sut: ExamSummaryViewModel
        private let inputSubject = PassthroughSubject<ExamSummaryViewModel.Input, Never>()
        private(set) var received: [ExamSummaryViewModel.Output] = []
        private var cancellables = Set<AnyCancellable>()

        init(examId: Int = 1) {
            sut = ExamSummaryViewModel(examId: examId)
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: ExamSummaryViewModel.Input) {
            inputSubject.send(input)
        }

        func resetReceived() { received.removeAll() }
    }

    // MARK: - didTapBeginExam

    @Test("didTapBeginExam → moveToExam에 올바른 examId 전달")
    func didTapBeginExam_emitsMoveToExamWithCorrectId() {
        let h = TestHarness(examId: 42)
        h.send(.didTapBeginExam)
        guard case .moveToExam(let examId) = h.received.first else {
            Issue.record("moveToExam output이 발행되지 않음")
            return
        }
        #expect(examId == 42)
    }

    @Test("didTapBeginExam 두 번 호출 → moveToExam(examId:) 두 번 발행")
    func didTapBeginExam_calledTwice_emitsTwice() {
        let h = TestHarness(examId: 1)
        h.send(.didTapBeginExam)
        h.send(.didTapBeginExam)
        guard h.received.count == 2 else {
            Issue.record("Expected 2 outputs, got \(h.received.count)")
            return
        }
        guard case .moveToExam(let id1) = h.received[0],
              case .moveToExam(let id2) = h.received[1] else {
            Issue.record("Expected two .moveToExam outputs")
            return
        }
        #expect(id1 == 1)
        #expect(id2 == 1)
    }
}
