//
//  TestProgressView.swift
//  QRIZ
//
//  Created by ch on 12/22/24.
//

import UIKit

final class TestProgressView: UIProgressView {
    
    init() {
        super.init(frame: .zero)
        self.progressTintColor = .customBlue500
        self.trackTintColor = .coolNeutral200
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestProgressView")
    }
}
