//
//  UIViewController+.swift
//  QRIZ
//
//  Created by 김세훈 on 1/7/25.
//

import UIKit

extension UIViewController {
    /// `네비게이션 바의 타이틀을 설정을 도와주는 함수입니다.`
    func setNavigationBarTitle(
        title: String,
        font: UIFont? = UIFont.systemFont(ofSize: 18, weight: .bold),
        textColor: UIColor? = .coolNeutral800
    ) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = textColor
        self.navigationItem.titleView = titleLabel
    }
}
