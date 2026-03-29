//
//  DailyTestTimerLabel.swift
//  QRIZ
//
//  Created by ch on 4/6/25.
//

import UIKit
import DesignSystem

final class DailyTestTimerLabel: UILabel {

    // MARK: - enum

    private enum Metric {
        static let fontSize: CGFloat = 14
        static let labelSpacing: CGFloat = 8
    }

    // MARK: - Properties

    private let remainingTextLabel: UILabel = {
        let label = UILabel()
        label.text = "문제별 남은시간"
        label.textColor = .coolNeutral700
        label.font = .systemFont(ofSize: Metric.fontSize, weight: .regular)
        label.backgroundColor = .white
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customRed500
        label.font = .monospacedDigitSystemFont(ofSize: Metric.fontSize, weight: .semibold)
        label.backgroundColor = .white
        return label
    }()

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        addViews()
        updateTime(timeRemaining: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestTimerLabel")
    }

    // MARK: - Methods

    func updateTime(timeRemaining: Int) {
        timerLabel.text = timeRemaining.formattedTime
    }
}

// MARK: - Auto Layout

extension DailyTestTimerLabel {
    private func addViews() {
        addSubview(remainingTextLabel)
        addSubview(timerLabel)

        remainingTextLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            remainingTextLabel.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -Metric.labelSpacing),
            remainingTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
