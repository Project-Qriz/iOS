//
//  SignupFooterView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit
import Combine

final class SignupFooterView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let buttonHeight: CGFloat = 48.0
    }
    
    // MARK: - Properties
    
    private let buttonTappedSubject = PassthroughSubject<Void, Never>()

    var buttonTappedPublisher: AnyPublisher<Void, Never> {
        buttonTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.coolNeutral500, for: .normal)
        button.backgroundColor = .coolNeutral200
        button.layer.cornerRadius = 8
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: - initialize
    
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
        self.backgroundColor = .white
    }
    
    func configure(buttonTitle: String) {
        nextButton.setTitle(buttonTitle, for: .normal)
    }
    
    func updateButtonState(isValid: Bool) {
        nextButton.isEnabled = isValid
        nextButton.backgroundColor = isValid ? .customBlue500 : .coolNeutral200
        nextButton.setTitleColor(isValid ? .white : .coolNeutral500, for: .normal)
    }
}

// MARK: - Layout Setup

extension SignupFooterView {
    private func addSubviews() {
        [
            nextButton
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: topAnchor),
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: Metric.buttonHeight)
        ])
    }
}
