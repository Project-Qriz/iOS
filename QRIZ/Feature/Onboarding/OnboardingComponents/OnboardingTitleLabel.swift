//
//  OnboardingTitleLabel.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit

final class OnboardingTitleLabel: UILabel {

    init(labelText: String, fontSize: CGFloat = 28, numberOfLines: Int = 2) {
        super.init(frame: .zero)
        self.text = labelText
        self.textColor = .coolNeutral800
        self.font = .systemFont(ofSize: fontSize, weight: .bold)
        self.textAlignment = .left
        self.numberOfLines = numberOfLines
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnboardingSubtitleLabel")
    }
}
