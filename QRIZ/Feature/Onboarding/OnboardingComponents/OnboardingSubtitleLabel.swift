//
//  OnboardingSubtitleLabel.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit

final class OnboardingSubtitleLabel: UILabel {

    // MARK: - Initializers
    init(_ labelText: String) {
        super.init(frame: .zero)
        self.attributedText = formattedText(labelText)
        self.textColor = .coolNeutral500
        self.font = .systemFont(ofSize: 16) // need font
        self.textAlignment = .left
        self.numberOfLines = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnboardingSubtitleLabel")
    }
    
    // MARK: - Methods
    private func formattedText(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
