// MistakeNote/Tests/MistakeNoteTests/SnapshotTestHelpers.swift

import UIKit
import XCTest

@MainActor
class MistakeNoteSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}

@MainActor
func inNav(_ viewController: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: viewController)
}
