import Foundation
import QRIZUtils

@MainActor
final class MockReviewPromptService: ReviewPromptService {

    var shouldShowPrompt: Bool = false

    private(set) var recordCompletionCallCount = 0
    private(set) var postponePromptCallCount = 0
    private(set) var markReviewedCallCount = 0

    func recordCompletion() {
        recordCompletionCallCount += 1
    }

    func postponePrompt() {
        postponePromptCallCount += 1
    }

    func markReviewed() {
        markReviewedCallCount += 1
    }
}
