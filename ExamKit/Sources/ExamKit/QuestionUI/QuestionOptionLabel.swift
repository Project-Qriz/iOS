//
//  QuestionOptionLabel.swift
//  ExamKit
//

import UIKit
import DesignSystem

public final class QuestionOptionLabel: UIView {

    // MARK: - Properties
    private let optionNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.layer.borderColor = UIColor.coolNeutral700.cgColor
        return label
    }()

    private let optionStringLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .coolNeutral700
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initializers
    public init(number: Int) {
        super.init(frame: .zero)
        optionNumberLabel.text = "\(number)"
        setOptionState(isSelected: false)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionOptionLabel")
    }

    // MARK: - Methods
    public func setOptionString(_ str: String) {
        optionStringLabel.attributedText = formattedText(str)
    }

    public func setOptionState(isSelected: Bool) {
        if isSelected {
            backgroundColor = .customBlue500.withAlphaComponent(0.14)
            optionNumberLabel.backgroundColor = .customBlue500
            optionNumberLabel.textColor = .white
            optionNumberLabel.layer.borderWidth = 0
        } else {
            backgroundColor = .white
            optionNumberLabel.backgroundColor = .white
            optionNumberLabel.textColor = .coolNeutral700
            optionNumberLabel.layer.borderWidth = 1.2
        }
    }

    private func formattedText(_ text: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = 8
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.length))
        return attributed
    }
}

// MARK: - Layout
extension QuestionOptionLabel {
    private func addSubviews() {
        addSubview(optionNumberLabel)
        addSubview(optionStringLabel)
    }

    private func setupConstraints() {
        optionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        optionStringLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            optionNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            optionNumberLabel.widthAnchor.constraint(equalToConstant: 40),
            optionNumberLabel.heightAnchor.constraint(equalTo: optionNumberLabel.widthAnchor),
            optionNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            optionStringLabel.leadingAnchor.constraint(equalTo: optionNumberLabel.trailingAnchor, constant: 16),
            optionStringLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            optionStringLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            optionStringLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
