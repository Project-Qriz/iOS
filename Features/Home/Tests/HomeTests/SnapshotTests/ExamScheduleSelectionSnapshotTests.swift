import UIKit
import XCTest
import SnapshotTesting
@testable import Home
import QRIZUtils

@MainActor
class ExamScheduleSelectionSnapshotTests: HomeSnapshotTestCase {

    // MARK: - Helpers

    private func makeView(rows: [ExamRowState] = []) -> ExamScheduleSelectionMainView {
        let view = ExamScheduleSelectionMainView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.updateExamList(rows: rows)
        view.layoutIfNeeded()
        return view
    }

    private func makeRows(count: Int, selectedId: Int? = nil) -> [ExamRowState] {
        (1...max(1, count)).map { i in
            ExamRowState(
                id: i,
                examName: "2026년 \(i)회",
                periodText: "접수기간: 2026.0\(i).01~2026.0\(i).10",
                dateText: "시험일: 2026-0\(i)-30",
                isSelected: i == selectedId,
                isExpired: false
            )
        }
    }

    // MARK: - Snapshot Tests

    func testExamScheduleSelectionView_empty() {
        let view = makeView(rows: [])
        assertSnapshot(of: view, as: .image)
    }

    func testExamScheduleSelectionView_multipleRows() {
        let view = makeView(rows: makeRows(count: 3))
        assertSnapshot(of: view, as: .image)
    }

    func testExamScheduleSelectionView_withSelectedRow() {
        let view = makeView(rows: makeRows(count: 3, selectedId: 2))
        assertSnapshot(of: view, as: .image)
    }

    func testExamScheduleSelectionView_expiredRow() {
        let rows = [
            ExamRowState(
                id: 1,
                examName: "2025년 1회",
                periodText: "접수기간: 2025.01.01~2025.01.10",
                dateText: "시험일: 2025-03-01",
                isSelected: false,
                isExpired: true
            ),
            ExamRowState(
                id: 2,
                examName: "2026년 1회",
                periodText: "접수기간: 2026.01.01~2026.01.10",
                dateText: "시험일: 2026-12-31",
                isSelected: true,
                isExpired: false
            )
        ]
        let view = makeView(rows: rows)
        assertSnapshot(of: view, as: .image)
    }
}
