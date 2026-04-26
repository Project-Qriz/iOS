import Foundation
import Testing
@testable import Daily
@testable import Network
import QRIZUtils

@MainActor
@Suite("DailyResultViewModel 테스트", .serialized)
struct DailyResultViewModelTests {

    // MARK: - Delegate Mock

    @MainActor
    private final class MockDelegate: DailyResultViewModelDelegate {
        var quitDailyCount = 0
        var moveToConceptCount = 0
        var showResultDetailData: ResultDetailData?
        var showProblemDetailQuestionId: Int?

        func didRequestQuitDaily() { quitDailyCount += 1 }
        func didRequestMoveToConcept() { moveToConceptCount += 1 }
        func didRequestShowResultDetail(_ data: ResultDetailData) { showResultDetailData = data }
        func didRequestShowProblemDetail(questionId: Int) { showProblemDetailQuestionId = questionId }
    }

    // MARK: - TestHarness

    @MainActor
    private final class TestHarness {
        let sut: DailyResultViewModel
        let delegate: MockDelegate

        init(service: DailyService, type: DailyLearnType = .daily) {
            sut = DailyResultViewModel(dailyTestType: type, day: 1, dailyService: service, userInfo: .shared)
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
        passed: Bool = true,
        items: [DailyResultResponse.DataInfo.ItemInfo] = [
            // skillId는 1-based: SurveyCheckList.list[skillId - 1]로 접근하므로 반드시 1 이상이어야 함
            DailyResultResponse.DataInfo.ItemInfo(skillId: 1, score: 80.0)
        ],
        subjectResults: [SubjectResult] = [
            SubjectResult(questionId: 1, detailType: "DDL", question: "CREATE 문법", correction: true)
        ]
    ) -> MockDailyService {
        let service = MockDailyService()
        service.getDailyTestResultResult = .success(
            DailyResultResponse(
                code: 1,
                msg: "ok",
                data: DailyResultResponse.DataInfo(
                    dayNumber: "1",
                    passed: passed,
                    reviewDay: false,
                    comprehensiveReviewDay: false,
                    items: items,
                    subjectResultsList: subjectResults,
                    totalScore: 80.0
                )
            )
        )
        service.getDailyWeeklyScoreResult = .success(
            DailyWeeklyScoreResponse(
                code: 1,
                msg: "ok",
                data: DailyWeeklyScoreResponse.DataInfo(
                    subjects: [
                        DailyWeeklyScoreResponse.DataInfo.SubjectInfo(
                            title: "1과목",
                            totalScore: 80.0,
                            majorItems: [
                                DailyWeeklyScoreResponse.DataInfo.SubjectInfo.MajorItemInfo(
                                    majorItem: "항목1",
                                    score: 80.0,
                                    subItemScores: []
                                )
                            ]
                        ),
                        DailyWeeklyScoreResponse.DataInfo.SubjectInfo(
                            title: "2과목",
                            totalScore: 70.0,
                            majorItems: [
                                DailyWeeklyScoreResponse.DataInfo.SubjectInfo.MajorItemInfo(
                                    majorItem: "항목2",
                                    score: 70.0,
                                    subItemScores: []
                                )
                            ]
                        )
                    ],
                    totalScore: 75.0
                )
            )
        )
        return service
    }

    private func makeFailingService(_ error: Error) -> MockDailyService {
        let service = MockDailyService()
        service.getDailyTestResultResult = .failure(error)
        service.getDailyWeeklyScoreResult = .failure(error)
        return service
    }

    /// getDailyWeeklyScore 성공 + getDailyTestResult 실패 (weekly 두 번째 API 호출 실패 시나리오)
    private func makeWeeklyPartialFailService(_ error: Error) -> MockDailyService {
        let service = makeService()
        service.getDailyTestResultResult = .failure(error)
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

    // MARK: - onViewDidLoad 데이터 업데이트 케이스

    @Test("onViewDidLoad daily 성공 → resultScoresData에 passed 반영")
    func onViewDidLoad_daily_success_updatesPassed() async throws {
        let h = TestHarness(service: makeService(passed: true))
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.passed == true)
    }

