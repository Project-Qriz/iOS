//
//  DayCardCell.swift
//  QRIZ
//
//  Created by 김세훈 on 6/28/25.
//

import UIKit

final class DayCardCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let verticalSpacing: CGFloat = 8.0
        static let numberCircleTopOffset: CGFloat = 4.0
        static let circleSize: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let titleText: String = "Day"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral400
        return label
    }()
    
    private let numberCircle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .coolNeutral400
        label.layer.cornerRadius = Metric.circleSize / 2
        label.layer.masksToBounds = true
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
        backgroundColor = .customBlue100
        layer.cornerRadius = 8
        layer.backgroundColor = UIColor.coolNeutral100.cgColor
    }
    
    func configure(day: Int) {
        numberCircle.text = "\(day)"
    }
}

// MARK: - Layout Setup

extension DayCardCell {
    private func addSubviews() {
        [
            titleLabel,
            numberCircle,
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        numberCircle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metric.verticalSpacing
            ),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            numberCircle.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metric.numberCircleTopOffset
            ),
            numberCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            numberCircle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.verticalSpacing),
            numberCircle.widthAnchor.constraint(equalToConstant: Metric.circleSize),
            numberCircle.heightAnchor.constraint(equalToConstant: Metric.circleSize),
        ])
    }
}
