import UIKit
import XCTest
import SnapshotTesting
import QRIZUtils
@testable import Home

@MainActor
class PlanChangeSnapshotTests: HomeSnapshotTestCase {

    // MARK: - Helpers

    // Note: makeKeyAndVisible()을 호출하지 않아 safeAreaLayoutGuide 인셋이 0으로 렌더링됨.
    // 실기기 레이아웃과 다를 수 있으나 프로젝트 전체 스냅샷 테스트의 공통 전제임.
    private func makeView(
        currentPlan: PlanOption?,
        availablePlans: [PlanOption],
        selectedPlan: PlanOption? = nil,
        confirmEnabled: Bool = false
    ) -> PlanChangeMainView {
        let view = PlanChangeMainView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.applyCurrentPlan(currentPlan)
        view.applyAvailablePlans(availablePlans)
        if let selected = selectedPlan {
            view.applySelection(selected)
        }
        view.setConfirmEnabled(confirmEnabled)
        view.layoutIfNeeded()
        return view
    }

    // MARK: - Snapshot Tests

    func testPlanChange_loaded_sevenDayCurrent_noSelection() {
        let view = makeView(
            currentPlan: .sevenDay,
            availablePlans: [.fourteenDay, .thirtyDay]
        )
        assertSnapshot(of: view, as: .image)
    }

    func testPlanChange_loaded_sevenDayCurrent_fourteenDaySelected() {
        let view = makeView(
            currentPlan: .sevenDay,
            availablePlans: [.fourteenDay, .thirtyDay],
            selectedPlan: .fourteenDay,
            confirmEnabled: true
        )
        assertSnapshot(of: view, as: .image)
    }

    func testPlanChange_loaded_thirtyDayCurrent_noAvailablePlans() {
        let view = makeView(
            currentPlan: .thirtyDay,
            availablePlans: []
        )
        assertSnapshot(of: view, as: .image)
    }

    func testPlanChange_loaded_fourteenDayCurrent_thirtyDaySelected() {
        let view = makeView(
            currentPlan: .fourteenDay,
            availablePlans: [.sevenDay, .thirtyDay],
            selectedPlan: .thirtyDay,
            confirmEnabled: true
        )
        assertSnapshot(of: view, as: .image)
    }
}
