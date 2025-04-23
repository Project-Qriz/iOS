//
//  ResetPasswordMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 2/1/25.
//

import UIKit

final class ResetPasswordMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let headerViewTopOffset: CGFloat = 40.0
        static let inputViewTopOffset: CGFloat = 20.0
        static let horizontalMargin: CGFloat = 18.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
    }
    
    private enum Attributes {
        static let buttonTitle: String = "변경하기"
    }
    
    // MARK: - Properties
    
    private let findAccountHeaderView = FindAccountHeaderView()
    let passwordInputView = PasswordInputView()
    let signUpFooterView = SignUpFooterView()
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        setupUI()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
        findAccountHeaderView.configure(
            title: FindAccountType.resetPassword.headerTitle,
            description: UILabel.setLineSpacing(8, text: FindAccountType.resetPassword.headerDescription)
        )
        signUpFooterView.configure(buttonTitle: Attributes.buttonTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension ResetPasswordMainView {
    private func addSubviews() {
        [
            findAccountHeaderView,
            passwordInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        findAccountHeaderView.translatesAutoresizingMaskIntoConstraints = false
        passwordInputView.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            findAccountHeaderView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Metric.headerViewTopOffset
            ),
            findAccountHeaderView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            findAccountHeaderView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            
            passwordInputView.topAnchor.constraint(
                equalTo: findAccountHeaderView.bottomAnchor,
                constant: Metric.inputViewTopOffset
            ),
            passwordInputView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            passwordInputView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            
            signUpFooterView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            signUpFooterView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            signUpFooterView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: Metric.signUpFooterViewBottomOffset
            )
        ])
    }
}


