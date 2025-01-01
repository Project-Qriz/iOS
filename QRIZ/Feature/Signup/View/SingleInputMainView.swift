//
//  SingleInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

final class SingleInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let singleInputViewTopOffset: CGFloat = 32.0
        static let signupFooterViewTopOffset: CGFloat = 129.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    private let singleInputView = SingleInputView()
    private let signupFooterView = SignupFooterView()
    
    // MARK: - initialize
    
    init(
        title: String,
        description: String,
        progressValue: Float,
        buttonTitle: String,
        inputPlaceholder: String,
        inputErrorText: String
    ) {
        super.init(frame: .zero)
        setupUI(
            title: title,
            description: description,
            progressValue: progressValue,
            buttonTitle: buttonTitle,
            inputPlaceholder: inputPlaceholder,
            inputErrorText: inputErrorText
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
        buttonTitle: String,
        inputPlaceholder: String,
        inputErrorText: String
    ) {
        self.backgroundColor = .white
        signupHeaderView.configure(title: title, description: description, progress: progressValue)
        singleInputView.configure(placeholder: inputPlaceholder, errorText: inputErrorText)
        signupFooterView.configure(buttonTitle: buttonTitle)
    }
}

// MARK: - Layout Setup

extension SingleInputMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            singleInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        singleInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            singleInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.singleInputViewTopOffset),
            singleInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            singleInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signupFooterView.topAnchor.constraint(equalTo: singleInputView.bottomAnchor, constant: Metric.signupFooterViewTopOffset),
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
        ])
    }
}
