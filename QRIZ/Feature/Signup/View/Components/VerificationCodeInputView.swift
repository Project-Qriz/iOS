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
        static let timerLabelText: String = "03:00"
        static let inputErrorText: String = "인증번호가 다르게 입력되었어요"
        static let resendCodeLabelText: String = "인증번호 다시 받기"
    }
    
    // MARK: - Properties
    
    private let resendCodeSubject = PassthroughSubject<Void, Never>()
    
    var resendCodePublisher: AnyPublisher<Void, Never> {
        resendCodeSubject.eraseToAnyPublisher()
    }
    
    var textChangedPublisher: AnyPublisher<String, Never> {
        codeTextField.textPublisher
    }
    
    // MARK: - UI
    
    private lazy var codeTextField: UITextField = {
        let textField = CustomTextField(
            placeholder: Attributes.placeholder,
            isSecure: false,
            rightViewType: .custom(wrapLabelInPaddingView(label: timerLabel))
        )
        textField.keyboardType = .numberPad
        textField.delegate = self
        return  textField
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral300
        label.text = Attributes.timerLabelText
        return label
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.inputErrorText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        label.isHidden = true
        return label
    }()
    
    private lazy var resendCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .coolNeutral500
        label.isUserInteractionEnabled = true
        
        let text = Attributes.resendCodeLabelText
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
    
    func updateErrorState(_ hasError: Bool) {
        inputErrorLabel.isHidden = !hasError
        codeTextField.layer.borderColor = hasError ? UIColor.customRed500.cgColor : UIColor.clear.cgColor
    }
    
    func updateTimerLabel(_ remainingTime: Int) {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
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
            width: label.intrinsicContentSize.width + 5,
            height: label.intrinsicContentSize.height
        )
        
        paddingView.addSubview(label)
        return paddingView
    }
    
    // MARK: - Actions
    
    @objc private func resendCodeTapped() {
        resendCodeSubject.send()
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

// MARK: - UITextFieldDelegate

extension VerificationCodeInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
