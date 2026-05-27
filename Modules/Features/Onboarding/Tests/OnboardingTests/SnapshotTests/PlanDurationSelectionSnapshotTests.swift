import XCTest
import SnapshotTesting
import SwiftUI
import QRIZUtils
@testable import Onboarding

@MainActor
class PlanDurationSelectionSnapshotTests: OnboardingSnapshotTestCase {

    private func makeSUT(selectedPlan: PlanOption? = nil) -> UIHostingController<PlanDurationSelectionView> {
        let vm = PlanDurationSelectionViewModel(
            dailyService: MockDailyService(),
            onNavigate: {}
        )
        if let plan = selectedPlan {
            vm.didSelectPlan(plan)
        }
        return UIHostingController(rootView: PlanDurationSelectionView(viewModel: vm))
    }

    func testInitialState() {
        assertSnapshot(of: makeSUT(), as: .image(on: .iPhone16Pro))
    }

    func testSevenDaySelected() {
        assertSnapshot(of: makeSUT(selectedPlan: .sevenDay), as: .image(on: .iPhone16Pro))
    }

    func testFourteenDaySelected() {
        assertSnapshot(of: makeSUT(selectedPlan: .fourteenDay), as: .image(on: .iPhone16Pro))
    }

    func testThirtyDaySelected() {
        assertSnapshot(of: makeSUT(selectedPlan: .thirtyDay), as: .image(on: .iPhone16Pro))
    }
}
