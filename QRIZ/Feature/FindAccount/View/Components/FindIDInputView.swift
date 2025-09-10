//
//  FindIDInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit
import Combine

final class FindIDInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let textFieldHeight: CGFloat = 48.0
        static let inputErrorLabelTopOffset: CGFloat = 4.0
    }
    
    // MARK: - Enums
    
    private enum Attributes {
        static let placeholder: String = "qriz@gmail.com"
        static let errorLabelText: String = "올바른 이메일 형식으로 입력해주세요."
    }
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    var textChangedPublisher: AnyPublisher<String, Never> {
        textField.textPublisher
    }
    
    // MARK: - UI
    
    private lazy var textField: UITextField = {
        let textField = CustomTextField(
            placeholder: Attributes.placeholder,
            rightViewType: .clearButton
        )
        return textField
    }()
    
    private let inputErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.errorLabelText
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

    func updateErrorState(isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        textField.layer.borderColor = isValid
        ? UIColor.coolNeutral600.cgColor
        : UIColor.customRed500.cgColor
    }
    
    func focusInitialField() {
        DispatchQueue.main.async { [weak self] in
            self?.textField.becomeFirstResponder()
        }
    }
}

// MARK: - Layout Setup

extension FindIDInputView {
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
