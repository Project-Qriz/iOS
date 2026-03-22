import UIKit
import DesignSystem

final class ProfileHeaderView: UIView {

    // MARK: - Properties

    // MARK: - UI

    private let nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let emailLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral400
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
        backgroundColor = .white
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.customBlue100.cgColor
        layer.cornerRadius = 8.0
    }

    func configure(name: String, email: String) {
        nameLabel.text = "\(name)님"
        emailLabel.text = email
    }
}

// MARK: - Layout Setup

extension ProfileHeaderView {
    private func addSubviews() {
        [
            nameLabel,
            emailLabel
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10.0),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            emailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
        ])
    }
}
