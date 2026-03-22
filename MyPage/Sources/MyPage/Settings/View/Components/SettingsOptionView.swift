import UIKit
import DesignSystem
import QRIZUtils
import Combine

final class SettingsOptionView: UIView {

    // MARK: - Properties

    var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let chevronButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral400
        return button
    }()

    // MARK: - Initialize

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
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
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.customBlue100.cgColor
        layer.cornerRadius = 8.0
    }
}

// MARK: - Layout Setup

extension SettingsOptionView {
    private func addSubviews() {
        [
            titleLabel,
            chevronButton,
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 21.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18.0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -21.0),

            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18.0),
            chevronButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
}
