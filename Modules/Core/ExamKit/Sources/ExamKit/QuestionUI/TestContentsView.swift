//
//  TestContentsView.swift
//  ExamKit
//

import UIKit
import Combine
import QRIZUtils
import DesignSystem

public final class TestContentsView: UIView {

    // MARK: - Properties

    private let optionTappedSubject = PassthroughSubject<Int, Never>()

    public var optionTappedPublisher: AnyPublisher<Int, Never> {
        optionTappedSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private let outerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    private let questionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue50
        view.layer.cornerRadius = 16
        return view
    }()

    private let questionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customBlue500
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .coolNeutral800
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let descriptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.coolNeutral200.cgColor
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .coolNeutral700
        return label
    }()

    private let optionLabels: [QuestionOptionLabel] = (1...4).map { QuestionOptionLabel(number: $0) }

    // MARK: - Initialization

    public init() {
        super.init(frame: .zero)
        addSubviews()
        setupOptionGestures()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestContentsView")
    }

    // MARK: - Methods

    public func updateQuestion(_ question: QuestionData) {
        numberLabel.text = String(format: "%02d.", question.questionNumber)
        titleLabel.attributedText = NSAttributedString(text: question.question, lineSpacing: 4)
        descriptionView.isHidden = question.description == nil
        descriptionLabel.attributedText = question.description.map { NSAttributedString(text: $0, lineSpacing: 4) }
        optionLabels.enumerated().forEach { index, label in
            label.setOptionState(isSelected: false)
            label.setOptionString(question.getOptionRawValue(option: index + 1))
        }
    }

    public func setOptionState(at index: Int, isSelected: Bool) {
        optionLabels[index - 1].setOptionState(isSelected: isSelected)
    }

    private func setupOptionGestures() {
        optionLabels.enumerated().forEach { index, label in
            label.onTap = { [weak self] in
                self?.optionTappedSubject.send(index + 1)
            }
        }
    }
}

// MARK: - Layout Setup

extension TestContentsView {
    private func addSubviews() {
        addSubview(outerStackView)
        outerStackView.addArrangedSubview(questionCardView)
        questionCardView.addSubview(questionStackView)
        [numberLabel, titleLabel, descriptionView].forEach { questionStackView.addArrangedSubview($0) }
        descriptionView.addSubview(descriptionLabel)
        optionLabels.forEach { outerStackView.addArrangedSubview($0) }

        questionStackView.setCustomSpacing(8, after: numberLabel)
        questionStackView.setCustomSpacing(16, after: titleLabel)
    }

    private func setupConstraints() {
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        questionStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            outerStackView.topAnchor.constraint(equalTo: topAnchor),
            outerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            questionStackView.topAnchor.constraint(equalTo: questionCardView.topAnchor, constant: 24),
            questionStackView.leadingAnchor.constraint(equalTo: questionCardView.leadingAnchor, constant: 24),
            questionStackView.trailingAnchor.constraint(equalTo: questionCardView.trailingAnchor, constant: -24),
            questionStackView.bottomAnchor.constraint(equalTo: questionCardView.bottomAnchor, constant: -24),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -16),
        ])
    }
}

