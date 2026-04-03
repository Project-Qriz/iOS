import UIKit
import XCTest
import SnapshotTesting
@testable import Exam

@MainActor
class ExamSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}

@MainActor
func inExamNav(_ vc: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: vc)
}
