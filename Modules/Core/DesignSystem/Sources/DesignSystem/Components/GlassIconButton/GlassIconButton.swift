//
//  GlassIconButton.swift
//  DesignSystem
//

import UIKit

/// 아이콘 하나를 원형 glass 배경 위에 올려 보여주는 버튼입니다. (iOS 26+)
///
/// iOS 26 미만에서는 glass 재질 없이 아이콘만 노출합니다.
/// 내비게이션 바 `leftBarButtonItem`의 customView로 쓸 경우, 시스템이 자동으로 씌우는
/// 공유 glass 배경과 겹치지 않도록 해당 바 버튼 아이템에 `hidingSharedBackground()`를 함께 적용하세요.
@MainActor
public final class GlassIconButton: UIButton {

    private let action: (() -> Void)?

    public init(
        systemImageName: String,
        pointSize: CGFloat = 17,
        diameter: CGFloat = 44,
        tintColor: UIColor = .black,
        action: (() -> Void)? = nil
    ) {
        self.action = action
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: diameter).isActive = true
        heightAnchor.constraint(equalToConstant: diameter).isActive = true

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        let image = UIImage(systemName: systemImageName, withConfiguration: symbolConfiguration)

        if #available(iOS 26.0, *) {
            var config = UIButton.Configuration.glass()
            config.image = image
            config.baseForegroundColor = tintColor
            config.cornerStyle = .capsule
            configuration = config
        } else {
            setImage(image?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
        }

        addAction(UIAction { [weak self] _ in self?.action?() }, for: .touchUpInside)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
