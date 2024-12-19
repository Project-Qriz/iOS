//
//  LoginLogoView.swift
//  QRIZ
//
//  Created by KSH on 12/20/24.
//

import UIKit

final class LoginLogoView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalPadding: CGFloat = 64.0
        static let logoHeightMultiplier: CGFloat = 0.5
    }
    
    private enum Attributes {
        static let loginLogo: String = "loginLogo"
    }
    
    // MARK: - UI
    
    private let appLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Attributes.loginLogo)
        return imageView
    }()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout Setup

extension LoginLogoView {
    private func addSubviews() {
        addSubview(appLogoImageView)
    }
    
    private func setupConstraints() {
        appLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            appLogoImageView.topAnchor.constraint(equalTo: self.topAnchor),
            appLogoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Metric.horizontalPadding),
            appLogoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Metric.horizontalPadding),
            appLogoImageView.heightAnchor.constraint(equalTo: appLogoImageView.widthAnchor, multiplier: Metric.logoHeightMultiplier),
            appLogoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
