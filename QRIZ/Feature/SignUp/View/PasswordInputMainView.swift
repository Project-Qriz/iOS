//
//  PasswordInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/4/25.
//

import UIKit

final class PasswordInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let passwordInputViewTopOffset: CGFloat = 24.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "비밀번호를 입력해주세요!"
        static let headerDescription: String = "사용할 비밀번호를 입력해주세요."
        static let footerTitle: String = "가입하기"
        static let progressValue: Float = 1.0
    }
    
    // MARK: - Properties
    
    private let signUpHeaderView = SignUpHeaderView()
    let passwordInputView = PasswordInputView()
    let signUpFooterView = SignUpFooterView()
    
    // MARK: - initialize
    
    init() {
        super.init(frame: .zero)
        setupUI(
            title: Attributes.headerTitle,
            progressValue: Attributes.progressValue,
            buttonTitle: Attributes.footerTitle
        )
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI(
        title: String,
        progressValue: Float,
        buttonTitle: String
    ) {
        self.backgroundColor = .white
        signUpHeaderView.configure(title: title, progress: progressValue)
        signUpFooterView.configure(buttonTitle: buttonTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension PasswordInputMainView {
    private func addSubviews() {
        [
            signUpHeaderView,
            passwordInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signUpHeaderView.translatesAutoresizingMaskIntoConstraints = false
        passwordInputView.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signUpHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signUpHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            passwordInputView.topAnchor.constraint(equalTo: signUpHeaderView.bottomAnchor, constant: Metric.passwordInputViewTopOffset),
            passwordInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            passwordInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signUpFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signUpFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signUpFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signUpFooterViewBottomOffset)
        ])
    }
}
