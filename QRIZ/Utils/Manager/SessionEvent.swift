//
//  SessionEvent.swift
//  QRIZ
//
//  Created by 김세훈 on 6/2/25.
//

import Combine

enum SessionEvent {
    case expired
}

protocol SessionEventNotifier {
    var event: AnyPublisher<SessionEvent, Never> { get }
    func notify(_ event: SessionEvent)
}

final class SessionEventNotifierImpl: SessionEventNotifier {
    
    // MARK: - Properties
    
    private let subject = PassthroughSubject<SessionEvent, Never>()
    
    var event: AnyPublisher<SessionEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - Functions
    
    func notify(_ event: SessionEvent) {
        return subject.send(event)
    }
}
