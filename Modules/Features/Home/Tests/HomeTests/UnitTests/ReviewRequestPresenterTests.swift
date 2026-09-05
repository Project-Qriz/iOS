import Testing
import Foundation
@testable import Home

@MainActor
@Suite("ReviewRequestPresenter 테스트")
struct ReviewRequestPresenterTests {

    @Test("postpone() → reviewPromptService.postponePrompt()가 호출된다")
    func postponeCallsPostponePrompt() {
        let reviewPromptService = MockReviewPromptService()
        var openedURLs: [URL] = []
        let sut = ReviewRequestPresenter(reviewPromptService: reviewPromptService, openURL: { openedURLs.append($0) })

        sut.postpone()

        #expect(reviewPromptService.postponePromptCallCount == 1)
        #expect(reviewPromptService.markReviewedCallCount == 0)
        #expect(openedURLs.isEmpty)
    }

    @Test("review() → reviewPromptService.markReviewed()가 호출되고 App Store URL이 열린다")
    func reviewCallsMarkReviewedAndOpensAppStoreURL() {
        let reviewPromptService = MockReviewPromptService()
        var openedURLs: [URL] = []
        let sut = ReviewRequestPresenter(reviewPromptService: reviewPromptService, openURL: { openedURLs.append($0) })

        sut.review()

        #expect(reviewPromptService.markReviewedCallCount == 1)
        #expect(reviewPromptService.postponePromptCallCount == 0)
        #expect(openedURLs.count == 1)
    }
}
