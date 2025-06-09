//
//  SupportMenuCell.swift
//  QRIZ
//
//  Created by 김세훈 on 6/4/25.
//

import UIKit

final class SupportHeaderCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalSpacing: CGFloat = 24.0
        static let separatorHeight: CGFloat = 1.0
    }
    
    private enum Attributes {
        static let title: String = "고객센터"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue100
        return view
    }()
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    private func setupUI() {
        backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension SupportHeaderCell {
    private func addSubviews() {
        [
            titleLabel,
            separator
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.horizontalSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalSpacing),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalSpacing),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalSpacing),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight),
        ])
    }
}

// MARK: - SupportMenuCell

final class SupportMenuCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalSpacing: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let chevron: String = "chevron.right"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: Attributes.chevron, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        
        button.addAction(UIAction(handler: { _ in
            print("터치터치")
        }), for: .touchUpInside)
        return button
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral400
        label.isHidden = true
        return label
    }()
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    private func setupUI() {
        backgroundColor = .white
    }
    
    func configure(title: String, version: String? = nil) {
        titleLabel.text = title
        
        if let version = version {
            versionLabel.text = version
            versionLabel.isHidden = false
            chevronButton.isHidden = true
        } else {
            versionLabel.isHidden = true
            chevronButton.isHidden = false
        }
    }
}

// MARK: - Layout Setup

extension SupportMenuCell {
    private func addSubviews() {
        [
            titleLabel,
            chevronButton,
            versionLabel
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalSpacing),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalSpacing),
            chevronButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalSpacing),
            versionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
