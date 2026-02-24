//
//  TestTimeLabel.swift
//  QRIZ
//
//  Created by ch on 12/22/24.
//

import UIKit
import DesignSystem

final class TestTimeLabel: UILabel {
    
    init() {
        super.init(frame: .zero)
        self.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        self.textColor = .customRed500
        self.text = "00:00"
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestTimeLabel")
    }
}
