//
//  ExamEntryCardCell.swift
//  QRIZ
//
//  Created by 김세훈 on 5/22/25.
//

import UIKit
import DesignSystem
import QRIZUtils

final class ExamEntryCardCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let verticalMargin: CGFloat = 28.0
        static let titleLabelLeadingOffset: CGFloat = 16.0
        static let descriptionLabelTopOffset: CGFloat = 8.0
        static let entryImageViewMargin: CGFloat = 24.0
        static let entryImageViewSize: CGFloat = 58.0
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()

    private let entryImageView: UIImageView = {
        let entryImageView = UIImageView()
        return entryImageView
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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.coolNeutral100.cgColor
    }

    func configure(state: EntryCardState) {
        switch state {
        case .preview:
            titleLabel.text = "프리뷰 시험"
            descriptionLabel.text = "간단한 테스트로 실력을 확인해봐요!"
            entryImageView.image = .onboarding2

        case .mock:
            titleLabel.text = "모의고사 응시"
            descriptionLabel.text = "실전처럼 준비하기"
            entryImageView.image = .mockExam
        }
    }
}

// MARK: - Layout Setup

extension ExamEntryCardCell {
    private func addSubviews() {
        [
            titleLabel,
            descriptionLabel,
            entryImageView
        ].forEach(contentView.addSubview(_:))
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        entryImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.titleLabelLeadingOffset),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.titleLabelLeadingOffset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.verticalMargin),

            entryImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.entryImageViewMargin),
            entryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.entryImageViewMargin),
            entryImageView.heightAnchor.constraint(equalToConstant: Metric.entryImageViewSize),
            entryImageView.widthAnchor.constraint(equalToConstant: Metric.entryImageViewSize)
        ])
    }
}
