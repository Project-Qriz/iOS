//
//  OnboardingSubtitleLabel.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit

final class OnboardingSubtitleLabel: UILabel {

    init(_ labelText: String) {
        super.init(frame: .zero)
        self.text = labelText
        self.textColor = .coolNeutral500
        self.font = .systemFont(ofSize: 16) // need font
        self.textAlignment = .left
        self.numberOfLines = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnboardingTitleLabel")
    }
}
