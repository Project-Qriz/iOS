import UIKit
import DesignSystem
import QRIZUtils

final class PlanChangeOptionView: UIView {

    // MARK: - Properties

    private let option: PlanOption
    var onTap: (() -> Void)?

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()

    private let badgeLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .coolNeutral600
        label.textAlignment = .center
        label.verticalPadding = 4
        label.layer.cornerRadius = 11
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, dayLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.setCustomSpacing(12, after: iconImageView)
        stack.setCustomSpacing(4, after: dayLabel)
        return stack
    }()

    // MARK: - Initialization

    init(option: PlanOption) {
        self.option = option
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        setupUI()
        configure()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = false
    }

    private func configure() {
        iconImageView.image = option.icon
        dayLabel.text = option.dayLabel
        descriptionLabel.text = option.description
    }
    
    private func applyShadow(isSelected: Bool) {
        if isSelected {
            applyQRIZShadow(
                radius: 5,
                color: UIColor(red: 0.063, green: 0.110, blue: 0.239, alpha: 1),
                opacity: 0.32
            )
        } else {
            applyQRIZShadow(
                radius: 3,
                color: UIColor(red: 0.094, green: 0.106, blue: 0.145, alpha: 1),
                opacity: 0.20
            )
        }
    }

    func setBadge(_ text: String?) {
        if let text {
            badgeLabel.text = text
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    func setSelected(_ selected: Bool) {
        layer.borderWidth = selected ? 1 : 0
        layer.borderColor = selected ? UIColor.customBlue500.cgColor : UIColor.clear.cgColor
        applyShadow(isSelected: selected)
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Layout Setup

extension PlanChangeOptionView {

    private func addSubviews() {
        [contentStack, badgeLabel].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -8),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            badgeLabel.topAnchor.constraint(equalTo: topAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
