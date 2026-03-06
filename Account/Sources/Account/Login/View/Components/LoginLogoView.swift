//
//  LoginLogoView.swift
//  QRIZ
//
//  Created by KSH on 12/20/24.
//

import UIKit
import DesignSystem

final class LoginLogoView: UIView {
    
    // MARK: - UI
    
    private let appLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.loginLogo
        return imageView
    }()
    
    // MARK: - Initialization

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
            appLogoImageView.topAnchor.constraint(equalTo: topAnchor),
            appLogoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            appLogoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            appLogoImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
