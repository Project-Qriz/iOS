import UIKit
import Combine
import DesignSystem
import ExamKit
import QRIZUtils

final class PreviewTestView: UIView {

    // MARK: - Metric

    private enum Metric {
        static let progressBarHeight: CGFloat = 4
        static let footerHeight: CGFloat = 108
        static let scrollInset: CGFloat = 18
    }

    // MARK: - Properties

    var optionTappedPublisher: AnyPublisher<Int, Never> {
        contentsView.optionTappedPublisher
    }

    // MARK: - UI

    let progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .customBlue500
        view.trackTintColor = .coolNeutral200
        return view
    }()

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

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        return sv
    }()

    private let contentsView = TestContentsView()

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
        backgroundColor = .white
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func updateQuestion(_ question: QuestionData) {
        contentsView.updateQuestion(question)
        scrollView.setContentOffset(.zero, animated: false)
    }

    func updateOptionState(at index: Int, isSelected: Bool) {
        contentsView.setOptionState(at: index, isSelected: isSelected)
    }

    func updateProgress(timeLimit: Int, timeRemaining: Int) {
        progressView.progress = Float(timeRemaining) / Float(timeLimit)
        timeLabel.text = timeRemaining.formattedTime
    }
}

// MARK: - Layout Setup

private extension PreviewTestView {
    func addSubviews() {
        [progressView, scrollView, pageIndicatorBgView, previousButton, nextButton, pageIndicatorLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        scrollView.addSubview(contentsView)
        contentsView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: Metric.progressBarHeight),

            pageIndicatorBgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageIndicatorBgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageIndicatorBgView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Metric.footerHeight),
            pageIndicatorBgView.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.scrollInset),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.scrollInset),
            scrollView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageIndicatorBgView.topAnchor),

            contentsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentsView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
            contentsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

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
            pageIndicatorLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
    }
}
