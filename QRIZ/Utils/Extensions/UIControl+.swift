//
//  UIControl+.swift
//  QRIZ
//
//  Created by 김세훈 on 2/4/25.
//

import UIKit
import Combine

extension UIControl {
    /// `UIControl 파라미터로 들어온 이벤트를 방출하는 퍼블리셔입니다.`
    ///  - Parameters:
    ///  - events: 감지하고 싶은 이벤트(touchUpInside, valueChanged 등등)를 입력받습니다.
    func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        Publishers.ControlEvent(control: self, events: events)
            .eraseToAnyPublisher()
    }
}
