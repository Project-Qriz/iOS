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
    private lazy var confirmButton: UIButton = UIButton(frame: .zero)
    private lazy var cancelButton: UIButton = UIButton(frame: .zero)
    
    init(alertType: AlertType, title: String, titleLine: Int = 1, description: String, descriptionLine: Int) {
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
    
    private func createButton(isConfirmButton: Bool) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 8
        var titleStr: NSAttributedString
        
        switch isConfirmButton {
            
        case true:
            titleStr = NSAttributedString(string: "확인", attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.white
            ])
            button.backgroundColor = .customBlue500
            
        case false:
            titleStr = NSAttributedString(string: "취소", attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor.customBlue500
            ])
            button.layer.borderColor = UIColor.customBlue500.cgColor
            button.layer.borderWidth = 1
            button.backgroundColor = .clear
        }
        
        button.setAttributedTitle(titleStr, for: .normal)
        
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
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(22 * descriptionLabel.numberOfLines))
        ])
    }
    
    private func addButtons(alertType: AlertType) {
        
        confirmButton = createButton(isConfirmButton: true)
        
        addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        switch alertType {
        case .canCancel:
            cancelButton = createButton(isConfirmButton: false)
            addSubview(cancelButton)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                confirmButton.widthAnchor.constraint(equalToConstant: 123.5),
                confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                cancelButton.bottomAnchor.constraint(equalTo: confirmButton.bottomAnchor),
                cancelButton.heightAnchor.constraint(equalTo: confirmButton.heightAnchor),
                cancelButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor),
                cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
            ])
        case .onlyConfirm:
            NSLayoutConstraint.activate([
                confirmButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
                confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
            ])
        }
    }
}
