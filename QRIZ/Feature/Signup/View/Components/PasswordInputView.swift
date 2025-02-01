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
        static let requirementVStackViewTopOffset: CGFloat = 4.0
        static let confirmPasswordTextFieldTopOffset: CGFloat = 16.0
        static let checkmarkSize: CGFloat = 16.0
    }
    
    private enum Attributes {
        static let passwordPlaceholder: String = "새 비밀번호 입력"
        static let confirmPasswordPlaceholder: String = "새 비밀번호 재입력"
        
        static let characterRequirementText: String = "대문자/소문자/숫자/특수문자 포함"
        static let lengthRequirementText: String = "8자 이상 16자 이하 입력 (공백 제외)"
        
        static let checkmark: String = "checkmark"
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
        isSecure: true,
        rightViewType: .passwordToggle
    )
    private let characterCheckImageView = buildCheckmarkImageView()
    private let characterRequirementLabel = buildRequirementLabel(
        text: Attributes.characterRequirementText
    )
    
    private let lengthCheckImageView = buildCheckmarkImageView()
    private let lengthRequirementLabel = buildRequirementLabel(
        text: Attributes.lengthRequirementText
    )
    
    private lazy var characterRequirementHStack = PasswordInputView.buildRequirementHStack(
        icon: characterCheckImageView,
        label: characterRequirementLabel
    )
    private lazy var lengthRequirementHStack = PasswordInputView.buildRequirementHStack(
        icon: lengthCheckImageView,
        label: lengthRequirementLabel
    )
    
    private let confirmPasswordTextField = CustomTextField(
        placeholder: Attributes.confirmPasswordPlaceholder,
        isSecure: true,
        rightViewType: .passwordToggle
    )
    
    private lazy var requirementVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            characterRequirementHStack,
            lengthRequirementHStack,
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
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
    
    private static func buildRequirementLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }
    
    private static func buildCheckmarkImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: Attributes.checkmark))
        imageView.tintColor = .coolNeutral500
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func buildRequirementHStack(icon: UIImageView, label: UILabel) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }
    
    func updatePasswordErrorState(_ isValid: Bool) {
        characterRequirementLabel.isHidden = isValid
        passwordTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.customRed500.cgColor
    }
    
    func updateconfirmErrorState(_ isValid: Bool) {
        lengthRequirementLabel.isHidden = isValid
        confirmPasswordTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.customRed500.cgColor
    }
}

// MARK: - Layout Setup

extension PasswordInputView {
    private func addSubviews() {
        [
            passwordTextField,
            requirementVStackView,
            confirmPasswordTextField
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        requirementVStackView.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: topAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            requirementVStackView.topAnchor.constraint(
                equalTo: passwordTextField.bottomAnchor,
                constant: Metric.requirementVStackViewTopOffset
            ),
            requirementVStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            requirementVStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            confirmPasswordTextField.topAnchor.constraint(
                equalTo: requirementVStackView.bottomAnchor,
                constant: Metric.confirmPasswordTextFieldTopOffset
            ),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            confirmPasswordTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            characterCheckImageView.widthAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            characterCheckImageView.heightAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            
            lengthCheckImageView.widthAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            lengthCheckImageView.heightAnchor.constraint(equalToConstant: Metric.checkmarkSize),
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
