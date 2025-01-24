//
//  OnlyIncorrectMenuItem.swift
//  QRIZ
//
//  Created by 이창현 on 1/22/25.
//

import UIKit

final class WrongQuestionMenuItem: UILabel {

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .white
        font = .systemFont(ofSize: 14, weight: .medium)
        textColor = .coolNeutral800
        textAlignment = .left
        text = title
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
