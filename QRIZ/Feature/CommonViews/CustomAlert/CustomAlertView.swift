//
//  CustomAlertViewController.swift
//  QRIZ
//
//  Created by ch on 1/6/25.
//

import UIKit

final class CustomAlertView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = .coolNeutral800
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        return createButton(
            title: "확인",
            font: UIFont.systemFont(ofSize: 14, weight: .medium),
            titleColor: .white,
            backgroundColor: .customBlue500
        )
    }()
    
    private lazy var cancelButton: UIButton = {
        return createButton(
            title: "취소",
            font: UIFont.systemFont(ofSize: 16, weight: .bold),
            titleColor: .customBlue500,
            backgroundColor: .clear,
            borderColor: .customBlue500
        )
    }()
    
    private lazy var buttonHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    init(
        alertType: AlertType,
        title: String,
        titleLine: Int = 1,
        description: String,
        descriptionLine: Int
    ) {
        super.init(frame: .zero)
        backgroundColor = .coolNeutral100
        layer.cornerRadius = 8
        setLabelText(isTitleLabel: true, text: title, numberOfLines: titleLine)
        setLabelText(isTitleLabel: false, text: description, numberOfLines: descriptionLine)
        addLabels()
        addButtons(alertType: alertType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: CustomAlertView")
    }
    
    func setButtonAction(_ isConfirmButton: Bool, action: UIAction) {
        if isConfirmButton {
            confirmButton.addAction(action, for: .touchUpInside)
        } else {
            cancelButton.addAction(action, for: .touchUpInside)
        }
    }
    
    private func setLabelText(isTitleLabel: Bool, text: String, numberOfLines: Int) {
        if isTitleLabel {
            titleLabel.text = text
            titleLabel.numberOfLines = numberOfLines
        } else {
            descriptionLabel.text = text
            descriptionLabel.numberOfLines = numberOfLines
        }
    }
    
    private func createButton(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor = .clear
    ) -> UIButton {
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 8
        let titleStr = NSAttributedString(
            string: title,
            attributes: [
                .font: font,
                .foregroundColor: titleColor
            ]
        )
        button.setAttributedTitle(titleStr, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor.cgColor
        return button
    }
    
    private func addLabels() {
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    private func addButtons(alertType: AlertType) {
        addSubview(buttonHStackView)
        
        let isCancelButtonHidden: Bool
        let buttonStackHeight: CGFloat
        let descriptionTopSpacing: CGFloat
        
        switch alertType {
        case .onlyConfirm:
            isCancelButtonHidden = true
            buttonStackHeight = 48
            descriptionTopSpacing = 8
        case .canCancel:
            isCancelButtonHidden = false
            buttonStackHeight = 40
            descriptionTopSpacing = 4
        }
        
        cancelButton.isHidden = isCancelButtonHidden
        buttonHStackView.heightAnchor.constraint(equalToConstant: buttonStackHeight).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: descriptionTopSpacing).isActive = true
        
        buttonHStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonHStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonHStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonHStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            buttonHStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
        ])
    }
}
