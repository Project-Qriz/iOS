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
/// 이 프로토콜을 채택한 화면에는 `QRIZNavigationController`가 원형 glass 뒤로가기 버튼을
/// 설치하지 않습니다. (단, SwiftUI가 자동으로 켜는 시스템 보조 뒤로가기 표시만큼은 화면이
/// 무엇을 채택했든 항상 꺼줍니다. — SwiftUI가 이건 스스로 관리해주지 않기 때문입니다.)
/// 자체 취소 버튼을 쓰는 시험 화면이나, SwiftUI `.toolbar`로 자기 X 버튼을 넣는 결과 화면처럼
/// 화면 스스로 왼쪽 영역을 책임지는 경우 채택하세요.
@MainActor
public protocol ManagesOwnLeadingBarItem: AnyObject {}

/// iOS 26+에서 시스템 뒤로가기 버튼 뒤에 붙는 glass 캡슐 배경을 없애기 위한 내비게이션 컨트롤러입니다.
///
/// 시스템 뒤로가기의 glass는 끌 수 없고 모양도 캡슐로 고정되어 있어, push되는 화면에 원형 glass
/// 뒤로가기 버튼(`GlassIconButton`)을 대신 답니다. 왼쪽 영역을 직접 관리하는 화면은
/// `ManagesOwnLeadingBarItem`을 채택해 이 컨트롤러가 아예 관여하지 않도록 합니다.
///
/// 스와이프 뒤로가기는 커스텀 왼쪽 버튼 때문에 시스템이 꺼버리므로 직접 복구합니다.
@MainActor
public final class QRIZNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    /// 시스템 glass를 사용하는 OS인지 여부입니다. `false`면 시스템 뒤로가기를 그대로 사용합니다.
    public var usesSystemGlass: Bool = UINavigationBar.supportsSystemGlass

    private enum Attributes {
        static let defaultImageName = "chevron.left"
        static let accessibilityLabel = "뒤로"
    }

    // 값 자체는 쓰지 않고 안정적인 메모리 주소만 연결 키로 사용하므로 동시 접근에 안전하다.
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
            // UIHostingController(SwiftUI 화면)는 왼쪽 버튼을 누가 관리하든(우리든, 화면 자신이든)
            // leftItemsSupplementBackButton을 true로 두어 그 옆에 시스템 뒤로가기를 하나 더 보여준다.
            // 이건 ManagesOwnLeadingBarItem 채택 여부와 무관하게 항상 꺼줘야 하는 유일한 부분이다.
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

    /// SwiftUI가 재렌더링(비동기 데이터 로딩 등) 때마다 이 값을 다시 true로 되돌릴 수 있어,
    /// 화면이 살아있는 동안 계속 false로 유지한다. UIKit 화면은 이 값이 원래 false라 사실상 무해하다.
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
