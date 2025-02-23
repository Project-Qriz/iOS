//
//  QuestionNumberLabel.swift
//  QRIZ
//
//  Created by ch on 12/19/24.
//

import UIKit

final class QuestionNumberLabel: UILabel {
    
    // MARK: - Initializers
    init(_ questionNumber: Int) {
        super.init(frame: .zero)
        setNumber(questionNumber)
        self.textColor = .black
        self.font = .boldSystemFont(ofSize: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionNumberLabel")
    }
    
    // MARK: - Methods
    func setNumber(_ questionNumber: Int) {
        self.text = String(format: "%02d.", questionNumber)
    }
}
