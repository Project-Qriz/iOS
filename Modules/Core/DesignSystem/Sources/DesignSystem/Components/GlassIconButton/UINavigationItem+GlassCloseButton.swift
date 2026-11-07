//
//  UINavigationItem+GlassCloseButton.swift
//  DesignSystem
//

import UIKit
import QRIZUtils

public extension UINavigationItem {
    /// 왼쪽 상단에 원형 glass X 버튼을 설치합니다.
    ///
    /// SwiftUI `.toolbar`에서는 시스템 공유 glass 배경을 숨기려면 `ToolbarContentBuilder` 안에서
    /// `#available` 분기가 필요한데, 이 분기는 Release 아카이브에서 링크 오류를 일으킨다.
    /// 그래서 SwiftUI 화면을 감싼 `UIHostingController`가 UIKit 쪽에서 이 메서드로 버튼을 설치한다.
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
