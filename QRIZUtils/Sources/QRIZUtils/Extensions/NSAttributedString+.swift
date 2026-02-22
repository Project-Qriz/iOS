//
//  UILabel+.swift
//  QRIZUtils
//
//  Created by 김세훈 on 1/22/25.
//

import UIKit

public extension NSAttributedString {
    /// 행간이 적용된 NSAttributedString을 생성합니다.
    convenience init(text: String, lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        self.init(
            string: text,
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }
}
