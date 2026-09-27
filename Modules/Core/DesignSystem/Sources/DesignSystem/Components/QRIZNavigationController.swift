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
    final class BackBarButtonItem: UIBarButtonItem {}

    /// KVO 관찰자를 붙들고 있기 위한 상자입니다.
    ///
    /// 관찰자를 뒤로가기 버튼(`BackBarButtonItem`)에 저장하면, SwiftUI가 나중에 자신의 바 버튼으로
    /// 이 아이템을 교체할 때 버튼이 해제되며 관찰도 함께 끊깁니다. 그러면 SwiftUI가 재렌더링(예: 비동기
    /// 데이터 로딩 완료) 시점에 `leftItemsSupplementBackButton`을 다시 true로 되돌려도 아무도 고치지
    /// 못해, 시스템 뒤로가기와 SwiftUI 자체 버튼이 함께 보이는 문제가 생긴다. 그래서 관찰자는 버튼이
    /// 아니라 화면(`UIViewController`) 자체에 연결해 화면이 살아있는 동안 계속 감시하게 한다.
    private final class ObservationBox {
        private let observations: [NSKeyValueObservation]
        fileprivate init(_ observations: [NSKeyValueObservation]) { self.observations = observations }

        // 값 자체는 쓰지 않고 안정적인 메모리 주소만 연결 키로 사용하므로 동시 접근에 안전하다.
        nonisolated(unsafe) private static var associationKey: UInt8 = 0

        static func attach(_ observations: [NSKeyValueObservation], to viewController: UIViewController) {
            objc_setAssociatedObject(
                viewController,
                &associationKey,
                ObservationBox(observations),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    private enum Attributes {
        static let defaultImageName = "chevron.left"
        static let accessibilityLabel = "뒤로"
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
        let hiddenBackButtonObservation = navigationItem.observe(\.hidesBackButton, options: [.new]) { [weak item] navigationItem, change in
            guard change.newValue == true, let item else { return }
            MainActor.assumeIsolated {
                Self.removeItem(item, from: navigationItem)
            }
        }
        // UIHostingController(SwiftUI 화면)는 leftItemsSupplementBackButton을 true로 두어 왼쪽 버튼 옆에
        // 시스템 뒤로가기를 함께 보여준다. 뒤로가기가 두 개 보이지 않도록 계속 false로 유지한다.
        // (SwiftUI가 재렌더링 때마다 이 값을 되돌릴 수 있어, 화면이 살아있는 동안 계속 감시해야 한다.)
        navigationItem.leftItemsSupplementBackButton = false
        let supplementBackButtonObservation = navigationItem.observe(\.leftItemsSupplementBackButton, options: [.new]) { navigationItem, change in
            guard change.newValue == true else { return }
            MainActor.assumeIsolated {
                navigationItem.leftItemsSupplementBackButton = false
            }
        }
        // `leftBarButtonItem`을 설정하면 내부적으로 iOS 16+ `leadingItemGroups`에도 그룹으로 미러링된다.
        // SwiftUI의 `.toolbar { ToolbarItem(placement: .navigationBarLeading) { ... } }`는 이 배열을
        // 교체가 아니라 "추가"하는 방식으로 동작해서, 화면이 자기 왼쪽 버튼을 넣어도 우리 그룹이 그대로
        // 남아 뒤로가기와 화면의 버튼이 함께 보일 수 있다. (이 시점부터는 `leftBarButtonItem`이 항상 nil을
        // 반환해 위 관찰자의 identity 비교가 무력화되므로, leadingItemGroups도 별도로 계속 감시해야 한다.)
        let leadingItemGroupsObservation = navigationItem.observe(\.leadingItemGroups, options: [.new]) { [weak item] navigationItem, _ in
            guard let item, navigationItem.hidesBackButton else { return }
            MainActor.assumeIsolated {
                Self.removeItem(item, from: navigationItem)
            }
        }
        ObservationBox.attach(
            [hiddenBackButtonObservation, supplementBackButtonObservation, leadingItemGroupsObservation],
            to: viewController
        )
        navigationItem.leftBarButtonItem = item
    }

    /// 우리가 설치한 뒤로가기 아이템을 `leftBarButtonItem`과 `leadingItemGroups` 양쪽에서 제거한다.
    private static func removeItem(_ item: UIBarButtonItem, from navigationItem: UINavigationItem) {
        if navigationItem.leftBarButtonItem === item {
            navigationItem.leftBarButtonItem = nil
        }
        let groups = navigationItem.leadingItemGroups
        if groups.contains(where: { $0.barButtonItems.contains(item) }) {
            navigationItem.leadingItemGroups = groups.filter { !$0.barButtonItems.contains(item) }
        }
    }

    private func makeBackItem(imageName: String) -> BackBarButtonItem {
        let button = GlassIconButton(systemImageName: imageName, tintColor: .black) { [weak self] in
            self?.popViewController(animated: true)
        }
        let item = BackBarButtonItem(customView: button)
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
