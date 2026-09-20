//
//  ToolbarContent+Glass.swift
//  DesignSystem
//

import SwiftUI

public extension ToolbarContent {
    /// iOS 26+에서 툴바 아이템 뒤에 자동으로 붙는 glass 캡슐 배경을 숨깁니다.
    ///
    /// 아이템 자체는 그대로 노출되며, iOS 25 이하에서는 아무것도 하지 않습니다.
    @ToolbarContentBuilder
    func hidingSharedBackground() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            self.sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
