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
    
    private enum Attributes {
        static let placeholder: String = "이름을 입력"
        static let errorText: String = "이름을 다시 확인해 주세요."
    }
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    var textChangedPublisher: AnyPublisher<String, Never> {
        textField.textPublisher
    }
    
    // MARK: - UI
    
    private let textField: UITextField = {
        let textField = CustomTextField(
            placeholder: Attributes.placeholder,
            rightViewType: .clearButton
        )
        return textField
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.errorText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialize
    
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
    
    func updateErrorState(isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        textField.layer.borderColor = isValid ? UIColor.customMint800.cgColor : UIColor.customRed500.cgColor
    }
    
    func focusInitialField() {
        DispatchQueue.main.async { [weak self] in
            self?.textField.becomeFirstResponder()
        }
    }
}

// MARK: - Layout Setup

extension SingleInputView {
    private func addSubviews() {
        [
            textField,
            inputErrorLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        inputErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
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
