//
//  TestPreviousButton.swift
//  QRIZ
//
//  Created by ch on 12/19/24.
//

import UIKit

final class TestButton: UIButton {

    init(isPreviousButton: Bool) {

        super.init(frame: .zero)
        self.titleLabel?.font = .boldSystemFont(ofSize: 16)
        self.layer.cornerRadius = 8

        if isPreviousButton {
            self.setTitle("이전", for: .normal)
            self.setTitleColor(.coolNeutral500, for: .normal)
            self.backgroundColor = .coolNeutral200
        } else {
            self.setTitle("다음", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = .coolNeutral700
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestButton")
    }
    
    func setTitleText(_ str: String) {
        self.setTitle(str, for: .normal)
    }
}
