import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class PlanDurationSelectionSnapshotTests: OnboardingSnapshotTestCase {

    private func makeSUT(selectedPlanType: Int? = nil) -> UIHostingController<PlanDurationSelectionView> {
        let vm = PlanDurationSelectionViewModel(
            dailyService: MockDailyService(),
            onNavigate: {}
        )
        if let planType = selectedPlanType {
            vm.didSelectPlan(planType)
        }
        return UIHostingController(rootView: PlanDurationSelectionView(viewModel: vm))
    }

    func testInitialState() {
        assertSnapshot(of: makeSUT(), as: .image(on: .iPhone16Pro))
    }

    func testSevenDaySelected() {
        assertSnapshot(of: makeSUT(selectedPlanType: 7), as: .image(on: .iPhone16Pro))
    }

    func testFourteenDaySelected() {
        assertSnapshot(of: makeSUT(selectedPlanType: 14), as: .image(on: .iPhone16Pro))
    }

    func testThirtyDaySelected() {
        assertSnapshot(of: makeSUT(selectedPlanType: 30), as: .image(on: .iPhone16Pro))
    }
}
