//
//  UINavigationItem+GlassCloseButton.swift
//  DesignSystem
//

import UIKit
import QRIZUtils

public extension UINavigationItem {
    /// 왼쪽 상단에 원형 glass X 버튼을 설치합니다. (SwiftUI toolbar의 #available 분기는 Release 링크 오류를 일으킴)
    @MainActor
    func setGlassCloseButton(
        tintColor: UIColor = .black,
        accessibilityLabel: String = "닫기",
        action: @escaping () -> Void
    ) {
        let button = GlassIconButton(systemImageName: "xmark", tintColor: tintColor, action: action)
        let item = UIBarButtonItem(customView: button)
        item.accessibilityLabel = accessibilityLabel
        item.hidingSharedBackground(usesSystemGlass: true)
        leftBarButtonItem = item
    }
}
