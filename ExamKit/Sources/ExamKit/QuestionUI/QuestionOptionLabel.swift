//
//  QuestionOptionLabel.swift
//  ExamKit
//

import UIKit
import DesignSystem
import QRIZUtils

public final class QuestionOptionLabel: UILabel {

    // MARK: - Properties
    private var optionNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 1

        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.layer.borderColor = UIColor.coolNeutral700.cgColor
        label.layer.borderWidth = 1.25

        return label
    }()

    private var optionStringLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .coolNeutral700
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initializers
    public init(optNum: Int) {
        super.init(frame: .zero)
        optionNumberLabel.text = "\(optNum)"
        setOptionState(isSelected: false)
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionOptionLabel")
    }

    // MARK: - Methods
    public func setOptionString(_ str: String, isSqlOrFunc: Bool = false) {
        optionStringLabel.attributedText = formattedText(str)
        optionStringLabel.font = isSqlOrFunc ? .systemFont(ofSize: 14, weight: .regular) : .systemFont(ofSize: 16, weight: .regular)
        moveOptionStringLabel(isSqlorFunc: isSqlOrFunc)
    }

    public func setOptionState(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .customBlue500.withAlphaComponent(0.14)
            optionNumberLabel.backgroundColor = .customBlue500
            optionNumberLabel.textColor = .white
            optionNumberLabel.layer.borderWidth = 0
        } else {
            self.backgroundColor = .white
            optionNumberLabel.backgroundColor = .white
            optionNumberLabel.textColor = .coolNeutral700
            optionNumberLabel.layer.borderWidth = 1.2
        }
    }

    private func formattedText(_ string: String) -> NSAttributedString {
        let string = NSMutableAttributedString(string: string)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = 8

        string.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.length))

        return string
    }

    private func moveOptionStringLabel(isSqlorFunc: Bool) {
        //
    }
}

// MARK: - AutoLayout
extension QuestionOptionLabel {
    private func addViews() {
        self.addSubview(optionNumberLabel)
        self.addSubview(optionStringLabel)

        optionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        optionStringLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            optionNumberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            optionNumberLabel.widthAnchor.constraint(equalToConstant: 40),
            optionNumberLabel.heightAnchor.constraint(equalTo: optionNumberLabel.widthAnchor),
            optionNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            optionStringLabel.leadingAnchor.constraint(equalTo: optionNumberLabel.trailingAnchor, constant: 16),
            optionStringLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            optionStringLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            optionStringLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
}
