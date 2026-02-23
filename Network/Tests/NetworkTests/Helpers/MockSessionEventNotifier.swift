//
//  MockSessionEventNotifier.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import Combine
import QRIZUtils

final class MockSessionEventNotifier: SessionEventNotifier {

    private let subject = PassthroughSubject<SessionEvent, Never>()
    var notifiedEvents: [SessionEvent] = []

    var event: AnyPublisher<SessionEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    func notify(_ event: SessionEvent) {
        notifiedEvents.append(event)
        subject.send(event)
    }

    func reset() {
        notifiedEvents = []
    }
}
