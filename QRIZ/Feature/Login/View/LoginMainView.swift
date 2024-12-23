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
        
        static let socialLoginViewTopOffset: CGFloat = 84.0
        static let socialLoginViewHorizontalMargin: CGFloat = 18.0
    }
    
    
    // MARK: - Properties
    
    private let loginLogoView = LoginLogoView()
    private let loginInputView = LoginInputView()
    private let accountOptionsView = AccountOptionsView()
    private let socialLoginView = SocialLoginView()
    
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
            accountOptionsView,
            socialLoginView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        loginLogoView.translatesAutoresizingMaskIntoConstraints = false
        loginInputView.translatesAutoresizingMaskIntoConstraints = false
        accountOptionsView.translatesAutoresizingMaskIntoConstraints = false
        socialLoginView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginLogoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Metric.logoViewTopOffset),
            loginLogoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.logoViewHorizontalMargin),
            loginLogoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.logoViewHorizontalMargin),
            
            loginInputView.topAnchor.constraint(equalTo: loginLogoView.bottomAnchor, constant: Metric.inputViewTopOffset),
            loginInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.inputViewHorizontalMargin),
            loginInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.inputViewHorizontalMargin),
            
            accountOptionsView.topAnchor.constraint(equalTo: loginInputView.bottomAnchor, constant: Metric.accountOptionsViewTopOffset),
            accountOptionsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            socialLoginView.topAnchor.constraint(equalTo: accountOptionsView.bottomAnchor, constant: Metric.socialLoginViewTopOffset),
            socialLoginView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.socialLoginViewHorizontalMargin),
            socialLoginView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.socialLoginViewHorizontalMargin),
        ])
    }
}
