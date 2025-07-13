//
//  DayCell.swift
//  QRIZ
//
//  Created by 김세훈 on 7/13/25.
//

import UIKit

final class DayCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalPadding: CGFloat = 24.0
        static let verticalPadding: CGFloat = 10.5
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral800
        label.textAlignment = .center
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
        contentView.layer.cornerRadius = 8.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.coolNeutral200.cgColor
    }
    
    func configure(title: String, selected: Bool) {
        titleLabel.text = title
        
        if selected {
            titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
            contentView.layer.borderWidth = 1.2
            contentView.layer.borderColor = UIColor.coolNeutral800.cgColor
        } else {
            titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
            contentView.layer.borderWidth = 1.0
            contentView.layer.borderColor = UIColor.coolNeutral200.cgColor
        }
    }
}

// MARK: - Layout Setup

extension DayCell {
    private func addSubviews() {
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metric.verticalPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metric.horizontalPadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Metric.horizontalPadding
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Metric.verticalPadding
            )
        ])
    }
}
