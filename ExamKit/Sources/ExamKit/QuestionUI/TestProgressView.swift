//
//  TestProgressView.swift
//  ExamKit
//

import UIKit
import DesignSystem

public final class TestProgressView: UIProgressView {

    public init() {
        super.init(frame: .zero)
        self.progressTintColor = .customBlue500
        self.trackTintColor = .coolNeutral200
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestProgressView")
    }
}
