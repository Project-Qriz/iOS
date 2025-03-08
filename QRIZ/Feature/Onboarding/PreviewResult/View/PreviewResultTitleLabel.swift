//
//  PreviewResultTitleLabel.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import UIKit

final class PreviewResultTitleLabel: UILabel {
    
    // MARK: - Initializers
    init(isTitleLabel: Bool) {
        super.init(frame: .zero)
        self.text = isTitleLabel ? " 님 의\n 프리뷰 결과에요!" : "님이 틀린문제에\n 자주 등장하는 개념"
        self.font = .boldSystemFont(ofSize: 22)
        self.textColor = .coolNeutral800
        self.textAlignment = .left
        self.numberOfLines = 2
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: PreviewResultTitleLabel")
    }
    
    // MARK: - Method
    func setLabelText(nickname: String, isTitleLabel: Bool) {
        var firstText: String
        var secondText: String

        if isTitleLabel {
            firstText = "\(nickname) 님의\n"
            secondText = "프리뷰 결과에요!"
        } else {
            firstText = "\(nickname)님이 틀린문제에\n"
            secondText = "자주 등장하는 개념"
        }
        
        let fullText = NSMutableAttributedString(string: firstText)
        fullText.append(NSAttributedString(string: secondText))
        
        fullText.addAttribute(.font, value: UIFont.systemFont(ofSize: 22), range: NSRange(location: 0, length: firstText.count))
        fullText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 22), range: NSRange(location: firstText.count, length: secondText.count))
        
        self.attributedText = fullText
    }
}
