//
//  LoginInputView.swift
//  QRIZ
//
//  Created by KSH on 12/20/24.
//

import UIKit
import Combine

final class LoginInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let clearButtonSize: CGFloat = 20.0
        static let showPwButtonSize: CGFloat = 24.0
        static let textFieldHeight: CGFloat = 54.0
        static let loginButtonHeight: CGFloat = 48.0
    }
    
    private enum Attributes {
        static let idPlaceholder = "아이디를 입력해 주세요"
        static let passwordPlaceholder = "비밀번호를 입력해 주세요"
        static let loginButtonTitle = "로그인"
        static let xmarkImage = "xmark.circle.fill"
    }
    
    // MARK: - Properties
    
    private let loginButtonTapSubject = PassthroughSubject<Void, Never>()
    
    var idTextPublisher: AnyPublisher<String, Never> {
        idTextField.textPublisher
    }
    
    var passwordTextPublisher: AnyPublisher<String, Never> {
        passwordTextField.textPublisher
    }
    
    var loginButtonTapPublisher: AnyPublisher<Void, Never> {
        loginButtonTapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var idTextField = CustomTextField(
        placeholder: Attributes.idPlaceholder,
        rightView: wrapButtonInPaddingView(button: clearButton)
    )
    
    private lazy var passwordTextField = CustomTextField(
        placeholder: Attributes.passwordPlaceholder,
        isSecure: true,
        rightView: wrapButtonInPaddingView(button: passwordToggleButton)
    )
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Attributes.xmarkImage), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: Metric.clearButtonSize, height: Metric.clearButtonSize)
        
        button.addAction(UIAction { [weak self] _ in
            self?.clearButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton()
        button.setImage(.eyeSlash, for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: Metric.showPwButtonSize, height: Metric.showPwButtonSize)
        
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.showPwButtonTapped(button: button)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Attributes.loginButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.coolNeutral500, for: .normal)
        button.backgroundColor = .coolNeutral200
        button.layer.cornerRadius = 8
        button.addAction(UIAction { [weak self] _ in
            self?.loginButtonTapSubject.send()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [idTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.setCustomSpacing(20, after: passwordTextField)
        return stackView
    }()
    
    // MARK: - Initialize
    
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
    
    func setLoginButtonEnabled(_ isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
        loginButton.backgroundColor = isEnabled ? .customBlue500 : .coolNeutral200
        loginButton.setTitleColor(isEnabled ? .white : .coolNeutral500, for: .normal)
    }
    
    private func wrapButtonInPaddingView(
        button: UIButton,
        paddingWidth: CGFloat = 40,
        paddingHeight: CGFloat = Metric.textFieldHeight
    ) -> UIView {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: paddingHeight))
        button.center = CGPoint(x: paddingView.frame.width / 2, y: paddingView.frame.height / 2)
        paddingView.addSubview(button)
        return paddingView
    }
    
    // MARK: - Actions
    
    private func clearButtonTapped() {
        idTextField.text = ""
        NotificationCenter.default.post(
            name: UITextField.textDidChangeNotification,
            object: idTextField
        )
    }
    
    private func showPwButtonTapped(button: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? UIImage.eye : UIImage.eyeSlash
        button.setImage(imageName, for: .normal)
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
