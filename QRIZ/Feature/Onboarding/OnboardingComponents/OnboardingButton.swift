//
//  OnboardingButton.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit

final class OnboardingButton: UIButton {

    init(_ titleText: String) {
        super.init(frame: .zero)
        self.setTitle(titleText, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.backgroundColor = .customBlue500
        self.layer.cornerRadius = 8

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 4, height: 6)
        self.layer.shadowRadius = 4
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnboardingButton")
    }
    
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
