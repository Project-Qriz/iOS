import XCTest
import SnapshotTesting
@testable import Onboarding

@MainActor
class PreviewTestSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let view = PreviewTestView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.layoutIfNeeded()

        assertSnapshot(of: view, as: .image)
    }
}
