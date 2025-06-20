//
//  ChangePasswordMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/20/25.
//

import UIKit
import Combine

final class ChangePasswordMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let titleLabelTopOffset: CGFloat = 40.0
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 20.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
    }
    
    private enum Attributes {
        static let titleText: String = "소중한 정보를 보호하기 위해\n새로운 비밀번호로 변경해 주세요!"
        static let forgotPasswordButtonTitle: String = "비밀번호를 잊으셨나요?"
        static let sendButtonTitle: String = "변경하기"
    }
    
    // MARK: - Properties

    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = UILabel.setLineSpacing(8, text: Attributes.titleText)
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        label.numberOfLines = 2
        return label
    }()

    private let changePasswordInputView = ChangePasswordInputView()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let title = Attributes.forgotPasswordButtonTitle
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.coolNeutral500,
            .foregroundColor: UIColor.coolNeutral500,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    let signUpFooterView = SignUpFooterView()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .white
        signUpFooterView.configure(buttonTitle: Attributes.sendButtonTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension ChangePasswordMainView {
    private func addSubviews() {
        [
            titleLabel,
            changePasswordInputView,
            forgotPasswordButton,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        changePasswordInputView.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Metric.titleLabelTopOffset
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            
            changePasswordInputView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metric.verticalSpacing
            ),
            changePasswordInputView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            changePasswordInputView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            
            forgotPasswordButton.topAnchor.constraint(
                equalTo: changePasswordInputView.bottomAnchor,
                constant: Metric.verticalSpacing
            ),
            forgotPasswordButton.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),
            
            signUpFooterView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            signUpFooterView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            signUpFooterView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: Metric.signUpFooterViewBottomOffset
            )
        ])
    }
}
