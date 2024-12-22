//
//  LoginMainView.swift
//  QRIZ
//
//  Created by KSH on 12/19/24.
//

import UIKit

final class LoginMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let logoViewTopOffset: CGFloat = 48.0
        static let logoViewHorizontalMargin: CGFloat = 64.0
        
        static let inputViewTopOffset: CGFloat = 32.0
        static let inputViewHorizontalMargin: CGFloat = 18.0
        
        static let accountOptionsViewTopOffset: CGFloat = 32.0
    }
    
    
    // MARK: - Properties
    
    private let loginLogoView = LoginLogoView()
    private let loginInputView = LoginInputView()
    private let accountOptionsView = AccountOptionsView()
    
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
}

// MARK: - Layout Setup

extension LoginMainView {
    private func addSubviews() {
        [
            loginLogoView,
            loginInputView,
            accountOptionsView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        loginLogoView.translatesAutoresizingMaskIntoConstraints = false
        loginInputView.translatesAutoresizingMaskIntoConstraints = false
        accountOptionsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginLogoView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Metric.logoViewTopOffset),
            loginLogoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Metric.logoViewHorizontalMargin),
            loginLogoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Metric.logoViewHorizontalMargin),
            
            loginInputView.topAnchor.constraint(equalTo: self.loginLogoView.bottomAnchor, constant: Metric.inputViewTopOffset),
            loginInputView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Metric.inputViewHorizontalMargin),
            loginInputView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Metric.inputViewHorizontalMargin),
            
            accountOptionsView.topAnchor.constraint(equalTo: self.loginInputView.bottomAnchor, constant: Metric.accountOptionsViewTopOffset),
            accountOptionsView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
}
