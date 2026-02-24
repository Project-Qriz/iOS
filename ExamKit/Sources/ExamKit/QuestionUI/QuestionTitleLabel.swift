//
//  QuestionTitleLabel.swift
//  ExamKit
//

import UIKit

public final class QuestionTitleLabel: UILabel {

    // MARK: - Initializers
    public init() {
        super.init(frame: .zero)
        self.text = " "
        self.textAlignment = .left
        self.numberOfLines = 0
        self.textColor = .black
        self.font = .systemFont(ofSize: 16, weight: .medium)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionTitleLabel")
    }

    // MARK: - Methods
    public func setTitle(_ text: String) {
        self.attributedText = formattedText(text)
    }

    private func formattedText(_ text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let attributedtext = NSMutableAttributedString(string: text)
        attributedtext.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedtext.length))

        return attributedtext
    }
}
