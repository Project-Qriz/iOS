//
//  RoundButton.swift
//  QRIZ
//
//  Created by KSH on 12/23/24.
//

import UIKit

final class RoundButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
}
