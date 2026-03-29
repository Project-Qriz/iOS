import UIKit
import DesignSystem
import ExamKit
import QRIZUtils

final class ExamTestView: UIView {

    // MARK: - Views
    let footerView = ExamTestFooterView()
    private(set) var contentsView: TestContentsView!
    private(set) var progressView: UIProgressView!
    private(set) var timeLabel: UILabel!
    private(set) var totalTimeRemainingLabel: UILabel!
    private(set) var scrollView: UIScrollView!

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupSubviews()
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamTestView")
    }

    // MARK: - Setup
    private func setupSubviews() {
        let pv = UIProgressView()
        pv.progressTintColor = .customBlue500
        pv.trackTintColor = .coolNeutral200
        progressView = pv

        let sv = UIScrollView()
        sv.backgroundColor = .white
        scrollView = sv

        contentsView = TestContentsView()

        let tl = UILabel()
        tl.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        tl.textColor = .customRed500
        tl.text = "00:00"
        timeLabel = tl

        let ttl = UILabel()
        ttl.font = .systemFont(ofSize: 14)
        ttl.text = "전체 남은 시간"
        ttl.textColor = .coolNeutral800
        totalTimeRemainingLabel = ttl
    }

    // MARK: - Update Methods
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

// MARK: - AutoLayout
extension ExamTestView {
    private func addViews() {
        addSubview(progressView)
        addSubview(scrollView)
        scrollView.addSubview(contentsView)
        addSubview(footerView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 132),

            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
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
