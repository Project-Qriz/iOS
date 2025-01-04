//
//  CustomTextField.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

/// 로그인, 회원가입 등에서 사용하는 CustomTextField입니다.
final class CustomTextField: UITextField {
    
    init(
        placeholder: String,
        isSecure: Bool = false,
        rightView: UIView? = nil,
        rightViewMode: UITextField.ViewMode = .never
    ) {
        super.init(frame: .zero)
        setupUI(placeholder: placeholder, isSecure: isSecure, rightView: rightView, rightViewMode: rightViewMode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(
        placeholder: String,
        isSecure: Bool,
        rightView: UIView?,
        rightViewMode: UITextField.ViewMode
    ) {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.coolNeutral300,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
        self.backgroundColor = .customBlue100
        self.layer.cornerRadius = 8
        self.isSecureTextEntry = isSecure
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        self.leftView = leftPaddingView
        self.leftViewMode = .always
        self.rightView = rightView
        self.rightViewMode = rightViewMode
    }
}
