//
//  UIView+.swift
//  QRIZ
//
//  Created by 김세훈 on 1/7/25.
//

import UIKit
import Combine

extension UIView {
    /// `뷰에 탭 제스처가 끝났을 때 발행되는 퍼블리셔입니다.`
    func tapGestureEndedPublisher() -> AnyPublisher<Void, Never> {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        return tapGesture.publisher(for: \.state)
            .filter { $0 == .ended }
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
