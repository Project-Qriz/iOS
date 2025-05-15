//
//  TermsAgreementItemView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/14/25.
//

import UIKit

final class TermsAgreementItemView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let checkmarkSize: CGFloat = 20.0
        static let chevronSize: CGFloat = 20.0
        static let contentSpacing: CGFloat = 8.0
    }
    
    private enum Attributes {
        static let checkmark: String = "checkmark"
        static let chevron: String = "chevron.right"
        static let requiredText: String = "(필수)"
    }
    
    // MARK: - UI
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: Attributes.checkmark))
        imageView.tintColor = .coolNeutral200
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral600
        return label
    }()
    
    private let requiredLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.requiredText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .customRed500
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: Attributes.chevron))
        imageView.tintColor = .coolNeutral600
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initialize
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
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

extension TermsAgreementItemView {
    private func addSubviews() {
        [
            checkmarkImageView,
            titleLabel,
            requiredLabel,
            chevronImageView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        requiredLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chevronImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            checkmarkImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: Metric.checkmarkSize),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: Metric.contentSpacing),
            
            requiredLabel.topAnchor.constraint(equalTo: topAnchor),
            requiredLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            chevronImageView.topAnchor.constraint(equalTo: topAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: Metric.chevronSize),
            chevronImageView.heightAnchor.constraint(equalToConstant: Metric.chevronSize),
            chevronImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

