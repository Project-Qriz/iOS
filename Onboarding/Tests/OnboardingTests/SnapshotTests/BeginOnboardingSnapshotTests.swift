import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class BeginOnboardingSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = BeginOnboardingViewModel(onNavigate: {})
        let vc = UIHostingController(rootView: BeginOnboardingView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
