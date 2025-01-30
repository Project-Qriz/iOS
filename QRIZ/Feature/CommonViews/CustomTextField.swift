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
        case custom(UIView?)
    }
    
    // MARK: - UI
    
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
        self.layer.borderColor = UIColor.coolNeutral600.cgColor
        self.isSecureTextEntry = isSecure
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        self.leftView = leftPaddingView
        self.leftViewMode = .always
    }
    
    func setTimerText(_ text: String) {
        timerLabel.text = text
    }
}

// MARK: - RightView Configuration

extension CustomTextField {
    private func setupRightView(_ type: RightViewType) {
        switch type {
        case .none: resetRightView()
        case .clearButton: setupClearButton()
        case .passwordToggle: setupPasswordToggle()
        case .timerLabel: setupTimerLabel()
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
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Attributes.xmarkImage), for: .normal)
        button.tintColor = .coolNeutral300
        button.addAction(UIAction { [weak self] _ in self?.text = "" }, for: .touchUpInside)
        configureRightView(
            with: button,
            subviewSize: CGSize(width: 20, height: 20)
        )
    }
    
    private func setupPasswordToggle() {
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
        configureRightView(
            with: button,
            subviewSize: CGSize(width: 24, height: 24)
        )
    }
    
    private func setupTimerLabel() {
        configureRightView(
            with: timerLabel,
            viewMode: .always,
            subviewSize: CGSize(width: 50, height: 48)
        )
    }
    
    private func configureRightView(
        with subview: UIView,
        viewMode: ViewMode = .whileEditing,
        containerSize: CGSize = CGSize(width: 50, height: 54),
        subviewSize: CGSize? = nil
    ) {
        let container = UIView(frame: CGRect(origin: .zero, size: containerSize))
        
        if let subviewSize = subviewSize {
            subview.frame.size = subviewSize
        }
        
        subview.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
        container.addSubview(subview)
        
        rightView = container
        rightViewMode = viewMode
    }
}
