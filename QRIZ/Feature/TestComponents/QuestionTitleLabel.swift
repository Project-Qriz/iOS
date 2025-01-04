//
//  QuestionTitleLabel.swift
//  QRIZ
//
//  Created by ch on 12/20/24.
//

import UIKit

final class QuestionTitleLabel: UILabel {
    init(_ titleStr: String) {
        super.init(frame: .zero)
        self.text = titleStr
        self.textAlignment = .left
        self.numberOfLines = 0
        self.textColor = .black
        self.font = .boldSystemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionTitleLabel")
    }
    
    func setTitle(_ titleStr: String) {
        self.text = titleStr
    }
}
