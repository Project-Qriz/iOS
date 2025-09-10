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
        static let confirmCheckmarkTrailingOffset: CGFloat = -40.0
        static let checkmarkSize: CGFloat = 22.0
        static let inputErrorLabelTopOffset: CGFloat = 8.0
    }
    
    private enum Attributes {
        static let passwordPlaceholder: String = "새 비밀번호 입력"
        static let confirmPasswordPlaceholder: String = "새 비밀번호 재입력"
        
        static let characterRequirementText: String = "대문자/소문자/숫자/특수문자 포함"
        static let lengthRequirementText: String = "8자 이상 16자 이하 입력 (공백 제외)"
        
        static let checkmark: String = "checkmark"
        static let errorText: String = "비밀번호가 다릅니다. 동일한 비밀번호를 입력해 주세요."
    }
    
    // MARK: - Properties
    
    private var isCharacterValid: Bool = false
    private var isLengthValid: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private let confirmPasswordTextField = CustomTextField(
        placeholder: Attributes.confirmPasswordPlaceholder,
        isSecure: true,
        rightViewType: .passwordToggle
    )
    
    private let confirmCheckmark: UIImageView = {
        let imageView = buildCheckmarkImageView(tintColor: UIColor.customBlue500)
        imageView.isHidden = true
        return imageView
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.errorText
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .customRed500
        label.isHidden = true
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
    
    func focusInitialField() {
        DispatchQueue.main.async { [weak self] in
            self?.passwordTextField.becomeFirstResponder()
        }
    }
    
    func updateCharacterRequirementUI(_ isValid: Bool) {
        isCharacterValid = isValid
        
        let color: UIColor = isValid ? .customMint800 : .coolNeutral500
        characterCheckImageView.tintColor = color
        characterRequirementLabel.textColor = color
        updatePasswordTextFieldBorderColor()
    }
    
    func updateLengthRequirementUI(_ isValid: Bool) {
        isLengthValid = isValid
        
        let color: UIColor = isValid ? .customMint800 : .coolNeutral500
        lengthCheckImageView.tintColor = color
        lengthRequirementLabel.textColor = color
        updatePasswordTextFieldBorderColor()
    }
    
    func updateConfirmPasswordUI(_ isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        confirmCheckmark.isHidden = !isValid
        
        let borderColor = isValid ? UIColor.customMint800.cgColor : UIColor.customRed500.cgColor
        confirmPasswordTextField.layer.borderColor = borderColor
    }
    
    private func updatePasswordTextFieldBorderColor() {
        if isCharacterValid && isLengthValid {
            passwordTextField.layer.borderColor = UIColor.customMint800.cgColor
        } else {
            passwordTextField.layer.borderColor = UIColor.coolNeutral600.cgColor
        }
    }
    
    private static func buildRequirementLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }
    
    private static func buildCheckmarkImageView(tintColor: UIColor? = .coolNeutral500) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: Attributes.checkmark))
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        imageView.preferredSymbolConfiguration = config
        imageView.tintColor = tintColor
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
}

// MARK: - Layout Setup

extension PasswordInputView {
    private func addSubviews() {
        [
            passwordTextField,
            requirementVStackView,
            confirmPasswordTextField,
            inputErrorLabel
        ].forEach(addSubview(_:))
        
        confirmPasswordTextField.addSubview(confirmCheckmark)
    }
    
    private func setupConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        requirementVStackView.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmCheckmark.translatesAutoresizingMaskIntoConstraints = false
        inputErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            confirmCheckmark.centerYAnchor.constraint(equalTo: confirmPasswordTextField.centerYAnchor),
            confirmCheckmark.trailingAnchor.constraint(
                equalTo: confirmPasswordTextField.trailingAnchor,
                constant: Metric.confirmCheckmarkTrailingOffset
            ),
            confirmCheckmark.widthAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            confirmCheckmark.heightAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            
            inputErrorLabel.topAnchor.constraint(
                equalTo: confirmPasswordTextField.bottomAnchor,
                constant: Metric.inputErrorLabelTopOffset
            ),
            inputErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputErrorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
