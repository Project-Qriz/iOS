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
    }
    
    
    // MARK: - Properties
    
    private let loginLogoView = LoginLogoView()
    
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
        addSubview(loginLogoView)
    }
    
    private func setupConstraints() {
        loginLogoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginLogoView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Metric.logoViewTopOffset),
            loginLogoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Metric.logoViewHorizontalMargin),
            loginLogoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Metric.logoViewHorizontalMargin),
        ])
    }
}
