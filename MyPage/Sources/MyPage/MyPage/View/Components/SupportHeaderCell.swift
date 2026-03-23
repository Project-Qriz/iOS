import UIKit
import DesignSystem

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
