//
//  IdInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit

final class IdInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let idInputViewTopOffset: CGFloat = 32.0
        static let signupFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "아이디를 입력해주세요!"
        static let headerDescription: String = "사용할 아이디를 입력해주세요."
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.5
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    let idInputView = IdInputView()
    let signupFooterView = SignupFooterView()
    
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
        signupHeaderView.configure(title: title, progress: progressValue)
        signupFooterView.configure(buttonTitle: buttonTitle)
    }
}

// MARK: - Layout Setup

extension IdInputMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            idInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        idInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            idInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.idInputViewTopOffset),
            idInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            idInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signupFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signupFooterViewBottomOffset)
        ])
    }
}
