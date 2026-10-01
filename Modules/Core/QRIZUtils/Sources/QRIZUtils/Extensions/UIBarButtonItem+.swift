//
//  UIBarButtonItem+.swift
//  QRIZUtils
//

import UIKit

public extension UIBarButtonItem {
    /// iOS 26+에서 바 버튼 아이템 뒤에 자동으로 붙는 glass 캡슐 배경을 숨깁니다.
    ///
    /// 버튼 자체는 그대로 노출되며, glass를 지원하지 않는 OS에서는 아무것도 하지 않습니다.
    @discardableResult
    func hidingSharedBackground(
        usesSystemGlass: Bool = UINavigationBar.supportsSystemGlass
    ) -> Self {
        if usesSystemGlass, #available(iOS 26.0, *) {
            hidesSharedBackground = true
        }
        return self
    }
}
