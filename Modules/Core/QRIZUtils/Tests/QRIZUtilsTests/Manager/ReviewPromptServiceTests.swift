import Testing
import Foundation
@testable import QRIZUtils

@MainActor
@Suite("ReviewPromptService 테스트")
struct ReviewPromptServiceTests {

    private func makeSUT(
        initialMockExamThreshold: Int = 1,
        mockExamPostponeIncrement: Int = 3,
        initialDailyThreshold: Int = 2,
        dailyPostponeIncrement: Int = 5
    ) -> ReviewPromptServiceImpl {
        let defaults = UserDefaults(suiteName: "ReviewPromptServiceTests-\(UUID().uuidString)")!
        return ReviewPromptServiceImpl(
            defaults: defaults,
            initialMockExamThreshold: initialMockExamThreshold,
            mockExamPostponeIncrement: mockExamPostponeIncrement,
            initialDailyThreshold: initialDailyThreshold,
            dailyPostponeIncrement: dailyPostponeIncrement
        )
    }

    @Test("초기 상태(완료 0회)에서는 shouldShowPrompt가 false다")
    func initialStateDoesNotShowPrompt() {
        let sut = makeSUT()

        #expect(sut.shouldShowPrompt == false)
    }

    @Test("모의고사 완료 횟수가 임계값(1) 이상이면 shouldShowPrompt는 true다")
    func mockExamAtThresholdShowsPrompt() {
        let sut = makeSUT()

        sut.recordMockExamCompletion()

        #expect(sut.shouldShowPrompt == true)
    }

    @Test("데일리 완료 횟수가 임계값(2) 미만이면 shouldShowPrompt는 false다")
    func dailyBelowThresholdDoesNotShowPrompt() {
        let sut = makeSUT()

        sut.recordDailyCompletion()

        #expect(sut.shouldShowPrompt == false)
    }

    @Test("데일리 완료 횟수가 임계값(2) 이상이면 shouldShowPrompt는 true다")
    func dailyAtThresholdShowsPrompt() {
        let sut = makeSUT()

        sut.recordDailyCompletion()
        sut.recordDailyCompletion()

        #expect(sut.shouldShowPrompt == true)
    }

    @Test("모의고사로 트리거된 postponePrompt는 두 임계값을 모두 현재 카운트 기준으로 끌어올린다")
    func postponeAfterMockExamTriggerRaisesBothThresholds() {
        let sut = makeSUT()

        sut.recordMockExamCompletion()
        #expect(sut.shouldShowPrompt == true)

        sut.postponePrompt()
        #expect(sut.shouldShowPrompt == false)

        for _ in 0..<2 { sut.recordMockExamCompletion() }
        #expect(sut.shouldShowPrompt == false)

        sut.recordMockExamCompletion()
        #expect(sut.shouldShowPrompt == true)
    }

    @Test("postponePrompt 이후 데일리는 postponeIncrement(5)만큼 더 진행해야 다시 노출된다")
    func postponeDelaysDailyByItsOwnIncrement() {
        let sut = makeSUT()

        sut.recordMockExamCompletion()
        sut.postponePrompt()

        for _ in 0..<4 { sut.recordDailyCompletion() }
        #expect(sut.shouldShowPrompt == false)

        sut.recordDailyCompletion()
        #expect(sut.shouldShowPrompt == true)
    }

    @Test("markReviewed 호출 시 임계값을 넘어도 영구히 shouldShowPrompt는 false다")
    func markReviewedPermanentlyHidesPrompt() {
        let sut = makeSUT()
        sut.recordMockExamCompletion()
        #expect(sut.shouldShowPrompt == true)

        sut.markReviewed()

        #expect(sut.shouldShowPrompt == false)

        sut.recordMockExamCompletion()
        sut.recordDailyCompletion()
        sut.recordDailyCompletion()
        #expect(sut.shouldShowPrompt == false)
    }
}
