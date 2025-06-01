//
//  SplashMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/2/25.
//

import UIKit

final class SplashMainView: UIView {
    
    // MARK: - UI
    
    private let logo = UIImageView(image: .splashLogo)
    private let bottomImage = UIImageView(image: .splashBottom)
    
    // MARK: - Initialize
    
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
        backgroundColor = .customBlue500
    }
}

// MARK: - Layout Setup

extension SplashMainView {
    private func addSubviews() {
        [
            logo,
            bottomImage
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        logo.translatesAutoresizingMaskIntoConstraints = false
        bottomImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            bottomImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomImage.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
