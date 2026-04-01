import UIKit
import XCTest
import SnapshotTesting
@testable import Home

@MainActor
class DaySelectBottomSheetSnapshotTests: HomeSnapshotTestCase {

    private let sheetSize = CGSize(width: 393, height: 275)

    // MARK: - Helpers

    private func makeVC(
        totalDays: Int,
        initialSelected: Int = 0,
        todayIndex: Int? = nil
    ) -> DaySelectBottomSheetViewController {
        let viewModel = DaySelectBottomSheetViewModel(
            totalDays: totalDays,
            initialSelected: initialSelected,
            todayIndex: todayIndex
        )
        let vc = DaySelectBottomSheetViewController(viewModel: viewModel)
        vc.view.frame = CGRect(origin: .zero, size: sheetSize)
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.view.layoutIfNeeded()
        return vc
    }

    // MARK: - Snapshot Tests

    func testDaySelectBottomSheet_week1_firstDay() {
        let vc = makeVC(totalDays: 14, initialSelected: 0, todayIndex: 0)
        assertSnapshot(of: vc.view, as: .image)
    }

    func testDaySelectBottomSheet_week2_selected() {
        let vc = makeVC(totalDays: 14, initialSelected: 9, todayIndex: 2)
        assertSnapshot(of: vc.view, as: .image)
    }

    func testDaySelectBottomSheet_singleWeek_lastDay() {
        let vc = makeVC(totalDays: 5, initialSelected: 4, todayIndex: 4)
        assertSnapshot(of: vc.view, as: .image)
    }
}
