//
//  FindPasswordVerificationMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/26/25.
//

import UIKit

final class FindPasswordVerificationMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let headerViewTopOffset: CGFloat = 40.0
        static let inputViewTopOffset: CGFloat = 20.0
        static let horizontalMargin: CGFloat = 18.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
    }
    
    private enum Attributes {
        static let buttonTitle: String = "재설정 하기"
    }
    
    // MARK: - Properties
    
    private let findAccountHeaderView = FindAccountHeaderView()
    let verificationInputView = VerificationInputView()
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
            title: FindAccountType.findPassword.headerTitle,
            description: UILabel.setLineSpacing(8, text: FindAccountType.findPassword.headerDescription)
        )
        signUpFooterView.configure(buttonTitle: Attributes.buttonTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension FindPasswordVerificationMainView {
    private func addSubviews() {
        [
            findAccountHeaderView,
            verificationInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        findAccountHeaderView.translatesAutoresizingMaskIntoConstraints = false
        verificationInputView.translatesAutoresizingMaskIntoConstraints = false
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
            
            verificationInputView.topAnchor.constraint(
                equalTo: findAccountHeaderView.bottomAnchor,
                constant: Metric.inputViewTopOffset
            ),
            verificationInputView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            verificationInputView.trailingAnchor.constraint(
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

