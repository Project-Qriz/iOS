import Testing
import Foundation
@testable import QRIZUtils

@MainActor
@Suite("ReviewPromptService 테스트")
struct ReviewPromptServiceTests {

    private func makeSUT(initialThreshold: Int = 3, postponeIncrement: Int = 5) -> ReviewPromptServiceImpl {
        let defaults = UserDefaults(suiteName: "ReviewPromptServiceTests-\(UUID().uuidString)")!
        return ReviewPromptServiceImpl(defaults: defaults, initialThreshold: initialThreshold, postponeIncrement: postponeIncrement)
    }

    @Test("초기 상태(완료 0회, 임계값 3)에서는 shouldShowPrompt가 false다")
    func initialStateDoesNotShowPrompt() {
        let sut = makeSUT()

        #expect(sut.shouldShowPrompt == false)
    }

    @Test("완료 횟수가 임계값 미만이면 shouldShowPrompt는 false다")
    func belowThresholdDoesNotShowPrompt() {
        let sut = makeSUT(initialThreshold: 3)

        sut.recordCompletion()
        sut.recordCompletion()

        #expect(sut.shouldShowPrompt == false)
    }

    @Test("완료 횟수가 임계값 이상이면 shouldShowPrompt는 true다")
    func atThresholdShowsPrompt() {
        let sut = makeSUT(initialThreshold: 3)

        sut.recordCompletion()
        sut.recordCompletion()
        sut.recordCompletion()

        #expect(sut.shouldShowPrompt == true)
    }

    @Test("postponePrompt 호출 시 임계값이 postponeIncrement만큼 늘어나 다시 false가 된다")
    func postponePromptRaisesThreshold() {
        let sut = makeSUT(initialThreshold: 3, postponeIncrement: 5)
        sut.recordCompletion()
        sut.recordCompletion()
        sut.recordCompletion()
        #expect(sut.shouldShowPrompt == true)

        sut.postponePrompt()

        #expect(sut.shouldShowPrompt == false)

        for _ in 0..<4 { sut.recordCompletion() }
        #expect(sut.shouldShowPrompt == false)

        sut.recordCompletion()
        #expect(sut.shouldShowPrompt == true)
    }

    @Test("markReviewed 호출 시 임계값을 넘어도 영구히 shouldShowPrompt는 false다")
    func markReviewedPermanentlyHidesPrompt() {
        let sut = makeSUT(initialThreshold: 3)
        sut.recordCompletion()
        sut.recordCompletion()
        sut.recordCompletion()
        #expect(sut.shouldShowPrompt == true)

        sut.markReviewed()

        #expect(sut.shouldShowPrompt == false)

        sut.recordCompletion()
        sut.recordCompletion()
        #expect(sut.shouldShowPrompt == false)
    }
}
