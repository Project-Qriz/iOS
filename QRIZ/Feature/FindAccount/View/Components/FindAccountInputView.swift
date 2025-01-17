//
//  FindAccountInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit

final class FindAccountInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        static let textFieldTopOffset: CGFloat = 12.0
        static let inputErrorLabelTopOffset: CGFloat = 8.0
    }
    
    // MARK: - Properties
    
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral600
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = CustomTextField(placeholder: "")
        textField.delegate = self
        return textField
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
    
    func configure(titleText: String, placeholder: String, errorText: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.coolNeutral300,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
        titleLabel.text = titleText
        inputErrorLabel.text = errorText
    }
    
    func updateErrorState(isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        textField.layer.borderColor = isValid
        ? UIColor.clear.cgColor
        : UIColor.customRed500.cgColor
    }
}

// MARK: - Layout Setup

extension FindAccountInputView {
    private func addSubviews() {
        [
            titleLabel,
            textField,
            inputErrorLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        inputErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            textField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: Metric.textFieldTopOffset
            ),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            inputErrorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Metric.inputErrorLabelTopOffset),
            inputErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputErrorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - UITextFieldDelegate

extension FindAccountInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
