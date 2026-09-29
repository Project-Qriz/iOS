//
//  QRIZNavigationController.swift
//  DesignSystem
//

import UIKit
import ObjectiveC
import QRIZUtils

/// 뒤로가기 버튼의 아이콘을 직접 지정하고 싶은 화면이 채택합니다. (기본값은 `chevron.left`)
@MainActor
public protocol BackButtonImageProviding: AnyObject {
    var backButtonSystemImageName: String { get }
}

/// 왼쪽 상단 바 버튼(취소, X 등)을 직접 관리하는 화면이 채택합니다.
///
/// 채택하면 `QRIZNavigationController`가 원형 glass 뒤로가기 버튼을 설치하지 않습니다.
/// 자체 취소 버튼을 쓰는 시험 화면, SwiftUI `.toolbar`로 자기 X 버튼을 넣는 결과 화면 등에 사용하세요.
@MainActor
public protocol ManagesOwnLeadingBarItem: AnyObject {}

/// iOS 26+ 시스템 뒤로가기의 캡슐 glass 배경을 원형 glass 버튼(`GlassIconButton`)으로 바꿉니다.
///
/// 왼쪽 영역을 직접 관리하는 화면은 `ManagesOwnLeadingBarItem`을 채택해 설치를 건너뛰게 하세요.
/// 커스텀 왼쪽 버튼을 달면 시스템이 스와이프 뒤로가기를 꺼버리므로 직접 복구합니다.
@MainActor
public final class QRIZNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    /// 시스템 glass를 사용하는 OS인지 여부입니다. `false`면 시스템 뒤로가기를 그대로 사용합니다.
    public var usesSystemGlass: Bool = UINavigationBar.supportsSystemGlass

    private enum Attributes {
        static let defaultImageName = "chevron.left"
        static let accessibilityLabel = "뒤로"
    }

    // 값은 쓰지 않고 주소만 연결 키로 사용하므로 동시 접근에 안전하다.
    nonisolated(unsafe) private static var supplementObservationKey: UInt8 = 0

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        if usesSystemGlass {
            interactivePopGestureRecognizer?.delegate = self
        }
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if usesSystemGlass, !viewControllers.isEmpty {
            suppressSupplementBackButton(on: viewController)
            if !(viewController is ManagesOwnLeadingBarItem) {
                installBackItemIfNeeded(on: viewController)
            }
        }
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Back Button

    func backButtonImageName(for viewController: UIViewController) -> String {
        (viewController as? BackButtonImageProviding)?.backButtonSystemImageName ?? Attributes.defaultImageName
    }

    /// SwiftUI 화면은 시스템 보조 뒤로가기를 자동으로 켜고, 재렌더링마다 다시 켤 수 있어 계속 감시한다.
    /// (UIKit 화면은 원래 꺼져 있어 무해하다. `ManagesOwnLeadingBarItem` 채택 여부와 무관하게 적용한다.)
    private func suppressSupplementBackButton(on viewController: UIViewController) {
        let navigationItem = viewController.navigationItem
        navigationItem.leftItemsSupplementBackButton = false
        let observation = navigationItem.observe(\.leftItemsSupplementBackButton, options: [.new]) { navigationItem, change in
            guard change.newValue == true else { return }
            MainActor.assumeIsolated {
                navigationItem.leftItemsSupplementBackButton = false
            }
        }
        objc_setAssociatedObject(
            viewController,
            &Self.supplementObservationKey,
            observation,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    private func installBackItemIfNeeded(on viewController: UIViewController) {
        let navigationItem = viewController.navigationItem
        guard navigationItem.leftBarButtonItem == nil, !navigationItem.hidesBackButton else { return }

        let button = GlassIconButton(systemImageName: backButtonImageName(for: viewController), tintColor: .black) { [weak self] in
            self?.popViewController(animated: true)
        }
        let item = UIBarButtonItem(customView: button)
        item.accessibilityLabel = Attributes.accessibilityLabel
        item.hidingSharedBackground(usesSystemGlass: true)
        navigationItem.leftBarButtonItem = item
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactivePopGestureRecognizer else { return true }
        guard viewControllers.count > 1, transitionCoordinator == nil,
              let top = topViewController else { return false }

        // 왼쪽 영역을 직접 관리하는 화면(취소 버튼, 뒤로가기 숨김 등)은 스와이프 뒤로가기를 막는다.
        return !(top is ManagesOwnLeadingBarItem)
    }
}
