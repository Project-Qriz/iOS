//
//  FindPasswordInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/26/25.
//

import UIKit
import Combine

final class FindPasswordInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        static let inputErrorLabelTopOffset: CGFloat = 4.0
        static let sendButtonWidthMultiplier: CGFloat = 80 / 48
        static let codeHStackViewTopOffset: CGFloat = 16.0
    }
    
    // MARK: - Enums
    
    private enum Attributes {
        static let emailPlaceholder: String = "qriz@gmail.com"
        static let codePlaceholder: String = "인증번호 입력"
        static let sendButtonTitle: String = "전송"
        static let resendButtonTitle: String = "재전송"
        static let confirmButtonTitle: String = "확인"
        static let emailErrorText: String = "올바른 이메일 형식으로 입력해주세요."
        static let codeErrorText: String = "인증번호가 올바르지 않습니다."
        static let toastMessage: String = "인증번호가 이메일로 전송됐습니다!"
    }
    
    // MARK: - Properties
    
    private let sendButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()

    var sendButtonTappedPublisher: AnyPublisher<Void, Never> {
        sendButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var confirmButtonPublisher: AnyPublisher<Void, Never> {
        confirmButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var emailTextChangedPublisher: AnyPublisher<String, Never> {
        emailTextField.textPublisher
    }
    
    var codeTextChangedPublisher: AnyPublisher<String, Never> {
        codeTextField.textPublisher
    }
    
    // MARK: - UI
    
    private lazy var emailTextField: UITextField = {
        let textField = CustomTextField(
            placeholder: Attributes.emailPlaceholder,
            rightViewType: .clearButton
        )
        textField.delegate = self
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(Attributes.sendButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.coolNeutral300, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.customBlue200.cgColor
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addAction(UIAction { [weak self] _ in
            self?.sendButtonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var emailHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            sendButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var codeTextField: UITextField = {
        let textField = CustomTextField(
            placeholder: Attributes.codePlaceholder,
            rightViewType: .clearButton
        )
        textField.keyboardType = .numberPad
        textField.delegate = self
        return textField
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(Attributes.confirmButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.coolNeutral300, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.customBlue200.cgColor
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addAction(UIAction { [weak self] _ in
            self?.confirmButtonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var codeHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            codeTextField,
            confirmButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.emailErrorText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        label.isHidden = true
        return label
    }()
    
    private lazy var mainVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailHStackView,
            codeHStackView,
            inputErrorLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
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
    
    func updateSendButton(isValid: Bool) {
        sendButton.isEnabled = isValid
        sendButton.setTitleColor(isValid ? .coolNeutral800 : .coolNeutral300, for: .normal)
    }
    
    func updateConfirmButton(isValid: Bool) {
        confirmButton.isEnabled = isValid
        confirmButton.setTitleColor(isValid ? .coolNeutral800 : .coolNeutral300, for: .normal)
    }
    
    func updateErrorState(isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        emailTextField.layer.borderColor = isValid
        ? UIColor.coolNeutral600.cgColor
        : UIColor.customRed500.cgColor
    }
    
    func handleEmailVerificationSuccess() {
        emailTextField.isEnabled = false
        codeHStackView.isHidden = false
        sendButton.setTitle(Attributes.resendButtonTitle, for: .normal)
        inputErrorLabel.text = Attributes.codeErrorText
        self.showToast(message: Attributes.toastMessage)
    }
    
    func handleCodeVerificationSuccess() {
        codeTextField.isEnabled = false
        updateSendButton(isValid: false)
        updateConfirmButton(isValid: false)
    }
}

// MARK: - Layout Setup

extension FindPasswordInputView {
    private func addSubviews() {
        [
            mainVStackView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        mainVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainVStackView.topAnchor.constraint(equalTo: topAnchor),
            mainVStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainVStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emailHStackView.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            codeHStackView.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            sendButton.widthAnchor.constraint(
                equalTo: emailHStackView.heightAnchor,
                multiplier: Metric.sendButtonWidthMultiplier
            ),
            
            confirmButton.widthAnchor.constraint(
                equalTo: codeHStackView.heightAnchor,
                multiplier: Metric.sendButtonWidthMultiplier
            ),
        ])
    }
}

// MARK: - UITextFieldDelegate

extension FindPasswordInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
