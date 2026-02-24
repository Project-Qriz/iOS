//
//  QuestionNumberLabel.swift
//  ExamKit
//

import UIKit

public final class QuestionNumberLabel: UILabel {

    // MARK: - Initializers
    public init() {
        super.init(frame: .zero)
        setNumber(1)
        self.textColor = .black
        self.font = .boldSystemFont(ofSize: 20)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionNumberLabel")
    }

    // MARK: - Methods
    public func setNumber(_ questionNumber: Int) {
        self.text = String(format: "%02d.", questionNumber)
    }
}
