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
        case custom(UIView?)
    }
    
    // MARK: - Initialize
    
    init(
        placeholder: String,
        isSecure: Bool = false,
        rightViewType: RightViewType = .none
    ) {
        super.init(frame: .zero)
        setupUI(placeholder: placeholder, isSecure: isSecure)
        setRightViewType(rightViewType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI(
        placeholder: String,
        isSecure: Bool
    ) {
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
    
    private func setRightViewType(_ type: RightViewType) {
        switch type {
        case .none:
            self.rightView = nil
            self.rightViewMode = .never
            
        case .clearButton:
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: Attributes.xmarkImage), for: .normal)
            button.tintColor = .coolNeutral300
            button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            
            button.addAction(
                UIAction { [weak self] _ in
                    self?.text = ""
                },
                for: .touchUpInside
            )
            
            configRightButton(button)
            
        case .passwordToggle:
            let button = UIButton(type: .system)
            button.setImage(UIImage.eyeSlash, for: .normal)
            button.tintColor = .coolNeutral700
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

            button.addAction(
                UIAction { [weak self] _ in
                    guard let self = self else { return }
                    self.isSecureTextEntry.toggle()
                    let newImage = self.isSecureTextEntry ? UIImage.eyeSlash : UIImage.eye
                    button.setImage(newImage, for: .normal)
                },
                for: .touchUpInside
            )
            
            configRightButton(button)
            
        case .custom(let rightView):
            self.rightView = rightView
        }
    }
    
    private func configRightButton(
        _ button: UIButton,
        paddingWidth: CGFloat = 50,
        paddingHeight: CGFloat = 54,
        viewMode: UITextField.ViewMode = .whileEditing
    ) {
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: paddingWidth, height: paddingHeight)
        )
        
        button.center = CGPoint(x: paddingView.frame.width / 2, y: paddingView.frame.height / 2)
        paddingView.addSubview(button)
        
        self.rightView = paddingView
        self.rightViewMode = viewMode
    }
}
