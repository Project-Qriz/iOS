import Foundation

@MainActor
public protocol ReviewPromptService: Sendable {
    var shouldShowPrompt: Bool { get }
    /// 모의고사 완료 시 호출한다 — 모의고사 완료 횟수를 1 증가시킨다.
    func recordMockExamCompletion()
    /// 데일리 완료 시 호출한다 — 데일리 완료 횟수를 1 증가시킨다.
    func recordDailyCompletion()
    /// "다음 기회에" — 모의고사/데일리 각각의 다음 노출 임계값을 postponeIncrement만큼 늘린다.
    func postponePrompt()
    /// "쓸게요!" — 이후 다시는 노출되지 않도록 표시한다.
    func markReviewed()
}

@MainActor
public final class ReviewPromptServiceImpl: ReviewPromptService, Sendable {

    private let defaults: UserDefaults
    private let initialMockExamThreshold: Int
    private let mockExamPostponeIncrement: Int
    private let initialDailyThreshold: Int
    private let dailyPostponeIncrement: Int

    private enum Key {
        static let mockExamCompletionCount = "reviewPrompt.mockExamCompletionCount"
        static let mockExamNextThreshold = "reviewPrompt.mockExamNextThreshold"
        static let dailyCompletionCount = "reviewPrompt.dailyCompletionCount"
        static let dailyNextThreshold = "reviewPrompt.dailyNextThreshold"
        static let hasReviewed = "reviewPrompt.hasReviewed"
    }

    public init(
        defaults: UserDefaults = .standard,
        initialMockExamThreshold: Int = 1,
        mockExamPostponeIncrement: Int = 3,
        initialDailyThreshold: Int = 2,
        dailyPostponeIncrement: Int = 5
    ) {
        self.defaults = defaults
        self.initialMockExamThreshold = initialMockExamThreshold
        self.mockExamPostponeIncrement = mockExamPostponeIncrement
        self.initialDailyThreshold = initialDailyThreshold
        self.dailyPostponeIncrement = dailyPostponeIncrement
    }

    public var shouldShowPrompt: Bool {
        guard !hasReviewed else { return false }
        return mockExamCompletionCount >= mockExamNextThreshold || dailyCompletionCount >= dailyNextThreshold
    }

    public func recordMockExamCompletion() {
        defaults.set(mockExamCompletionCount + 1, forKey: Key.mockExamCompletionCount)
    }

    public func recordDailyCompletion() {
        defaults.set(dailyCompletionCount + 1, forKey: Key.dailyCompletionCount)
    }

    public func postponePrompt() {
        // 트리거된 쪽 임계값만 올리면 아직 넘어서 있는 다른 쪽 때문에 즉시 재노출될 수 있으므로,
        // 항상 "지금 카운트로부터 N번 더"가 되도록 두 임계값을 함께 재설정한다.
        defaults.set(mockExamCompletionCount + mockExamPostponeIncrement, forKey: Key.mockExamNextThreshold)
        defaults.set(dailyCompletionCount + dailyPostponeIncrement, forKey: Key.dailyNextThreshold)
    }

    public func markReviewed() {
        defaults.set(true, forKey: Key.hasReviewed)
    }

    private var mockExamCompletionCount: Int {
        defaults.integer(forKey: Key.mockExamCompletionCount)
    }

    private var mockExamNextThreshold: Int {
        defaults.object(forKey: Key.mockExamNextThreshold) == nil
            ? initialMockExamThreshold
            : defaults.integer(forKey: Key.mockExamNextThreshold)
    }

    private var dailyCompletionCount: Int {
        defaults.integer(forKey: Key.dailyCompletionCount)
    }

    private var dailyNextThreshold: Int {
        defaults.object(forKey: Key.dailyNextThreshold) == nil
            ? initialDailyThreshold
            : defaults.integer(forKey: Key.dailyNextThreshold)
    }

    private var hasReviewed: Bool {
        defaults.bool(forKey: Key.hasReviewed)
    }
}
