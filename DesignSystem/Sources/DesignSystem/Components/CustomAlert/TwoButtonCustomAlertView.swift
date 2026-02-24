//
//  TwoButtonCustomAlertView.swift
//  DesignSystem
//
//  Created by ch on 1/6/25.
//

import UIKit

final class TwoButtonCustomAlertView: UIView {

    // MARK: - Enums

    private enum Metric {
        static let contentInsets: CGFloat = 20
    }

    // MARK: - Properties

    private let confirmTitle: String
    private let cancelTitle: String

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = .coolNeutral800
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
    }()

    private lazy var confirmButton: UIButton = {
        return createButton(
            title: confirmTitle,
            font: UIFont.systemFont(ofSize: 16, weight: .medium),
            titleColor: .white,
            backgroundColor: .customBlue500
        )
    }()

    private lazy var cancelButton: UIButton = {
        return createButton(
            title: cancelTitle,
            font: UIFont.systemFont(ofSize: 16, weight: .medium),
            titleColor: .black,
            backgroundColor: .clear,
            borderColor: .coolNeutral200
        )
    }()

    private lazy var buttonHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    // MARK: - Initializer

    init(
        title: String,
        titleLine: Int = 1,
        description: String,
        descriptionLine: Int = 2,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소"
    ) {
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        super.init(frame: .zero)
        setupUI()
        setLabelText(isTitleLabel: true, text: title, numberOfLines: titleLine)
        setLabelText(isTitleLabel: false, text: description, numberOfLines: descriptionLine)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    func setButtonAction(_ isConfirmButton: Bool, action: UIAction) {
        if isConfirmButton {
            confirmButton.addAction(action, for: .touchUpInside)
        } else {
            cancelButton.addAction(action, for: .touchUpInside)
        }
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
    }

    private func setLabelText(isTitleLabel: Bool, text: String, numberOfLines: Int) {
        if isTitleLabel {
            titleLabel.text = text
            titleLabel.numberOfLines = numberOfLines
        } else {
            descriptionLabel.text = text
            descriptionLabel.numberOfLines = numberOfLines
        }
    }

    private func createButton(
        title: String,
        font: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor = .clear
    ) -> UIButton {
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 6
        let titleStr = NSAttributedString(
            string: title,
            attributes: [
                .font: font,
                .foregroundColor: titleColor
            ]
        )
        button.setAttributedTitle(titleStr, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor.cgColor
        return button
    }
}

// MARK: - Layout Setup

extension TwoButtonCustomAlertView {
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(buttonHStackView)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonHStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.contentInsets),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.contentInsets),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.contentInsets),

            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            buttonHStackView.heightAnchor.constraint(equalToConstant: 40),
            buttonHStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.contentInsets),
            buttonHStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.contentInsets),
            buttonHStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.contentInsets),
            buttonHStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Metric.contentInsets),
        ])
    }
}
