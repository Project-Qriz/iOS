//
//  UINavigationBar+.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import UIKit

extension UINavigationBar {
    /// `전체 네비게이션 뒤로가기 버튼을 설정해주는 함수입니다.`
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
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        {
            let offsetImage = backImage.withAlignmentRectInsets(
                UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
            )
            appearance.setBackIndicatorImage(offsetImage, transitionMaskImage: offsetImage)
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        return appearance
    }
}
