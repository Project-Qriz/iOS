//
//  TermsAgreementHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/13/25.
//

import UIKit

final class TermsAgreementHeaderView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let xmarkSize: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let title: String = "약관동의"
        static let xmark: String = "xmark"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.title
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let xmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: Attributes.xmark))
        imageView.tintColor = .coolNeutral800
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        self.backgroundColor = .white
    }

}

// MARK: - Layout Setup

extension TermsAgreementHeaderView {
    private func addSubviews() {
        [
            titleLabel,
            xmarkImageView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        xmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            xmarkImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            xmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            xmarkImageView.widthAnchor.constraint(equalToConstant: Metric.xmarkSize),
            xmarkImageView.heightAnchor.constraint(equalToConstant: Metric.xmarkSize),
        ])
    }
}

