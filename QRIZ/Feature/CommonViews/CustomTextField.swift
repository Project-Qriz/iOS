//
//  CustomTextField.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

/// 로그인, 회원가입 등에서 사용하는 CustomTextField입니다.
final class CustomTextField: UITextField {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let xmarkImage = "xmark.circle.fill"
    }
    
    enum RightViewType {
        case none
        case clearButton
        case passwordToggle
        case timerLabel
        case clearButtonWithTimer
        case custom(UIView?)
    }
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 48)
        return view
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Attributes.xmarkImage), for: .normal)
        button.tintColor = .coolNeutral300
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.text = ""
            NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.eyeSlash, for: .normal)
        button.tintColor = .coolNeutral700
        button.addAction(
            UIAction { [weak self] _ in
                guard let self = self else { return }
                self.isSecureTextEntry.toggle()
                let newImage = self.isSecureTextEntry ? UIImage.eyeSlash : UIImage.eye
                button.setImage(newImage, for: .normal)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .coolNeutral800
        return label
    }()
    
    // MARK: - Initialize
    
    init(
        placeholder: String,
        isSecure: Bool = false,
        rightViewType: RightViewType = .none
    ) {
        super.init(frame: .zero)
        setupUI(placeholder: placeholder, isSecure: isSecure)
        setupRightView(rightViewType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI(placeholder: String, isSecure: Bool) {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.coolNeutral300,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        self.font = .systemFont(ofSize: 16, weight: .regular)
        self.textColor = .black
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.coolNeutral200.cgColor
        self.isSecureTextEntry = isSecure
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        self.leftView = leftPaddingView
        self.leftViewMode = .always
    }
    
    func updateTimerLabel(_ remainingTime: Int) {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func becomeFirstResponder() -> Bool {
        let didBecome = super.becomeFirstResponder()
        if didBecome {
            layer.borderColor = UIColor.coolNeutral600.cgColor
        }
        return didBecome
    }
    
    override func resignFirstResponder() -> Bool {
        let didResign = super.resignFirstResponder()
        if didResign {
            layer.borderColor = UIColor.coolNeutral200.cgColor
        }
        return didResign
    }
}

// MARK: - RightView Configuration

extension CustomTextField {
    private func setupRightView(_ type: RightViewType) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        switch type {
        case .none: resetRightView()
        case .clearButton: setupClearButton()
        case .passwordToggle: setupPasswordToggle()
        case .timerLabel: setupTimerLabel()
        case .clearButtonWithTimer: setupClearButtonWithTimer()
        case .custom(let view): setupCustomView(view)
        }
    }
    
    private func resetRightView() {
        rightView = nil
        rightViewMode = .never
    }
    
    private func setupCustomView(_ view: UIView?) {
        rightView = view
        rightViewMode = (view != nil) ? .always : .never
    }
    
    private func setupClearButton() {
        containerView.frame.size = CGSize(width: 30, height: 48)
        clearButton.frame = CGRect(x: 0, y: 14, width: 20, height: 20)
        clearButton.isHidden = false
        
        containerView.addSubview(clearButton)
        
        rightView = containerView
        rightViewMode = .whileEditing
    }
    
    private func setupPasswordToggle() {
        containerView.frame.size = CGSize(width: 36, height: 48)
        passwordToggleButton.frame = CGRect(x: 0, y: 12, width: 24, height: 24)
        
        containerView.addSubview(passwordToggleButton)
        
        rightView = containerView
        rightViewMode = .always
    }
    
    private func setupTimerLabel() {
        containerView.frame.size = CGSize(width: 50, height: 48)
        timerLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 48)
        
        containerView.addSubview(timerLabel)
        
        rightView = containerView
        rightViewMode = .always
    }
    
    
    private func setupClearButtonWithTimer() {
        containerView.frame.size = CGSize(width: 80, height: 48)
        
        clearButton.frame = CGRect(x: 0, y: 14, width: 20, height: 20)
        clearButton.isHidden = true
        
        timerLabel.frame = CGRect(x: 30, y: 0, width: 50, height: 48)
        
        containerView.addSubview(clearButton)
        containerView.addSubview(timerLabel)
        
        rightView = containerView
        rightViewMode = .always
        
        addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
    }
    
    @objc private func handleEditingDidBegin() {
        clearButton.isHidden = false
    }
    
    @objc private func handleEditingDidEnd() {
        clearButton.isHidden = true
    }
}
