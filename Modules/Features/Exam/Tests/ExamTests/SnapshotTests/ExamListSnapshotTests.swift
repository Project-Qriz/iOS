import UIKit
import XCTest
import SnapshotTesting
@testable import Exam
import Network
import QRIZUtils

@MainActor
class ExamListSnapshotTests: ExamSnapshotTestCase {

    // MARK: - Helpers

    private func makeConfiguredNav(
        filterType: ExamListFilterType = .total,
        isFilterVisible: Bool = false
    ) -> UINavigationController {
        let examListView = ExamListView()
        examListView.selectFilterItem(filterType)
        examListView.setFilterItemsVisibility(isVisible: isFilterVisible)

        let vc = UIViewController()
        vc.view = examListView

        let titleLabel = UILabel()
        titleLabel.text = "모의고사"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        vc.navigationItem.titleView = titleLabel

        let nav = inExamNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        return nav
    }

    // MARK: - ExamListView 상태 스냅샷

    func testExamListView_empty() {
        let nav = makeConfiguredNav()
        assertSnapshot(of: nav, as: .image)
    }

    func testExamListView_filterVisible() {
        let nav = makeConfiguredNav(isFilterVisible: true)
        assertSnapshot(of: nav, as: .image)
    }

    func testExamListView_incompleteFilter() {
        let nav = makeConfiguredNav(filterType: .incomplete)
        assertSnapshot(of: nav, as: .image)
    }

    func testExamListView_completedFilter() {
        let nav = makeConfiguredNav(filterType: .completed)
        assertSnapshot(of: nav, as: .image)
    }

    func testExamListView_sortByDateFilter() {
        let nav = makeConfiguredNav(filterType: .sortByDate)
        assertSnapshot(of: nav, as: .image)
    }

    // MARK: - ExamListCell 스냅샷

    func testExamListCell_incomplete() {
        let cell = ExamListCell()
        // 셀 너비: 393 - 18(leading) - 18(trailing) = 357
        cell.frame = CGRect(x: 0, y: 0, width: 357, height: 116)
        cell.configure(isCompleted: false, examRound: 1, score: nil)
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    func testExamListCell_completed() {
        let cell = ExamListCell()
        cell.frame = CGRect(x: 0, y: 0, width: 357, height: 116)
        cell.configure(isCompleted: true, examRound: 3, score: 75.0)
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }
}
