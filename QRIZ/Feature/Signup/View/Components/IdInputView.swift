//
//  IDInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit
import Combine

final class IdInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let stackViewHeight: CGFloat = 48.0
        static let buttonWidthMultiplier: CGFloat = 1.9
        static let idCountLabelTopOffset: CGFloat = 8.0
        
    }
    
    private enum Attributes {
        static let placeholder: String = "아이디 입력"
        static let buttonTitle: String = "중복확인"
        static let idCountLabelText: String = "0/8"
    }
    
    // MARK: - UI
    
    private let nameTextField: UITextField = CustomTextField(placeholder: Attributes.placeholder)
    private let duplicateCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle(Attributes.buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.customBlue500, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.customBlue500.cgColor
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameTextField,
            duplicateCheckButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    let idCountLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.idCountLabelText
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .coolNeutral800
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
}

// MARK: - Layout Setup

extension IdInputView {
    private func addSubviews() {
        [
            stackView,
            idCountLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        idCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Metric.stackViewHeight),
            
            duplicateCheckButton.widthAnchor.constraint(equalTo: duplicateCheckButton.heightAnchor, multiplier: Metric.buttonWidthMultiplier),
            
            idCountLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Metric.idCountLabelTopOffset),
            idCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            idCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            idCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
