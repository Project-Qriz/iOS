//
//  QuestionOptionLabel.swift
//  ExamKit
//

import UIKit
import DesignSystem
import QRIZUtils

public final class QuestionOptionLabel: UIView {

    // MARK: - Properties

    private let optionNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
        return label
    }()

    private let optionStringLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .coolNeutral800
        label.numberOfLines = 0
        return label
    }()

    var onTap: (() -> Void)?

    // MARK: - Initialization

    public init(number: Int) {
        super.init(frame: .zero)
        optionNumberLabel.text = "\(number)"
        setupUI()
        addSubviews()
        setupConstraints()
        setOptionState(isSelected: false)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionOptionLabel")
    }

    // MARK: - Methods

    private func setupUI() {
        layer.cornerRadius = 16
        layer.borderWidth = 1
    }

    public func setOptionString(_ str: String) {
        optionStringLabel.attributedText = NSAttributedString(text: str, lineSpacing: 8)
    }

    public func setOptionState(isSelected: Bool) {
        let tint: UIColor = isSelected ? .customBlue500 : .coolNeutral100
        backgroundColor = isSelected ? .customBlue500.withAlphaComponent(0.14) : .white
        layer.borderColor = tint.cgColor
        optionNumberLabel.backgroundColor = tint
        optionNumberLabel.textColor = isSelected ? .white : .coolNeutral400
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Layout Setup

extension QuestionOptionLabel {
    private func addSubviews() {
        addSubview(optionNumberLabel)
        addSubview(optionStringLabel)
    }

    private func setupConstraints() {
        optionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        optionStringLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            optionNumberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            optionNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            optionNumberLabel.widthAnchor.constraint(equalToConstant: 32),
            optionNumberLabel.heightAnchor.constraint(equalTo: optionNumberLabel.widthAnchor),

            optionStringLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            optionStringLabel.leadingAnchor.constraint(equalTo: optionNumberLabel.trailingAnchor, constant: 16),
            optionStringLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            optionStringLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

            heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
    }
}
