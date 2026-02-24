//
//  TestTimeLabel.swift
//  ExamKit
//

import UIKit
import DesignSystem

public final class TestTimeLabel: UILabel {

    public init() {
        super.init(frame: .zero)
        self.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        self.textColor = .customRed500
        self.text = "00:00"
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestTimeLabel")
    }
}
