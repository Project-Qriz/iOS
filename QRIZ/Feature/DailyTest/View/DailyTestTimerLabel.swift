//
//  DailyTestTimerLabel.swift
//  QRIZ
//
//  Created by ch on 4/6/25.
//

import UIKit

final class DailyTestTimerLabel: UILabel {
    
    // MARK: - Properties
    private let remainingTextLabel: UILabel = {
        let label = UILabel()
        label.text = "문제별 남은시간"
        label.textColor = .coolNeutral700
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.backgroundColor = .white
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customRed500
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        label.backgroundColor = .white
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        updateTime(timeRemaining: 0)
        addViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestTimerLabel")
    }
    
    // MARK: - Methods
    func updateTime(timeRemaining: Int) {
        timerLabel.text = formattedTime(timeRemaining: timeRemaining)
    }
    
    private func formattedTime(timeRemaining: Int) -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
            timerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            remainingTextLabel.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -8),
            remainingTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
