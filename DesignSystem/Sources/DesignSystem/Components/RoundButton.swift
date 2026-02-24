//
//  RoundButton.swift
//  DesignSystem
//
//  Created by KSH on 12/23/24.
//

import UIKit

public final class RoundButton: UIButton {
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
}
