import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class BeginOnboardingSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = BeginOnboardingViewModel(onNavigate: {})
        let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
