//
//  VerificationCodeMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit

final class VerificationCodeMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let singleInputViewTopOffset: CGFloat = 24.0
        static let signupFooterViewTopOffset: CGFloat = 20.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "이메일로 받은\n인증번호를 입력해주세요"
        static let headerDescription: String = "이메일을 받지 못하셨다면 다시 보내기를 클릭해주세요."
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.5
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    private let verificationCodeInputView = VerificationCodeInputView()
    private let signupFooterView = SignupFooterView()
    
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

extension VerificationCodeMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            verificationCodeInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        verificationCodeInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            verificationCodeInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.singleInputViewTopOffset),
            verificationCodeInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            verificationCodeInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signupFooterView.topAnchor.constraint(equalTo: verificationCodeInputView.bottomAnchor, constant: Metric.signupFooterViewTopOffset),
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
        ])
    }
}
