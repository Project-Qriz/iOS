//
//  UILabel+.swift
//  QRIZ
//
//  Created by 김세훈 on 1/22/25.
//

import UIKit

extension UILabel {
    /// 행간 조정을 도와주는  메서드입니다.
    static func setLineSpacing(_ spacing: CGFloat, text: String) -> NSAttributedString {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineSpacing = spacing
        
      return NSAttributedString(
        string: text,
        attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
      )
    }
}
