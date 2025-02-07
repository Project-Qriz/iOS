//
//  EmailInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 2/7/25.
//

import UIKit

final class EmailInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let singleInputViewTopOffset: CGFloat = 32.0
        static let signupFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "본인확인을 위해\n이메일을 인증해 주세요."
        static let progressValue: Float = 0.25
        static let footerTitle: String = "다음"
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    let findPasswordInputView = FindPasswordInputView()
    let signupFooterView = SignupFooterView()
    
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
        signupHeaderView.configure(
            title: UILabel.setLineSpacing(8, text: Attributes.headerTitle),
            progress: Attributes.progressValue
        )
        signupFooterView.configure(buttonTitle: Attributes.footerTitle)
    }
}

// MARK: - Layout Setup

extension EmailInputMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            findPasswordInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        findPasswordInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            findPasswordInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.singleInputViewTopOffset),
            findPasswordInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            findPasswordInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signupFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signupFooterViewBottomOffset)
        ])
    }
}