    @Test("onViewDidLoad daily 성공 → resultScoresData에 dayNum 반영")
    func onViewDidLoad_daily_success_updatesDayNum() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.dayNum == "DAY 1")
    }

    @Test("onViewDidLoad daily 성공 → gradeResultList에 문제 목록 반영")
    func onViewDidLoad_daily_success_updatesGradeResultList() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultGradeListData.gradeResultList.count == 1)
        #expect(h.sut.resultGradeListData.gradeResultList.first?.questionId == 1)
    }

    @Test("onViewDidLoad weekly 성공 → subjectCount가 두 과목 항목 수 합산으로 설정됨")
    func onViewDidLoad_weekly_success_updatesSubjectCount() async throws {
        // 1과목 1개 + 2과목 1개 = 2
        let h = TestHarness(service: makeService(), type: .weekly)
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.subjectCount == 2)
    }

    @Test("onViewDidLoad daily 성공 → errorMessage nil 유지")
    func onViewDidLoad_daily_success_errorMessageRemainsNil() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.errorMessage == nil)
    }

    @Test("onViewDidLoad daily 성공 → subjectScores에 점수 반영")
    func onViewDidLoad_daily_success_updatesSubjectScores() async throws {
        let h = TestHarness(service: makeService(items: [
            DailyResultResponse.DataInfo.ItemInfo(skillId: 1, score: 75.0)
        ]))
        try await h.sendViewDidLoadAndWaitForUpdate()
        #expect(h.sut.resultScoresData.subjectScores[0] == 75.0)
    }

    @Test("onViewDidLoad weekly getDailyTestResult 실패 → errorMessage 재시도 안내 메시지 설정")
    func onViewDidLoad_weekly_partialFail_setsErrorMessage() async throws {
        let h = TestHarness(service: makeWeeklyPartialFailService(URLError(.timedOut)), type: .weekly)
        try await h.sendViewDidLoad()
        #expect(h.sut.errorMessage == "잠시 후 다시 시도해주세요.")
    }

    // MARK: - 네비게이션 액션

    @Test("didTapCancel → delegate.didRequestQuitDaily 호출")
    func didTapCancel_callsDelegateQuitDaily() {
        let h = TestHarness(service: MockDailyService())
        h.sut.didTapCancel()
        #expect(h.delegate.quitDailyCount == 1)
    }

    @Test("didTapConcept → delegate.didRequestMoveToConcept 호출")
    func didTapConcept_callsDelegateMoveToConcept() {
        let h = TestHarness(service: MockDailyService())
        h.sut.didTapConcept()
        #expect(h.delegate.moveToConceptCount == 1)
    }

    @Test("didTapProblem → delegate.didRequestShowProblemDetail에 questionId 전달")
    func didTapProblem_callsDelegateWithQuestionId() {
        let h = TestHarness(service: MockDailyService())
        h.sut.didTapProblem(questionId: 42)
        #expect(h.delegate.showProblemDetailQuestionId == 42)
    }

    @Test("didTapResultDetail + .weekly → delegate에 올바른 resultDetailData 인스턴스 전달")
    func didTapResultDetail_weeklyType_passesCorrectResultDetailData() {
        let h = TestHarness(service: MockDailyService(), type: .weekly)
        h.sut.didTapResultDetail()
        #expect(h.delegate.showResultDetailData === h.sut.resultDetailData)
    }

    @Test("didTapResultDetail + .daily → delegate 호출 안 함")
    func didTapResultDetail_dailyType_doesNotCallDelegate() {
        let h = TestHarness(service: MockDailyService(), type: .daily)
        h.sut.didTapResultDetail()
        #expect(h.delegate.showResultDetailData == nil)
    }
}
