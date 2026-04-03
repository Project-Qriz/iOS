//
//  StudyContentCell.swift
//  QRIZ
//
//  Created by ch on 3/27/25.
//

import UIKit
import DesignSystem

final class StudyContentCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let titleTopOffset: CGFloat = 20
        static let horizontalInset: CGFloat = 16
        static let descriptionTopSpacing: CGFloat = 12
    }

    // MARK: - Properties

    static let identifier = "StudyContentCell"

    private static let descriptionParagraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        return style
    }()

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupAppearance()
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(title: String, description: String) {
        titleLabel.text = title

        let attributedString = NSMutableAttributedString(string: description)
        attributedString.addAttribute(.paragraphStyle, value: Self.descriptionParagraphStyle, range: NSRange(location: 0, length: attributedString.length))

        descriptionLabel.attributedText = attributedString
    }

    private func setupAppearance() {
        layer.cornerRadius = 8
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        layer.shadowColor = UIColor.coolNeutral100.cgColor
    }

    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            backgroundColor = .coolNeutral800.withAlphaComponent(0.1)
        case .cancelled, .failed, .ended:
            backgroundColor = .white
        default:
            break
        }
    }
}

// MARK: - Layout Setup

extension StudyContentCell {
    private func addSubviews() {
        [titleLabel, descriptionLabel].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        [titleLabel, descriptionLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalInset),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.descriptionTopSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalInset),
        ])
    }
}
