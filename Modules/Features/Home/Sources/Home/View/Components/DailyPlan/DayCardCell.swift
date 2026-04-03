//
//  DayCardCell.swift
//  QRIZ
//
//  Created by 김세훈 on 6/28/25.
//

import UIKit
import DesignSystem

final class DayCardCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let verticalSpacing: CGFloat = 8.0
        static let numberCircleTopOffset: CGFloat = 4.0
        static let circleSize: CGFloat = 24.0
        static let goalAchievedDay: Int = 31
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Day"
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

    private let flagImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "flag.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .coolNeutral400
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setupUI() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        contentView.backgroundColor = .customBlue100
    }

    func configure(day: Int, isSelected: Bool) {
        if day == Metric.goalAchievedDay {
            titleLabel.text = "목표달성"
            numberCircle.isHidden = true
            flagImageView.isHidden = false
        } else {
            titleLabel.text = "Day"
            numberCircle.isHidden = false
            flagImageView.isHidden = true
            numberCircle.text = "\(day)"
        }

        titleLabel.textColor = isSelected ? .coolNeutral800 : .coolNeutral400
        numberCircle.backgroundColor = isSelected ? .coolNeutral800 : .coolNeutral400
        contentView.backgroundColor = isSelected ? .white : .customBlue100
    }
}

// MARK: - Layout Setup

extension DayCardCell {
    private func addSubviews() {
        [
            titleLabel,
            numberCircle,
            flagImageView,
        ].forEach(contentView.addSubview(_:))
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        numberCircle.translatesAutoresizingMaskIntoConstraints = false
        flagImageView.translatesAutoresizingMaskIntoConstraints = false

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
            numberCircle.widthAnchor.constraint(equalToConstant: Metric.circleSize),
            numberCircle.heightAnchor.constraint(equalToConstant: Metric.circleSize),
            numberCircle.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Metric.verticalSpacing
            ),

            flagImageView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metric.numberCircleTopOffset
            ),
            flagImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: Metric.circleSize),
            flagImageView.heightAnchor.constraint(equalToConstant: Metric.circleSize),
            flagImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Metric.verticalSpacing
            ),
        ])
    }
}
