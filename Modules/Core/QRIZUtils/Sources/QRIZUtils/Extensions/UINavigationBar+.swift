//
//  UINavigationBar+.swift
//  QRIZUtils
//
//  Created by 김세훈 on 1/8/25.
//

import UIKit

public extension UINavigationBar {
    /// 시스템 Liquid Glass(iOS 26+)를 사용할 수 있는지 여부입니다.
    static var supportsSystemGlass: Bool {
        if #available(iOS 26, *) { true } else { false }
    }

    /// `커스텀 뒤로가기 버튼이 적용된 UINavigationBarAppearance를 생성하여 반환합니다.`
    ///
    /// 시스템 glass를 사용하는 경우 `backgroundColor`, `hidesShadow`는 무시되며
    /// 배경과 경계 표현은 시스템에 맡깁니다.
    static func defaultBackButtonStyle(
        systemImageName: String = "chevron.left",
        tintColor: UIColor = .black,
        backgroundColor: UIColor = .white,
        hidesShadow: Bool = false,
        usesSystemGlass: Bool = UINavigationBar.supportsSystemGlass
    ) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()

        if usesSystemGlass {
            appearance.configureWithDefaultBackground()
        } else {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            if hidesShadow {
                appearance.shadowColor = .clear
            }
        }

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
