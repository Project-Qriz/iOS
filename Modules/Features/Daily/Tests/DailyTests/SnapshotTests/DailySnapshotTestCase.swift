import UIKit
import XCTest
import SnapshotTesting
@testable import Daily

@MainActor
class DailySnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}

extension ViewImageConfig {
    static let iPhone16Pro = ViewImageConfig(
        safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 393, height: 852),
        traits: UITraitCollection(traitsFrom: [
            UITraitCollection(horizontalSizeClass: .compact),
            UITraitCollection(verticalSizeClass: .regular),
            UITraitCollection(userInterfaceIdiom: .phone),
        ])
    )
}

@MainActor
func inDailyNav(_ vc: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: vc)
}
