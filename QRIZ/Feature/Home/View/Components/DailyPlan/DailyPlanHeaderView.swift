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
}

// MARK: - Layout Setup

extension DailyPlanHeaderView {
    private func addSubviews() {
        [
            titleLabel,
            resetButton
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            resetButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: Metric.buttonSize),
            resetButton.heightAnchor.constraint(equalToConstant: Metric.buttonSize),
        ])
    }
}
