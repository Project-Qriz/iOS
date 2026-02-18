//
//  UINavigationBar+.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import UIKit

public extension UINavigationBar {
    /// `커스텀 뒤로가기 버튼이 적용된 UINavigationBarAppearance를 생성하여 반환합니다.`
    static func defaultBackButtonStyle(
        systemImageName: String = "chevron.left",
        tintColor: UIColor = .black
    ) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
            .font: UIFont.systemFont(ofSize: 0.0)
        ]

        if let backImage = UIImage(systemName: systemImageName)?
            .withTintColor(tintColor, renderingMode: .alwaysOriginal)
        {
            let offsetImage = backImage.withAlignmentRectInsets(
                UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
            )
            appearance.setBackIndicatorImage(offsetImage, transitionMaskImage: offsetImage)
        }

        return appearance
    }
}
