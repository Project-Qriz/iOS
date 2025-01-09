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
        static let signupFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "비밀번호를 입력해주세요!"
        static let headerDescription: String = "사용할 비밀번호를 입력해주세요."
        static let footerTitle: String = "가입하기"
        static let progressValue: Float = 1.0
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    private let passwordInputView = PasswordInputView()
    let signupFooterView = SignupFooterView()
    
    // MARK: - initialize
    
    init() {
        super.init(frame: .zero)
        setupUI(
            title: Attributes.headerTitle,
            description: Attributes.headerDescription,
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
        description: String,
        progressValue: Float,
        buttonTitle: String
    ) {
        self.backgroundColor = .white
        signupHeaderView.configure(title: title, description: description, progress: progressValue)
        signupFooterView.configure(buttonTitle: buttonTitle)
    }
}

// MARK: - Layout Setup

extension PasswordInputMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            passwordInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        passwordInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            passwordInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.passwordInputViewTopOffset),
            passwordInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            passwordInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signupFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signupFooterViewBottomOffset)
        ])
    }
}
