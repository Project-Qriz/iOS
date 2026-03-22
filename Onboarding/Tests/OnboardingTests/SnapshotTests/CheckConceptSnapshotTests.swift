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
            onNavigate: { _ in }
        )
        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }

    func testWithSomeSelected() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in }
        )
        vm.didTapConcept(at: 0)
        vm.didTapConcept(at: 5)
        vm.didTapConcept(at: 10)

        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }

    func testAllSelected() {
        let vm = CheckConceptViewModel(
            onboardingService: MockOnboardingService(),
            onNavigate: { _ in }
        )
        vm.didTapAll()

        let vc = UIHostingController(rootView: CheckConceptView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
