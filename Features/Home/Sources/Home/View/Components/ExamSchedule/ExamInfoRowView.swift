//
//  ExamInfoRowView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/4/25.
//

import UIKit
import DesignSystem
import QRIZUtils

final class ExamInfoRowView: UIView {

    // MARK: - Enums

    private enum Metric {
        static let defaultMargin: CGFloat = 18.0
        static let verticalInset: CGFloat = 16.0
        static let iconToContentSpacing: CGFloat = 16.0
        static let separatorHeight: CGFloat = 1.0
    }

    // MARK: - UI

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue100
        return view
    }()

    private let statusImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let image = UIImage(systemName: "record.circle.fill", withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private lazy var examInfoVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            examNameLabel, periodLabel, examDateLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        return stackView
    }()

    private let examNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let examDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
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
        backgroundColor = .white
    }

    func configure(with state: ExamRowState) {
        setTexts(
            name: state.examName,
            period: state.periodText,
            date: state.dateText
        )
        setSelected(state.isSelected)
        setExpired(state.isExpired)
    }

    private func setTexts(
        name: String,
        period: String,
        date: String
    ) {
        examNameLabel.text = name
        periodLabel.text = period
        examDateLabel.text = date
    }

    private func setSelected(_ isSelected: Bool) {
        statusImageView.tintColor = isSelected ? .customBlue500 : .coolNeutral200
    }

    private func setExpired(_ isExpired: Bool) {
        backgroundColor = isExpired ? .coolNeutral100 : .white
        examNameLabel.textColor = isExpired ? .coolNeutral300 : .coolNeutral800
        periodLabel.textColor = isExpired ? .coolNeutral300 : .coolNeutral500
        examDateLabel.textColor = isExpired ? .coolNeutral300 : .coolNeutral800
    }
}

// MARK: - Layout Setup

extension ExamInfoRowView {
    private func addSubviews() {
        [
            separator,
            statusImageView,
            examInfoVStackView
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        examInfoVStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.defaultMargin),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.defaultMargin),
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight),

            statusImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.defaultMargin),

            examInfoVStackView.topAnchor.constraint(equalTo: topAnchor, constant: Metric.verticalInset),
            examInfoVStackView.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: Metric.iconToContentSpacing),
            examInfoVStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.defaultMargin),
            examInfoVStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.verticalInset),
        ])
    }
}
