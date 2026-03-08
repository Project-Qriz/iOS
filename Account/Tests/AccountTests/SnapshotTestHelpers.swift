//
//  SnapshotTestHelpers.swift
//  AccountTests
//

import UIKit
import XCTest

@MainActor
func inNav(_ viewController: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: viewController)
}

@MainActor
class AccountSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}
