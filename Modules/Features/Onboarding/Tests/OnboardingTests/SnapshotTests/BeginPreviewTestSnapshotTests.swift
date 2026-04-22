import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class BeginPreviewTestSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = BeginPreviewTestViewModel(onNavigate: {})
        let vc = UIHostingController(rootView: BeginPreviewTestView(viewModel: vm))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
