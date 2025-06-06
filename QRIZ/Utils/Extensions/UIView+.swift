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
    
    /// `토스트 메시지 생성을 도와주는 메서드입니다.`
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 12, weight: .regular)
        toastLabel.backgroundColor = .coolNeutral800
        toastLabel.numberOfLines = 0
        
        let textSize = toastLabel.intrinsicContentSize
        let labelWidth = min(textSize.width + 40, self.bounds.width - 40)
        let labelHeight = textSize.height + 20
        
        toastLabel.frame = CGRect(
            x: (self.bounds.width - labelWidth) / 2,
            y: self.bounds.height - (labelHeight + 100),
            width: labelWidth,
            height: labelHeight
        )
        
        toastLabel.layer.cornerRadius = 6
        toastLabel.layer.masksToBounds = true
        
        self.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
    
    /// `QRIZ effect 그림자 설정용 메서드입니다.`
    func applyQRIZShadow(
        radius: CGFloat,
        color: UIColor = .coolNeutral300,
        opacity: Float = 0.12,
        offset: CGSize = .init(width: 0, height: 1)
    ) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
}
