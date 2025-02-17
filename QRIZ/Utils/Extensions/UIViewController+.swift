//
//  UIViewController+.swift
//  QRIZ
//
//  Created by 김세훈 on 1/7/25.
//

import UIKit
import Combine

extension UIViewController {
    /// `네비게이션 바의 타이틀을 설정을 도와주는 함수입니다.`
    func setNavigationBarTitle(
        title: String,
        font: UIFont? = UIFont.systemFont(ofSize: 18, weight: .bold),
        textColor: UIColor? = .coolNeutral800
    ) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = textColor
        self.navigationItem.titleView = titleLabel
    }
    
    /// `키보드가 나타나거나 사라질 때 특정 뷰를 이동시키는 알림을 관찰하는 함수입니다.`
    func observeKeyboardNotifications(for viewToMove: UIView) -> AnyCancellable {
        let willShowCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.keyboardWillShow(notification: notification, for: viewToMove)
            }
        
        let willHideCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.keyboardWillHide(notification: notification, for: viewToMove)
            }
        
        return AnyCancellable {
            willShowCancellable.cancel()
            willHideCancellable.cancel()
        }
    }
    
    // 키보드가 나타날 때 호출되는 메서드
    private func keyboardWillShow(notification: Notification, for viewToMove: UIView) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height * 0.9
        UIView.animate(withDuration: animationDuration) {
            viewToMove.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    
    // 키보드가 사라질 때 호출되는 메서드
    private func keyboardWillHide(notification: Notification, for viewToMove: UIView) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: animationDuration) {
            viewToMove.transform = .identity
        }
    }
}
