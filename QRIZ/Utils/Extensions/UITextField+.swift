//
//  UITextField+.swift
//  QRIZ
//
//  Created by 김세훈 on 12/29/24.
//

import UIKit
import Combine

extension UITextField {
    /// `UITextField 텍스트 변경 시 발행되는 퍼블리셔입니다.`
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { _ in self.text ?? "" }
            .eraseToAnyPublisher()
    }
    
    /// `UITextField 텍스트 입력 완료 시 발행되는 퍼블리셔입니다.`
    var textDidEndEditingPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: self)
            .map { _ in self.text ?? "" }
            .eraseToAnyPublisher()
    }
}
