//
//  TestContentsView.swift
//  ExamKit
//

import UIKit
import Combine
import QRIZUtils
import DesignSystem

public final class TestContentsView: UIStackView {

    // MARK: - Properties

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let descriptionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.coolNeutral200.cgColor
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()

    private let optionLabels: [QuestionOptionLabel] = (1...4).map {
        let option = QuestionOptionLabel(number: $0)
        option.tag = $0
        return option
    }

    private let optionTappedSubject: PassthroughSubject<Int, Never> = .init()
    public var optionTappedPublisher: AnyPublisher<Int, Never> {
        optionTappedSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    public init() {
        super.init(frame: .zero)
        setupUI()
        addSubviews()
        setupConstraints()
        setupOptionGestures()
    }

    required init(coder: NSCoder) {
        fatalError("no initializer for coder: TestContentsView")
    }

    // MARK: - Methods

    public func updateQuestion(_ question: QuestionData) {
        numberLabel.text = String(format: "%02d.", question.questionNumber)
        titleLabel.attributedText = lineSpaced(question.question)
        if let description = question.description {
            descriptionView.isHidden = false
            descriptionLabel.attributedText = lineSpaced(description)
        } else {
            descriptionView.isHidden = true
        }
        let options = [question.option1, question.option2, question.option3, question.option4]
        optionLabels.forEach {
            $0.setOptionState(isSelected: false)
            $0.setOptionString(options[$0.tag - 1])
        }
    }

    public func setOptionState(at index: Int, isSelected: Bool) {
        optionLabels[index - 1].setOptionState(isSelected: isSelected)
    }

    private func setupUI() {
        axis = .vertical
        alignment = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 35, left: 0, bottom: 35, right: 0)
    }

    private func lineSpaced(_ text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.length))
        return attributed
    }

    private func setupOptionGestures() {
        optionLabels.forEach {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:))))
        }
    }

    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        optionTappedSubject.send(index)
    }
}

// MARK: - Layout

extension TestContentsView {
    private func addSubviews() {
        addArrangedSubview(numberLabel)
        addArrangedSubview(titleLabel)
        addArrangedSubview(descriptionView)
        descriptionView.addSubview(descriptionLabel)
        for option in optionLabels {
            addArrangedSubview(option)
        }
    }

    private func setupConstraints() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -16)
        ])

        setCustomSpacing(14, after: numberLabel)
        setCustomSpacing(14, after: titleLabel)
        setCustomSpacing(16, after: descriptionView)
    }
}
