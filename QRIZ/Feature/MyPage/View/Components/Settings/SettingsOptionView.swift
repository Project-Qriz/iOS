//
//  SettingsOptionView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import UIKit
import Combine

final class SettingsOptionView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let verticalSpacing: CGFloat = 21.0
        static let horizontalSpacing: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let chevron: String = "chevron.right"
    }
    
    // MARK: - Properties
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let chevronButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: Attributes.chevron, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral400
        return button
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
        backgroundColor = .white
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.customBlue100.cgColor
        layer.cornerRadius = 8.0
    }
}

// MARK: - Layout Setup

extension SettingsOptionView {
    private func addSubviews() {
        [
            titleLabel,
            chevronButton,
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.verticalSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.verticalSpacing),
            
            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalSpacing),
            chevronButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
}

