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
    
    enum textFieldType {
        case email
        case code
    }
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        static let sendButtonWidthMultiplier: CGFloat = 80 / 48
    }
    
    // MARK: - Enums
    
    private enum Attributes {
        static let emailPlaceholder = "qriz@gmail.com"
        static let codePlaceholder = "인증번호 입력"
        
        static let sendButtonTitle = "전송"
        static let resendButtonTitle = "재전송"
        static let confirmButtonTitle = "확인"
        
        static let emailErrorText = "올바른 이메일 형식으로 입력해주세요."
        static let codeErrorText = "인증번호가 올바르지 않습니다."
        static let expiredErrorText = "인증 시간이 만료되었어요. 재전송을 눌러주세요."
        
        static let emailVerificationSentMessage = "인증번호가 이메일로 전송됐습니다!"
        static let codeVerificationSuccessMessage = "인증 완료되었습니다."
        
        static let timerDuration = 180
    }
    
    // MARK: - Properties
    
    private let sendButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

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
    
    private lazy var emailTextField: CustomTextField = {
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
    
    private lazy var codeTextField: CustomTextField = {
        let textField = CustomTextField(
            placeholder: Attributes.codePlaceholder,
            rightViewType: .clearButtonWithTimer
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
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    private func observe() {
        codeTextField.textPublisher
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.inputErrorLabel.isHidden = true
                self?.codeTextField.layer.borderColor = UIColor.coolNeutral600.cgColor
            }
            .store(in: &cancellables)
    }
    
    func updateSendButton(isValid: Bool) {
        setButtonState(
            button: sendButton,
            isEnabled: isValid,
            enabledTitleColor: .coolNeutral800,
            disabledTitleColor: .coolNeutral300,
            enabledBorderColor: UIColor.customBlue200.cgColor,
            disabledBorderColor: UIColor.customBlue200.cgColor
        )
    }
    
    func updateConfirmButton(isValid: Bool) {
        setButtonState(
            button: confirmButton,
            isEnabled: isValid,
            enabledTitleColor: .customBlue500,
            disabledTitleColor: .coolNeutral300,
            enabledBorderColor: UIColor.customBlue500.cgColor,
            disabledBorderColor: UIColor.coolNeutral200.cgColor
        )
    }
    
    func updateErrorState(for type: textFieldType, isValid: Bool) {
        let textField: UITextField
        let errorText: String
        
        switch type {
        case .email:
            textField = emailTextField
            errorText = Attributes.emailErrorText
        case .code:
            textField = codeTextField
            errorText = Attributes.codeErrorText
        }
        
        if isValid {
            hideMessage()
            textField.layer.borderColor = UIColor.coolNeutral600.cgColor
        } else {
            showErrorMessage(errorText)
            textField.layer.borderColor = UIColor.customRed500.cgColor
        }
    }
    
    func handleEmailVerificationSuccess() {
        codeHStackView.isHidden = false
        emailTextField.isEnabled = false
        emailTextField.updateRightView(.checkmark)
        sendButton.setTitle(Attributes.resendButtonTitle, for: .normal)
        showMessage(Attributes.emailVerificationSentMessage, textColor: .customMint800)
    }
    
    func handleCodeVerificationSuccess() {
        setTextFieldState(codeTextField, enabled: false, borderColor: UIColor.coolNeutral200.cgColor)
        setButtonState(
            button: confirmButton,
            isEnabled: false,
            enabledTitleColor: .customBlue500,
            disabledTitleColor: .coolNeutral300,
            enabledBorderColor: UIColor.customBlue200.cgColor,
            disabledBorderColor: UIColor.coolNeutral200.cgColor
        )
        setButtonState(
            button: sendButton,
            isEnabled: false,
            enabledTitleColor: .coolNeutral800,
            disabledTitleColor: .coolNeutral300,
            enabledBorderColor: UIColor.customBlue200.cgColor,
            disabledBorderColor: UIColor.coolNeutral200.cgColor
        )
        codeTextField.updateRightView(.checkmark)
        showSuccessMessage(Attributes.codeVerificationSuccessMessage)
    }
    
    func handleCodeVerificationFailure() {
        codeTextField.layer.borderColor = UIColor.customRed500.cgColor
        showErrorMessage(Attributes.codeErrorText)
    }
    
    func handleTimerExpired() {
        setTextFieldState(
            codeTextField,
            enabled: false,
            borderColor: UIColor.coolNeutral100.cgColor,
            backgroundColor: .coolNeutral100
        )
        setButtonState(
            button: confirmButton,
            isEnabled: false,
            enabledTitleColor: .customBlue500,
            disabledTitleColor: .coolNeutral300,
            enabledBorderColor: UIColor.customBlue200.cgColor,
            disabledBorderColor: UIColor.customBlue200.cgColor
        )
        
        showErrorMessage(Attributes.expiredErrorText)
    }
    
    func updateTimerLabel(_ remainingTime: Int) {
        codeTextField.updateTimerLabel(remainingTime)
    }
    
    /// 버튼 상태 관리 메서드
    private func setButtonState(
        button: UIButton,
        isEnabled: Bool,
        enabledTitleColor: UIColor,
        disabledTitleColor: UIColor,
        enabledBorderColor: CGColor,
        disabledBorderColor: CGColor
    ) {
        button.isEnabled = isEnabled
        button.setTitleColor(isEnabled ? enabledTitleColor : disabledTitleColor, for: .normal)
        button.layer.borderColor = isEnabled ? enabledBorderColor : disabledBorderColor
    }
    
    /// 텍스트필드 상태 관리 메서드
    private func setTextFieldState(
        _ textField: UITextField,
        enabled: Bool,
        borderColor: CGColor? = nil,
        backgroundColor: UIColor = .white
    ) {
        textField.isEnabled = enabled
        textField.backgroundColor = backgroundColor
        if let borderColor = borderColor {
            textField.layer.borderColor = borderColor
        }
    }
    
    private func showErrorMessage(_ text: String) {
        showMessage(text, textColor: .customRed500)
    }
    
    private func showSuccessMessage(_ text: String) {
        showMessage(text, textColor: .customMint800)
    }
    
    private func showMessage(_ text: String, textColor: UIColor) {
        inputErrorLabel.text = text
        inputErrorLabel.textColor = textColor
        inputErrorLabel.isHidden = false
    }
    
    private func hideMessage() {
        inputErrorLabel.text = nil
        inputErrorLabel.isHidden = true
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
