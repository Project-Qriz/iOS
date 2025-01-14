//
//  PasswordInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/4/25.
//

import UIKit
import Combine

final class PasswordInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        
    }
    
    private enum Attributes {
        static let passwordPlaceholder: String = "영문, 숫자, 특수 문자를 조합하여 8~16자로 입력해 주세요."
        static let confirmPasswordPlaceholder: String = "비밀번호 재확인"
        static let passwordErrorLabelText: String = "영문과 숫자를 조합하여 8~10자로 입력해주세요."
        static let confirmPasswordErrorLabelText: String = "비밀번호가 일치하지 않습니다."
    }
    
    // MARK: - Properties
    
    var passwordTextChangedPublisher: AnyPublisher<String, Never> {
        passwordTextField.textPublisher
    }
    
    var confirmTextChangedPublisher: AnyPublisher<String, Never> {
        confirmPasswordTextField.textPublisher
    }
    
    // MARK: - UI
    
    private let passwordTextField = CustomTextField(
        placeholder: Attributes.passwordPlaceholder,
        isSecure: true
    )
    private lazy var passwordErrorLabel = buildErrorLabel(text: Attributes.passwordErrorLabelText)
    private let confirmPasswordTextField = CustomTextField(
        placeholder: Attributes.confirmPasswordPlaceholder,
        isSecure: true
    )
    private lazy var confirmPasswordErrorLabel = buildErrorLabel(text: Attributes.confirmPasswordErrorLabelText)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            passwordTextField,
            passwordErrorLabel,
            confirmPasswordTextField,
            confirmPasswordErrorLabel
            
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        setupUI()
        setupDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    private func setupDelegate() {
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func buildErrorLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        label.isHidden = true
        return label
    }
    
    func updatePasswordErrorState(_ isValid: Bool) {
        passwordErrorLabel.isHidden = isValid
        passwordTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.customRed500.cgColor
    }
    
    func updateconfirmErrorState(_ isValid: Bool) {
        confirmPasswordErrorLabel.isHidden = isValid
        confirmPasswordTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.customRed500.cgColor
    }
}

// MARK: - Layout Setup

extension PasswordInputView {
    private func addSubviews() {
        [
            stackView,
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
        ])
    }
}

// MARK: - UITextFieldDelegate

extension PasswordInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
