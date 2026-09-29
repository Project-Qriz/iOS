//
//  View+GlassIconButton.swift
//  DesignSystem
//

import SwiftUI

/// SwiftUI `Button`을 iOS 26+ glass 재질의 원형 버튼으로 만듭니다.
///
/// iOS 25 이하에서는 지정한 크기의 프레임만 적용하고 glass 스타일은 적용하지 않습니다.
private struct GlassIconButtonStyle: ViewModifier {
    let diameter: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .frame(width: diameter, height: diameter)
        } else {
            content
                .frame(width: diameter, height: diameter)
        }
    }
}

public extension View {
    /// 이 뷰(주로 아이콘 하나를 담은 `Button`)를 원형 glass 버튼으로 스타일링합니다.
    func glassIconButtonStyle(diameter: CGFloat = 44) -> some View {
        modifier(GlassIconButtonStyle(diameter: diameter))
    }
}
