//
//  DailyTestView.swift
//  QRIZ
//

import UIKit
import DesignSystem
import Combine
import ExamKit

final class DailyTestView: UIView {

    // MARK: - Properties

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()

    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .customBlue500
        view.trackTintColor = .coolNeutral200
        return view
    }()

    private let footerView: DailyTestFooterView = .init()
    private let contentsView: TestContentsView = .init()
    private let timerLabel: DailyTestTimerLabel = .init()

    private(set) lazy var timerBarButtonItem = UIBarButtonItem(customView: timerLabel)

    var userInputPublisher: AnyPublisher<DailyTestViewModel.Input, Never> {
        let optionTapped = contentsView.optionTappedPublisher
            .map { DailyTestViewModel.Input.optionTapped(optionIdx: $0) }
        return footerView.input
            .merge(with: optionTapped)
            .eraseToAnyPublisher()
    }

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestView")
    }

    // MARK: - Methods

    func updateQuestion(_ question: QuestionData) {
        contentsView.updateQuestion(question)
        footerView.updateCurPage(curPage: question.questionNumber)
        scrollToTop()
    }

    func updateTotalPage(_ totalPage: Int) {
        footerView.updateTotalPage(totalPage: totalPage)
    }

    func updateProgress(timeLimit: Int, timeRemaining: Int) {
        timerLabel.updateTime(timeRemaining: timeRemaining)
        progressView.progress = Float(timeLimit - timeRemaining) / Float(timeLimit)
    }

    func updateOptionState(at optionIdx: Int, isSelected: Bool) {
        contentsView.setOptionState(at: optionIdx, isSelected: isSelected)
    }

    func setButtonsVisibility(isVisible: Bool) {
        footerView.setButtonsVisibility(isVisible: isVisible)
    }

    func alterButtonText() {
        footerView.alterButtonText()
    }

    private func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: false)
    }
}

// MARK: - Auto Layout

extension DailyTestView {
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
