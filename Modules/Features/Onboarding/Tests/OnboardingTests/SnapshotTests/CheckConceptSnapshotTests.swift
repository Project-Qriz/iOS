import XCTest
import SnapshotTesting
import SwiftUI
import Network
@testable import Onboarding

@MainActor
class CheckConceptSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in },
            userInfo: .shared
        )
        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testWithSomeSelected() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in },
            userInfo: .shared
        )
        vm.didTapConcept(at: 0)
        vm.didTapConcept(at: 5)
        vm.didTapConcept(at: 10)

        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testAllSelected() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in },
            userInfo: .shared
        )
        vm.didTapAll()

        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
