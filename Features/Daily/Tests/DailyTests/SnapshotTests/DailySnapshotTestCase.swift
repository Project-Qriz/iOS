import UIKit
import XCTest
import SnapshotTesting
@testable import Daily

@MainActor
class DailySnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}

@MainActor
func inDailyNav(_ vc: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: vc)
}
