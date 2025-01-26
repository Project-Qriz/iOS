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
        static let errorLabelText: String = "올바른 이메일 형식으로 입력해주세요."
        static let toastMessage: String = "인증번호가 이메일로 전송됐습니다!"
    }
    
    // MARK: - Properties
    
    private let buttonTappedSubject = PassthroughSubject<Void, Never>()

    var buttonTappedPublisher: AnyPublisher<Void, Never> {
        buttonTappedSubject.eraseToAnyPublisher()
    }
    
    var emailTextChangedPublisher: AnyPublisher<String, Never> {
        emailTextField.textPublisher
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
            self?.buttonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var emailHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            sendButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.errorLabelText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        label.isHidden = true
        return label
    }()
    
    private lazy var codeTextField: UITextField = {
        let textField = CustomTextField(
            placeholder: Attributes.codePlaceholder,
            rightViewType: .clearButton
        )
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
            self?.buttonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var codeHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            codeTextField,
            confirmButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.isHidden = true
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
    
    func updateErrorState(isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        emailTextField.layer.borderColor = isValid
        ? UIColor.coolNeutral600.cgColor
        : UIColor.customRed500.cgColor
    }
    
    func handleVerificationSuccess() {
        emailTextField.isEnabled = false
        codeHStackView.isHidden = false
        sendButton.setTitle(Attributes.resendButtonTitle, for: .normal)
        self.showToast(message: Attributes.toastMessage)
    }
}

// MARK: - Layout Setup

extension FindPasswordInputView {
    private func addSubviews() {
        [
            emailHStackView,
            codeHStackView,
            inputErrorLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        emailHStackView.translatesAutoresizingMaskIntoConstraints = false
        codeHStackView.translatesAutoresizingMaskIntoConstraints = false
        inputErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailHStackView.topAnchor.constraint(equalTo: topAnchor),
            emailHStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emailHStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emailHStackView.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            sendButton.widthAnchor.constraint(
                equalTo: emailHStackView.heightAnchor,
                multiplier: Metric.sendButtonWidthMultiplier
            ),
            
            inputErrorLabel.topAnchor.constraint(
                equalTo: emailTextField.bottomAnchor,
                constant: Metric.inputErrorLabelTopOffset
            ),
            inputErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            codeHStackView.topAnchor.constraint(
                equalTo: emailHStackView.bottomAnchor,
                constant: Metric.codeHStackViewTopOffset
            ),
            codeHStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            codeHStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            codeHStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            codeHStackView.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
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

