//
//  ExamScheduleCardCell.swift
//  QRIZ
//
//  Created by 김세훈 on 4/26/25.
//

import UIKit
import DesignSystem
import Combine

final class ExamScheduleCardCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let defaultMargin: CGFloat = 24.0
        static let separatorTopOffset: CGFloat = 14.5
        static let separatorHeight: CGFloat = 1.0
        static let statusLabelTopOffset: CGFloat = 16.0
        static let suggestionLabelTopOffset: CGFloat = 10.0
        static let actionButtonTopOffset: CGFloat = 16.0
        static let actionButtonHeightMultiple: CGFloat = 40 / 291
    }

    // MARK: - Properties

    private let buttonTapSubject = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()

    var buttonTapPublisher: AnyPublisher<Void, Never> {
        buttonTapSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        label.numberOfLines = 2
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue100
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 바로 등록할까요?"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("등록하기", for: .normal)
        button.setTitleColor(.coolNeutral800, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.coolNeutral200.cgColor
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTapSubject.send()
        }, for: .touchUpInside)
        return button
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

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.coolNeutral100.cgColor
    }

    func configure(userName: String? = nil, statusText: String) {
        let titleText = userName.map { "\($0)님의\n시험 일정을 등록해보세요!" } ?? "앗,\n등록했던 시험일이 지났어요."
        titleLabel.attributedText = NSAttributedString(text: titleText, lineSpacing: 6)
        statusLabel.text = statusText
    }
}

// MARK: - Layout Setup

extension ExamScheduleCardCell {
    private func addSubviews() {
        [
            titleLabel,
            separator,
            statusLabel,
            suggestionLabel,
            actionButton
        ].forEach(contentView.addSubview(_:))
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.defaultMargin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.defaultMargin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.defaultMargin),

            separator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.separatorTopOffset),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.defaultMargin),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.defaultMargin),
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight),

            statusLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: Metric.statusLabelTopOffset),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.defaultMargin),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.defaultMargin),

            suggestionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: Metric.suggestionLabelTopOffset),
            suggestionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.defaultMargin),
            suggestionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.defaultMargin),

            actionButton.topAnchor.constraint(equalTo: suggestionLabel.bottomAnchor, constant: Metric.actionButtonTopOffset),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.defaultMargin),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.defaultMargin),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.defaultMargin),
            actionButton.heightAnchor.constraint(equalTo: actionButton.widthAnchor, multiplier: Metric.actionButtonHeightMultiple)
        ])
    }
}
