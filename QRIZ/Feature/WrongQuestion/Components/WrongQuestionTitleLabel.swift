//
//  WrongQuesetionTitleLabel.swift
//  QRIZ
//
//  Created by ch on 1/15/25.
//

import UIKit

final class WrongQuestionTitleLabel: UILabel {

    init() {
        super.init(frame: .zero)
        font = .boldSystemFont(ofSize: 18)
        textColor = .coolNeutral800
        textAlignment = .center
        text = "오답노트"
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
