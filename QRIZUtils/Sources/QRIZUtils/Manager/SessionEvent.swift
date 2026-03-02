//
//  SessionEvent.swift
//  QRIZUtils
//
//  Created by 김세훈 on 6/2/25.
//

public enum SessionEvent: Sendable {
    case expired
}

public protocol SessionEventNotifier: Sendable {
    var events: AsyncStream<SessionEvent> { get }
    func notify(_ event: SessionEvent)
}

public final class SessionEventNotifierImpl: SessionEventNotifier {

    // MARK: - Properties

    private let continuation: AsyncStream<SessionEvent>.Continuation
    public let events: AsyncStream<SessionEvent>

    // MARK: - Initialize

    public init() {
        var continuation: AsyncStream<SessionEvent>.Continuation!
        self.events = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }

    // MARK: - Functions

    public func notify(_ event: SessionEvent) {
        continuation.yield(event)
    }
}
