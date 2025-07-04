//
//  DailyPlanHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/26/25.
//

import UIKit

import UIKit
import Combine

final class DailyPlanHeaderView: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let buttonSize: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let chevron: String = "chevron.down"
        static let titleText: String = "오늘의 공부"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(.homeReset, for: .normal)
        button.tintColor = .coolNeutral800
        return button
    }()
    
    private let dayButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding  = 4
        config.titleAlignment = .leading
        config.imagePlacement = .trailing
        
        var title = AttributedString("Day1")
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.foregroundColor = .coolNeutral600
        config.attributedTitle = title
        
        let button = UIButton(configuration: config)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let chevron = UIImage(systemName: Attributes.chevron, withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)

        button.setImage(chevron, for: .normal)
        button.tintColor = .coolNeutral600
        button.contentHorizontalAlignment = .leading
        return button
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
        backgroundColor = .customBlue50
    }
    
    func configure(day: Int) {
        dayButton.configuration?.title = "Day\(day)"
    }
}

// MARK: - Layout Setup

extension DailyPlanHeaderView {
    private func addSubviews() {
        [
            titleLabel,
            resetButton,
            dayButton
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            resetButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: Metric.buttonSize),
            resetButton.heightAnchor.constraint(equalToConstant: Metric.buttonSize),
            
            dayButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            dayButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dayButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
