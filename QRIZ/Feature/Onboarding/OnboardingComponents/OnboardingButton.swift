//
//  OnboardingButton.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit

final class OnboardingButton: UIButton {

    // MARK: - Initializers
    init(_ titleText: String) {
        super.init(frame: .zero)
        self.setTitle(titleText, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.backgroundColor = .customBlue500
        self.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnboardingButton")
    }
    
    // MARK: - Methods
    func setButtonState(isActive: Bool) {
        if isActive {
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = .customBlue500
        } else {
            self.setTitleColor(.coolNeutral500, for: .normal)
            self.backgroundColor = .coolNeutral200
        }
    }
}
