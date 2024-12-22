//
//  LoginInputView.swift
//  QRIZ
//
//  Created by KSH on 12/20/24.
//

import UIKit

final class LoginInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 60.0
        static let loginButtonHeight: CGFloat = 46.0
    }
    
    private enum Attributes {
        static let idPlaceholder = "아이디를 입력해 주세요"
        static let passwordPlaceholder = "비밀번호를 입력해 주세요"
        static let loginButtonTitle = "로그인"
    }

    // MARK: - UI
    
    private lazy var idTextField: UITextField = {
        return buildTextField(placeholder: Attributes.idPlaceholder)
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = buildTextField(placeholder: Attributes.passwordPlaceholder, isSecure: true)
        textField.rightViewMode = .whileEditing
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Attributes.loginButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold) // 폰트 수정 bold/16
        button.setTitleColor(.coolNeutral500, for: .normal)
        button.backgroundColor = .coolNeutral200
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [idTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.setCustomSpacing(12, after: passwordTextField)
        return stackView
    }()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLayout()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .white
    }
    
    private func buildTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.coolNeutral300,
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold) // 폰트 수정 semibold/16
            ]
        )
        textField.backgroundColor = .customBlue100
        textField.layer.cornerRadius = 8
        
        // leftPaddingView
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: Metric.textFieldHeight))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.isSecureTextEntry = isSecure
        return textField
    }
}

// MARK: - Layout Setup

extension LoginInputView {
    private func addSubviews() {
        addSubview(stackView)
    }
    
    private func setupLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            idTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            passwordTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            loginButton.heightAnchor.constraint(equalToConstant: Metric.loginButtonHeight)
        ])
    }
}
