//
//  VerificationCodeInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit
import Combine

final class VerificationCodeInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        static let inputErrorLabelTopOffset: CGFloat = 8.0
        static let resendCodeLabelTopOffset: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let placeholder: String = "인증번호 6자리 입력"
        static let inputErrorText: String = "인증번호가 다르게 입력되었어요"
    }
    
    // MARK: - Properties
    
    private var timer: Timer?
    private var remainingSeconds: Int = 180
    
    // MARK: - UI
    
    private lazy var codeTextField: UITextField = CustomTextField(
        placeholder: Attributes.placeholder,
        rightView: wrapLabelInPaddingView(label: timerLabel),
        rightViewMode: .always
    )
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral300
        label.text = "03:00"
        return label
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.inputErrorText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        return label
    }()
    
    private lazy var resendCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .coolNeutral500
        label.isUserInteractionEnabled = true
        
        let text = "인증번호 다시 받기"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: text.count)
        )
        label.attributedText = attributedString
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendCodeTapped)))
        return label
    }()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
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
    }
    
    private func wrapLabelInPaddingView(
        label: UILabel,
        horizontalPadding: CGFloat = 6,
        verticalPadding: CGFloat = 0,
        height: CGFloat = Metric.textFieldHeight
    ) -> UIView {
        let paddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: label.intrinsicContentSize.width + horizontalPadding * 2,
            height: height
        ))
        
        label.frame = CGRect(
            x: horizontalPadding,
            y: (height - label.intrinsicContentSize.height) / 2,
            width: label.intrinsicContentSize.width,
            height: label.intrinsicContentSize.height
        )
        
        paddingView.addSubview(label)
        return paddingView
    }
    
    // MARK: - Actions
    
    @objc private func resendCodeTapped() {
        print("인증번호 다시 받기 클릭")
    }
}

// MARK: - Layout Setup

extension VerificationCodeInputView {
    private func addSubviews() {
        [
            codeTextField,
            inputErrorLabel,
            resendCodeLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        codeTextField.translatesAutoresizingMaskIntoConstraints = false
        inputErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        resendCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            codeTextField.topAnchor.constraint(equalTo: topAnchor),
            codeTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            codeTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            codeTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            inputErrorLabel.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: Metric.inputErrorLabelTopOffset),
            inputErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            resendCodeLabel.topAnchor.constraint(equalTo: inputErrorLabel.bottomAnchor, constant: Metric.resendCodeLabelTopOffset),
            resendCodeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            resendCodeLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
