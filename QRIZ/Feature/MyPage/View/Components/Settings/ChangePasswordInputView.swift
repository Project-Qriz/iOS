//
//  ChangePasswordInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/20/25.
//

import UIKit

final class ChangePasswordInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldAspectRatio: CGFloat = 48.0 / 339.0
        static let currentPasswordTextFieldTopOffset: CGFloat = 16.0
    }
    
    private enum Attributes {
        static let currentPasswordPlaceholder = "현재 비밀번호"
        static let newPasswordPlaceholder = "새 비밀번호"
    }
    
    // MARK: - UI
    
    private let currentPasswordTextField: CustomTextField = {
        let textField = CustomTextField(
            placeholder: Attributes.currentPasswordPlaceholder,
            rightViewType: .passwordToggle
        )
        return textField
    }()
    
    private let newPasswordTextField: CustomTextField = {
        let textField = CustomTextField(
            placeholder: Attributes.newPasswordPlaceholder,
            rightViewType: .passwordToggle
        )
        return textField
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension ChangePasswordInputView {
    private func addSubviews() {
        [
            currentPasswordTextField,
            newPasswordTextField,
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        currentPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        newPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentPasswordTextField.topAnchor.constraint(equalTo: topAnchor),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            currentPasswordTextField.heightAnchor.constraint(
                equalTo: currentPasswordTextField.widthAnchor,
                multiplier: Metric.textFieldAspectRatio
            ),
            
            newPasswordTextField.topAnchor.constraint(
                equalTo: currentPasswordTextField.bottomAnchor,
                constant: Metric.currentPasswordTextFieldTopOffset
            ),
            newPasswordTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            newPasswordTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            newPasswordTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            newPasswordTextField.heightAnchor.constraint(
                equalTo: newPasswordTextField.widthAnchor,
                multiplier: Metric.textFieldAspectRatio
            ),
        ])
    }
}


