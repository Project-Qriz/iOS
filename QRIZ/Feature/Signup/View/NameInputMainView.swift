//
//  NameInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

final class NameInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let nameInputViewTopOffset: CGFloat = 32.0
        static let signupFooterViewTopOffset: CGFloat = 129.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "이름을 입력해주세요!"
        static let headerDescription: String = "가입을 위해 실명을 입력해주세요."
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.25
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    private let nameInputView = NameInputView()
    private let signupFooterView = SignupFooterView()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
        signupHeaderView.configure(
            title: Attributes.headerTitle,
            description: Attributes.headerDescription,
            progress: Attributes.progressValue
        )
        signupFooterView.configure(buttonTitle: Attributes.footerTitle)
    }
}

// MARK: - Layout Setup

extension NameInputMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            nameInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        nameInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            nameInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.nameInputViewTopOffset),
            nameInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            nameInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),

            signupFooterView.topAnchor.constraint(equalTo: nameInputView.bottomAnchor, constant: Metric.signupFooterViewTopOffset),
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
        ])
    }
}
