import UIKit
import DesignSystem
import ExamKit

final class PreviewTestView: UIView {

    // MARK: - UI

    let progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .customBlue500
        view.trackTintColor = .coolNeutral200
        return view
    }()

    let questionNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    let questionTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    let optionLabels: [QuestionOptionLabel] = (1...4).map { QuestionOptionLabel(number: $0) }

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.coolNeutral800, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()

    let totalTimeRemainingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "전체 남은 시간"
        label.textColor = .coolNeutral800
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = .customRed500
        label.text = "00:00"
        return label
    }()

    private let pageIndicatorBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.customBlue100.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 16
        return view
    }()

    let previousButton = TestButton(isPreviousButton: true)
    let nextButton = TestButton(isPreviousButton: false)
    let pageIndicatorLabel = TestPageIndicatorLabel()

    // MARK: - Initializers

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

    private func setupUI() {
        backgroundColor = .white
    }
}

// MARK: - Layout Setup

private extension PreviewTestView {
    private func addSubviews() {
        let views: [UIView] = [
            progressView, questionNumberLabel, questionTitleLabel,
            pageIndicatorBgView, previousButton, nextButton, pageIndicatorLabel
        ] + optionLabels
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        setupProgressViewConstraints()
        setupQuestionSectionConstraints()
        setupOptionLabelsConstraints()
        setupBottomSectionConstraints()
    }

    private func setupProgressViewConstraints() {
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func setupQuestionSectionConstraints() {
        NSLayoutConstraint.activate([
            questionNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            questionNumberLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),

            questionTitleLabel.leadingAnchor.constraint(equalTo: questionNumberLabel.leadingAnchor),
            questionTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            questionTitleLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 14)
        ])
    }

    private func setupOptionLabelsConstraints() {
        optionLabels.forEach {
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
                $0.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18)
            ])
        }
        optionLabels.first?.topAnchor.constraint(equalTo: questionTitleLabel.bottomAnchor, constant: 26).isActive = true
        zip(optionLabels, optionLabels.dropFirst()).forEach { prev, curr in
            curr.topAnchor.constraint(equalTo: prev.bottomAnchor).isActive = true
        }
    }

    private func setupBottomSectionConstraints() {
        NSLayoutConstraint.activate([
            pageIndicatorBgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageIndicatorBgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageIndicatorBgView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -108),
            pageIndicatorBgView.bottomAnchor.constraint(equalTo: bottomAnchor),

            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            previousButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
            previousButton.widthAnchor.constraint(equalToConstant: 90),
            previousButton.heightAnchor.constraint(equalToConstant: 48),

            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 90),
            nextButton.heightAnchor.constraint(equalToConstant: 48),

            pageIndicatorLabel.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor),
            pageIndicatorLabel.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            pageIndicatorLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
