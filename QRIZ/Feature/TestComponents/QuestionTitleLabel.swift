//
//  QuestionTitleLabel.swift
//  QRIZ
//
//  Created by ch on 12/20/24.
//

import UIKit

final class QuestionTitleLabel: UILabel {
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        self.text = " "
        self.textAlignment = .left
        self.numberOfLines = 0
        self.textColor = .black
        self.font = .boldSystemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionTitleLabel")
    }
    
    // MARK: - Methods
    func setTitle(_ titleStr: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let attributedtext = NSMutableAttributedString(string: titleStr)
        attributedtext.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedtext.length))

        self.attributedText = attributedtext
    }
}
