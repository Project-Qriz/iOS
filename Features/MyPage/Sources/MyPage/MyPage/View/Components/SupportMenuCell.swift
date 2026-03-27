import UIKit
import DesignSystem

final class SupportMenuCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let horizontalSpacing: CGFloat = 24.0
        static let verticalSpacing: CGFloat = 25.0
    }

    private enum Attributes {
        static let chevron: String = "chevron.right"
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let chevronButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: Attributes.chevron, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral400
        return button
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral400
        label.isHidden = true
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

    func configure(title: String, version: String? = nil) {
        titleLabel.text = title

        if let version = version {
            versionLabel.text = version
            versionLabel.isHidden = false
            chevronButton.isHidden = true
        } else {
            versionLabel.isHidden = true
            chevronButton.isHidden = false
        }
    }
}

// MARK: - Layout Setup

extension SupportMenuCell {
    private func addSubviews() {
        [
            titleLabel,
            chevronButton,
            versionLabel
        ].forEach(contentView.addSubview(_:))
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.verticalSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.verticalSpacing),

            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalSpacing),
            chevronButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalSpacing),
            versionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
