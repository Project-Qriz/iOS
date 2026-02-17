//
//  SessionEvent.swift
//  QRIZ
//
//  Created by 김세훈 on 6/2/25.
//

import Combine

public enum SessionEvent {
    case expired
}

public protocol SessionEventNotifier {
    var event: AnyPublisher<SessionEvent, Never> { get }
    func notify(_ event: SessionEvent)
}

public final class SessionEventNotifierImpl: SessionEventNotifier {

    // MARK: - Properties

    private let subject = PassthroughSubject<SessionEvent, Never>()

    public var event: AnyPublisher<SessionEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - Initialize

    public init() {}

    // MARK: - Functions

    public func notify(_ event: SessionEvent) {
        return subject.send(event)
    }
}
