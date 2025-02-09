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
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    var textChangedPublisher: AnyPublisher<String, Never> {
        textField.textPublisher
    }
    
    // MARK: - UI
    
    private lazy var textField: UITextField = {
        let textField = CustomTextField(placeholder: "")
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
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    private func observe() {
        textField.controlEventPublisher(for: .editingDidEndOnExit)
            .sink { [weak self] _ in
                self?.resignFirstResponder()
            }
            .store(in: &cancellables)
    }
    
    func configure(placeholder: String, errorText: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.coolNeutral300,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
        inputErrorLabel.text = errorText
    }
    
    func updateErrorState(isValid: Bool) {
        inputErrorLabel.isHidden = isValid
        textField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.customRed500.cgColor
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
