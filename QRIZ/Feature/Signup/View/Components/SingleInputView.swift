//
//  SingleInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit
import Combine

final class SingleInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        static let inputErrorLabelTopOffset: CGFloat = 8.0
    }
    
    // MARK: - UI
    
    private let nameTextField: UITextField = CustomTextField(placeholder: "")
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
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
    
    func configure(placeholder: String, errorText: String) {
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.coolNeutral300,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
        inputErrorLabel.text = errorText
    }
}

// MARK: - Layout Setup

extension SingleInputView {
    private func addSubviews() {
        [
            nameTextField,
            inputErrorLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        inputErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: Metric.textFieldHeight),
            
            inputErrorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Metric.inputErrorLabelTopOffset),
            inputErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputErrorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
