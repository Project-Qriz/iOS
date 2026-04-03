//
//  MockSessionEventNotifier.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import QRIZUtils

final class MockSessionEventNotifier: SessionEventNotifier {

    private let continuation: AsyncStream<SessionEvent>.Continuation
    let events: AsyncStream<SessionEvent>
    var notifiedEvents: [SessionEvent] = []

    init() {
        var continuation: AsyncStream<SessionEvent>.Continuation!
        self.events = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }

    func notify(_ event: SessionEvent) {
        notifiedEvents.append(event)
        continuation.yield(event)
    }

    func reset() {
        notifiedEvents = []
    }
}
