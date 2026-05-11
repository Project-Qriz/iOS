//
//  ExamResultViewModelTests.swift
//  QRIZ
//

import Foundation
import Testing
@testable import Exam
import QRIZNetwork
import QRIZUtils

@MainActor
@Suite("ExamResultViewModel 테스트", .serialized)
struct ExamResultViewModelTests {

    // MARK: - Delegate Mock

    @MainActor
    private final class MockDelegate: ExamResultViewModelDelegate {
        var quitExamCount = 0
        var moveToConceptCount = 0
        var moveToResultDetailCount = 0
        var showProblemDetailQuestionId: Int?

        func didRequestQuitExam() { quitExamCount += 1 }
        func didRequestMoveToConcept() { moveToConceptCount += 1 }
        func didRequestMoveToResultDetail() { moveToResultDetailCount += 1 }
        func didRequestShowProblemDetail(questionId: Int) { showProblemDetailQuestionId = questionId }
    }

    // MARK: - TestHarness

    @MainActor
    private final class TestHarness {
        let sut: ExamResultViewModel
        let delegate: MockDelegate

        init(service: any ExamService) {
            sut = ExamResultViewModel(examId: 1, examService: service, userInfo: .shared)
            delegate = MockDelegate()
            sut.delegate = delegate
        }

        /// fetch 완료만 기다림 — updateData() 내부 500ms sleep 이전 상태를 검증할 때 사용
        func sendViewDidLoad() async throws {
            sut.onViewDidLoad()
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        /// fetch + updateData() 전파까지 기다림 — ObservableObject 반영 여부를 검증할 때 사용
        func sendViewDidLoadAndWaitForUpdate() async throws {
            sut.onViewDidLoad()
            try await Task.sleep(nanoseconds: updateDataSleepNanoseconds)
        }
    }

    // MARK: - Factories

    private func makeService(
        problemCount: Int = 2,
        historicalCount: Int = 3
    ) -> MockExamService {
        let service = MockExamService()
        service.getExamResultResult = .success(MockExamService.makeExamResult(problemCount: problemCount, historicalCount: historicalCount))
        service.getExamScoreResult = .success(MockExamService.makeExamScore())
        return service
    }

    private func makeFailingService(_ error: Error) -> MockExamService {
        let service = MockExamService()
        service.getExamResultResult = .failure(error)
        service.getExamScoreResult = .failure(error)
        return service
    }

    private func makePartialFailingService(
        resultError: Error? = nil,
        scoreError: Error? = nil
    ) -> MockExamService {
        let service = MockExamService()
        service.getExamResultResult = resultError.map { .failure($0) } ?? .success(MockExamService.makeExamResult())
        service.getExamScoreResult = scoreError.map { .failure($0) } ?? .success(MockExamService.makeExamScore())
        return service
    }

    // MARK: - onViewDidLoad 에러 케이스

    @Test("onViewDidLoad 서버 에러 → errorMessage 서버 에러 안내 메시지 설정")
    func onViewDidLoad_serverError_setsServerErrorMessage() async throws {
        let h = TestHarness(service: makeFailingService(NetworkError.serverError(httpStatus: 500)))
        try await h.sendViewDidLoad()
        #expect(h.sut.errorMessage == "관리자에게 문의하세요.")
    }

    @Test("onViewDidLoad 일반 에러 → errorMessage 재시도 안내 메시지 설정")
    func onViewDidLoad_genericError_setsGenericErrorMessage() async throws {
        let h = TestHarness(service: makeFailingService(URLError(.notConnectedToInternet)))
        try await h.sendViewDidLoad()
        #expect(h.sut.errorMessage == "잠시 후 다시 시도해주세요.")
    }

