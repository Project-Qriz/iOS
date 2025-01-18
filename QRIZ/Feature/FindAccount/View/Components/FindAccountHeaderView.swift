//
//  FindAccountHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit

final class FindAccountHeaderView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let descriptionLabelTopOffset: CGFloat = 10.0
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
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
    
    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}

// MARK: - Layout Setup

extension FindAccountHeaderView {
    private func addSubviews() {
        [
            titleLabel,
            descriptionLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: Metric.descriptionLabelTopOffset
            ),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
