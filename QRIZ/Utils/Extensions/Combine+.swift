//
//  Combine+.swift
//  QRIZ
//
//  Created by 김세훈 on 2/4/25.
//

import UIKit
import Combine

extension Combine.Publishers {
    /// `UIControl 파라미터로 들어온 이벤트를 방출하는 퍼블리셔입니다.`
    /// - Parameters:
    /// - control: 이벤트를 감지할 UIControl입니다.
    /// - events: 감지하고 싶은 이벤트(touchUpInside, valueChanged 등)를 입력받습니다.
    struct ControlEvent<Control: UIControl>: Publisher {
        typealias Output = Void
        typealias Failure = Never
        
        private let control: Control
        private let controlEvents: Control.Event
        
        init(control: Control, events: Control.Event) {
            self.control = control
            self.controlEvents = events
        }
        
        func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            event: controlEvents)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Combine.Publishers.ControlEvent {
    /// `UIControl 파라미터로 들어온 이벤트를 감지하고 해당 이벤트 발생 시 Void 값을 방출하는 Subscription 클래스입니다.`
    /// - Parameters:
    /// - subscriber: 이벤트를 전달받을 구독자입니다.
    /// - control: 이벤트를 감지할 UIControl입니다.
    /// - event: 감지하고 싶은 이벤트를 입력받습니다.
    private final class Subscription<S: Subscriber, Target: UIControl>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: Target?
        
        init(subscriber: S, control: Target, event: Target.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(processControlEvent), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) {
        }
        
        func cancel() {
            subscriber = nil
        }
        
        @objc private func processControlEvent() {
            _ = subscriber?.receive()
        }
    }
}
