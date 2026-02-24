//
//  TestTotalTimeRemainingLabel.swift
//  ExamKit
//

import UIKit
import DesignSystem

public final class TestTotalTimeRemainingLabel: UILabel {

    public init() {
        super.init(frame: .zero)
        self.font = .systemFont(ofSize: 14)
        self.text = "전체 남은 시간"
        self.textColor = .coolNeutral800
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestTotalTimeRemainingLabel")
    }
}
