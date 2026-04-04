import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class BeginPreviewTestSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = BeginPreviewTestViewModel(onNavigate: {})
        let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
