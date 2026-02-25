//
//  TestButton.swift
//  ExamKit
//

import UIKit
import DesignSystem

public final class TestButton: UIButton {

    // MARK: - Initializers
    public init(isPreviousButton: Bool) {
        super.init(frame: .zero)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        layer.cornerRadius = 8

        if isPreviousButton {
            setTitle("이전", for: .normal)
            setTitleColor(.coolNeutral500, for: .normal)
            backgroundColor = .coolNeutral200
        } else {
            setTitle("다음", for: .normal)
            setTitleColor(.white, for: .normal)
            backgroundColor = .coolNeutral700
        }
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestButton")
    }

    // MARK: - Methods
    public func setTitleText(_ str: String) {
        setTitle(str, for: .normal)
    }
}
