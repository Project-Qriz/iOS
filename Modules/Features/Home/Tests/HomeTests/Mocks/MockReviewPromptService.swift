import Foundation
import QRIZUtils

@MainActor
final class MockReviewPromptService: ReviewPromptService {

    var shouldShowPrompt: Bool = false

    private(set) var recordMockExamCompletionCallCount = 0
    private(set) var recordDailyCompletionCallCount = 0
    private(set) var postponePromptCallCount = 0
    private(set) var markReviewedCallCount = 0

    func recordMockExamCompletion() {
        recordMockExamCompletionCallCount += 1
    }

    func recordDailyCompletion() {
        recordDailyCompletionCallCount += 1
    }

    func postponePrompt() {
        postponePromptCallCount += 1
    }

    func markReviewed() {
        markReviewedCallCount += 1
    }
}
