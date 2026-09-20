//
//  QRIZNavigationController.swift
//  DesignSystem
//

import UIKit
import QRIZUtils

/// 뒤로가기 버튼의 아이콘을 직접 지정하고 싶은 화면이 채택합니다. (기본값은 `chevron.left`)
@MainActor
public protocol BackButtonImageProviding: AnyObject {
    var backButtonSystemImageName: String { get }
}

/// iOS 26+에서 시스템 뒤로가기 버튼 뒤에 붙는 glass 캡슐 배경을 없애기 위한 내비게이션 컨트롤러입니다.
///
/// 시스템 뒤로가기의 glass는 끌 수 없으므로, push되는 화면에 캡슐 없는 커스텀 뒤로가기 버튼을 대신 답니다.
/// 스와이프 뒤로가기는 시스템이 끄기 때문에 직접 복구하되, 원래 막혀 있던 화면(시험 중 취소 버튼 등)은 계속 막습니다.
@MainActor
public final class QRIZNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    /// 시스템 glass를 사용하는 OS인지 여부입니다. `false`면 시스템 뒤로가기를 그대로 사용합니다.
    public var usesSystemGlass: Bool = UINavigationBar.supportsSystemGlass

    /// 이 컨트롤러가 설치한 뒤로가기 버튼을 식별하기 위한 타입입니다.
    final class BackBarButtonItem: UIBarButtonItem {
        /// 화면이 나중에 뒤로가기를 숨기면(예: SwiftUI `navigationBarBackButtonHidden`) 이 버튼을 치우기 위한 관찰자입니다.
        var hiddenBackButtonObservation: NSKeyValueObservation?
    }

    private enum Attributes {
        static let defaultImageName = "chevron.left"
        static let accessibilityLabel = "뒤로"
        /// 시스템 뒤로가기 화살표(약 11.3 x 15.7pt)와 같은 크기/굵기로 맞춘다.
        static let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        /// 바 버튼 아이템의 기본 여백 때문에 시스템 뒤로가기보다 오른쪽에 놓이는 것을 보정한다.
        static let imageAlignmentInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        if usesSystemGlass {
            interactivePopGestureRecognizer?.delegate = self
        }
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if usesSystemGlass, !viewControllers.isEmpty {
            installBackItemIfNeeded(on: viewController)
        }
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Back Button

    func backButtonImageName(for viewController: UIViewController) -> String {
        (viewController as? BackButtonImageProviding)?.backButtonSystemImageName ?? Attributes.defaultImageName
    }

    private func installBackItemIfNeeded(on viewController: UIViewController) {
        let navigationItem = viewController.navigationItem
        guard navigationItem.leftBarButtonItem == nil, !navigationItem.hidesBackButton else { return }

        // hidesBackButton은 건드리지 않는다. 커스텀 왼쪽 버튼이 있으면 시스템 뒤로가기는 자동으로 대체되고,
        // 화면이 나중에 뒤로가기를 숨기려 할 때(true로 변경) 그 변화를 감지할 수 있어야 하기 때문이다.
        let item = makeBackItem(imageName: backButtonImageName(for: viewController))
        item.hiddenBackButtonObservation = navigationItem.observe(\.hidesBackButton, options: [.new]) { [weak item] navigationItem, change in
            guard change.newValue == true else { return }
            MainActor.assumeIsolated {
                guard let item, navigationItem.leftBarButtonItem === item else { return }
                navigationItem.leftBarButtonItem = nil
            }
        }
        navigationItem.leftBarButtonItem = item
    }

    private func makeBackItem(imageName: String) -> BackBarButtonItem {
        let image = UIImage(systemName: imageName, withConfiguration: Attributes.symbolConfiguration)?
            .withAlignmentRectInsets(Attributes.imageAlignmentInsets)
        let item = BackBarButtonItem(
            image: image,
            primaryAction: UIAction { [weak self] _ in
                self?.popViewController(animated: true)
            }
        )
        item.tintColor = .black
        item.accessibilityLabel = Attributes.accessibilityLabel
        item.hidingSharedBackground(usesSystemGlass: true)
        return item
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactivePopGestureRecognizer else { return true }
        guard viewControllers.count > 1, transitionCoordinator == nil,
              let navigationItem = topViewController?.navigationItem else { return false }

        if navigationItem.leftBarButtonItem is BackBarButtonItem { return true }

        // 시스템 규칙 유지: 뒤로가기를 숨기거나 자체 왼쪽 버튼을 쓰는 화면은 스와이프 뒤로가기를 막는다.
        return !navigationItem.hidesBackButton && navigationItem.leftBarButtonItem == nil
    }
}
