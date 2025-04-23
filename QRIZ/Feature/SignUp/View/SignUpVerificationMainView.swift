//
//  SignUpVerificationMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 2/7/25.
//

import UIKit

final class SignUpVerificationMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let verificationInputViewTopOffset: CGFloat = 20.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "본인확인을 위해\n이메일을 인증해 주세요."
        static let progressValue: Float = 0.25
        static let footerTitle: String = "다음"
    }
    
    // MARK: - Properties
    
    private let signUpHeaderView = SignUpHeaderView()
    let verificationInputView = VerificationInputView()
    let signUpFooterView = SignUpFooterView()
    
    // MARK: - initialize
    
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
        signUpHeaderView.configure(
            title: Attributes.headerTitle,
            progress: Attributes.progressValue
        )
        signUpFooterView.configure(buttonTitle: Attributes.footerTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension SignUpVerificationMainView {
    private func addSubviews() {
        [
            signUpHeaderView,
            verificationInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signUpHeaderView.translatesAutoresizingMaskIntoConstraints = false
        verificationInputView.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signUpHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signUpHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            verificationInputView.topAnchor.constraint(equalTo: signUpHeaderView.bottomAnchor, constant: Metric.verificationInputViewTopOffset),
            verificationInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            verificationInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signUpFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signUpFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signUpFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signUpFooterViewBottomOffset)
        ])
    }
}

