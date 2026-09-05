import Foundation

@MainActor
public protocol ReviewPromptService: Sendable {
    var shouldShowPrompt: Bool { get }
    /// 모의고사/데일리 완료 시 호출한다 — 합산 완료 횟수를 1 증가시킨다.
    func recordCompletion()
    /// "다음 기회에" — 다음 노출 임계값을 postponeIncrement만큼 늘린다.
    func postponePrompt()
    /// "쓸게요!" — 이후 다시는 노출되지 않도록 표시한다.
    func markReviewed()
}

@MainActor
public final class ReviewPromptServiceImpl: ReviewPromptService, @unchecked Sendable {

    private let defaults: UserDefaults
    private let initialThreshold: Int
    private let postponeIncrement: Int

    private enum Key {
        static let completionCount = "reviewPrompt.completionCount"
        static let nextThreshold = "reviewPrompt.nextThreshold"
        static let hasReviewed = "reviewPrompt.hasReviewed"
    }

    public init(
        defaults: UserDefaults = .standard,
        initialThreshold: Int = 3,
        postponeIncrement: Int = 5
    ) {
        self.defaults = defaults
        self.initialThreshold = initialThreshold
        self.postponeIncrement = postponeIncrement
    }

    public var shouldShowPrompt: Bool {
        !hasReviewed && completionCount >= nextThreshold
    }

    public func recordCompletion() {
        defaults.set(completionCount + 1, forKey: Key.completionCount)
    }

    public func postponePrompt() {
        defaults.set(nextThreshold + postponeIncrement, forKey: Key.nextThreshold)
    }

    public func markReviewed() {
        defaults.set(true, forKey: Key.hasReviewed)
    }

    private var completionCount: Int {
        defaults.integer(forKey: Key.completionCount)
    }

    private var nextThreshold: Int {
        defaults.object(forKey: Key.nextThreshold) == nil
            ? initialThreshold
            : defaults.integer(forKey: Key.nextThreshold)
    }

    private var hasReviewed: Bool {
        defaults.bool(forKey: Key.hasReviewed)
    }
}
