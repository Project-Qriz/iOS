//
//  TestTotalTimeRemainingLabel.swift
//  QRIZ
//
//  Created by ch on 12/22/24.
//

import UIKit

final class TestTotalTimeRemainingLabel: UILabel {
    
    init() {
        super.init(frame: .zero)
        self.font = .systemFont(ofSize: 14)
        self.text = "전체 남은 시간"
        self.textColor = .coolNeutral800
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestTotalTimeRemainingLabel")
    }
}
