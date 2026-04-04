import UIKit
import Combine
import DesignSystem
import ExamKit
import QRIZUtils



final class ExamTestView: UIView {

    // MARK: - Metric

    private enum Metric {
        static let progressBarHeight: CGFloat = 4
        static let footerHeight: CGFloat = 132
        static let scrollInset: CGFloat = 18
    }
    
    // MARK: - Properties

    var optionTappedPublisher: AnyPublisher<Int, Never> {
        contentsView.optionTappedPublisher
    }

    var prevButtonTappedPublisher: AnyPublisher<Void, Never> {
        footerView.prevButtonTappedPublisher
    }

    var nextButtonTappedPublisher: AnyPublisher<Void, Never> {
        footerView.nextButtonTappedPublisher
    }

    // MARK: - UI

    private let contentsView = TestContentsView()
    private let footerView = ExamTestFooterView()

    private let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.progressTintColor = .customBlue500
        pv.trackTintColor = .coolNeutral200
        return pv
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        return sv
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = .customRed500
        label.text = "00:00"
        return label
    }()

    let totalTimeRemainingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "전체 남은 시간"
        label.textColor = .coolNeutral800
        return label
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

    private func setupUI() {
        backgroundColor = .white
    }

    func updateQuestion(_ question: QuestionData) {
        contentsView.updateQuestion(question)
        footerView.updateCurPage(curPage: question.questionNumber)
        scrollView.setContentOffset(.zero, animated: false)
    }

    func updateTotalPage(_ totalPage: Int) {
        footerView.updateTotalPage(totalPage: totalPage)
    }

    func updateProgress(timeLimit: Int, timeRemaining: Int) {
        progressView.progress = Float(timeRemaining) / Float(timeLimit)
        timeLabel.text = timeRemaining.formattedTime
    }

    func updateOptionState(at optionIdx: Int, isSelected: Bool) {
        contentsView.setOptionState(at: optionIdx, isSelected: isSelected)
    }

    func updatePrevButton(isVisible: Bool) {
        footerView.updatePrevButton(isVisible: isVisible)
    }

    func updateNextButton(isVisible: Bool, isTextSubmit: Bool) {
        footerView.updateNextButton(isVisible: isVisible, isTextSubmit: isTextSubmit)
    }
}

// MARK: - Layout Setup

extension ExamTestView {

    private func addSubviews() {
        [progressView, scrollView, footerView].forEach { addSubview($0) }
        scrollView.addSubview(contentsView)
    }

    private func setupConstraints() {
        [progressView, scrollView, contentsView, footerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: Metric.progressBarHeight),

            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: Metric.footerHeight),

            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.scrollInset),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.scrollInset),
            scrollView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            contentsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentsView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
}
