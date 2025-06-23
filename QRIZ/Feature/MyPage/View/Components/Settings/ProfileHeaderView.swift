//
//  ProfileHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import UIKit

final class ProfileHeaderView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let spacing: CGFloat = 16.0
        static let emailLabelTopOffset: CGFloat = 10.0
    }
    
    // MARK: - Properties
    
    // MARK: - UI
    
    private let nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let emailLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral400
        return label
    }()
    
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
        backgroundColor = .white
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.customBlue100.cgColor
        layer.cornerRadius = 8.0
    }
    
    func configure(name: String, email: String) {
        nameLabel.text = "\(name)님"
        emailLabel.text = email
    }
}

// MARK: - Layout Setup

extension ProfileHeaderView {
    private func addSubviews() {
        [
            nameLabel,
            emailLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.spacing),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.spacing),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metric.emailLabelTopOffset),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.spacing),
            emailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.spacing)
        ])
    }
}