    @Test("getExamScore 실패 → errorMessage 재시도 안내 메시지 설정")
    func onViewDidLoad_scoreApiFails_setsErrorMessage() async throws {
        let h = TestHarness(service: makePartialFailingService(scoreError: URLError(.notConnectedToInternet)))
        try await h.sendViewDidLoad()
        #expect(h.sut.errorMessage == "잠시 후 다시 시도해주세요.")
    }

    // MARK: - onViewDidLoad 데이터 업데이트 케이스

    @Test("onViewDidLoad 성공 → errorMessage nil 유지")
    func onViewDidLoad_success_errorMessageRemainsNil() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.errorMessage == nil)
    }

    @Test("onViewDidLoad 성공 → gradeResultList에 문제 목록 반영")
    func onViewDidLoad_success_updatesGradeResultList() async throws {
        let h = TestHarness(service: makeService(problemCount: 3))
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultGradeListData.gradeResultList.count == 3)
        #expect(h.sut.resultGradeListData.gradeResultList.first?.questionId == 1)
    }

    @Test("onViewDidLoad 성공 → subjectCount가 두 과목 항목 수 합산으로 설정됨")
    func onViewDidLoad_success_updatesSubjectCount() async throws {
        // makeExamScore: 1과목 majorItem 1개 + 2과목 majorItem 1개 = 2
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.subjectCount == 2)
    }

    @Test("onViewDidLoad 성공 → subjectCount가 각 과목 majorItems 수의 합산")
    func onViewDidLoad_success_subjectCountSumsMajorItems() async throws {
        // 1과목 3개 + 2과목 2개 = 5
        let service = makeService()
        service.getExamScoreResult = .success(MockExamService.makeExamScore(subject1MajorCount: 3, subject2MajorCount: 2))
        let h = TestHarness(service: service)
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.subjectCount == 5)
    }

    @Test("onViewDidLoad 성공 → subjectScores에 점수 반영")
    func onViewDidLoad_success_updatesSubjectScores() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.subjectScores[0] == 80.0)
        #expect(h.sut.resultScoresData.subjectScores[1] == 70.0)
    }

    @Test("onViewDidLoad 성공 → scoreGraphData에 historicalScores 반영")
    func onViewDidLoad_success_updatesScoreGraphData() async throws {
        // makeExamResult default: historicalCount = 3
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.scoreGraphData.totalScores.count == 3)
    }

    @Test("onViewDidLoad 두 번 호출 → scoreGraphData 중복 누적 없음")
    func onViewDidLoad_calledTwice_scoreGraphDataNotDuplicated() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        try await h.sendViewDidLoadAndWaitForUpdate()
        // 두 번 호출해도 historicalCount(3)만큼만 유지되어야 함
        #expect(h.sut.scoreGraphData.totalScores.count == 3)
    }

    // MARK: - 네비게이션 액션

    @Test("didTapCancel → delegate.didRequestQuitExam 호출")
    func didTapCancel_callsDelegateQuitExam() {
        let h = TestHarness(service: makeService())
        h.sut.didTapCancel()
        #expect(h.delegate.quitExamCount == 1)
    }

    @Test("didTapConcept → delegate.didRequestMoveToConcept 호출")
    func didTapConcept_callsDelegateMoveToConcept() {
        let h = TestHarness(service: makeService())
        h.sut.didTapConcept()
        #expect(h.delegate.moveToConceptCount == 1)
    }

    @Test("didTapResultDetail → delegate.didRequestMoveToResultDetail 호출")
    func didTapResultDetail_callsDelegateMoveToResultDetail() {
        let h = TestHarness(service: makeService())
        h.sut.didTapResultDetail()
        #expect(h.delegate.moveToResultDetailCount == 1)
    }

    @Test("didTapProblem → delegate.didRequestShowProblemDetail에 questionId 전달")
    func didTapProblem_callsDelegateWithQuestionId() {
        let h = TestHarness(service: makeService())
        h.sut.didTapProblem(questionId: 42)
        #expect(h.delegate.showProblemDetailQuestionId == 42)
    }
}
