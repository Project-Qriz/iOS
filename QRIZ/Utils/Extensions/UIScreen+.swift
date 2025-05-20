//
//  UIScreen+.swift
//  QRIZ
//
//  Created by 김세훈 on 5/20/25.
//

import UIKit

extension UIScreen {
    
    enum SizeCategory { case se, normal, max }
    
    /// `iPhone SE를 판단하는 계산 프로퍼티입니다.`
    var isSESize: Bool {
        bounds.height <= 667
    }
    
    /// `화면 높이를 기준으로 디바이스를 판별하는 계산 프로퍼티입니다.`
    var sizeCategory: SizeCategory {
        switch bounds.height {
        case ..<700:  return .se
        case 700..<880: return .normal
        default:       return .max
        }
    }
    
    /// `주어진 비율만큼의 화면 높이를 반환하는 메서드입니다.`
    func height(multipliedBy ratio: CGFloat) -> CGFloat {
        bounds.height * ratio
    }
}
