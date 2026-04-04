import XCTest
import SnapshotTesting
@testable import Daily
import QRIZUtils

@MainActor
class DailyLearnSnapshotTests: DailySnapshotTestCase {

    // MARK: - Helpers

    private func makeConfiguredNav(
        state: DailyTestState,
        type: DailyLearnType = .daily,
        score: Double? = nil
    ) -> UINavigationController {
        let dailyLearnView = DailyLearnView()
        dailyLearnView.configure(state: state, type: type, score: score)

        let vc = UIViewController()
        vc.view = dailyLearnView

        let titleLabel = UILabel()
        titleLabel.text = "오늘의 공부"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        vc.navigationItem.titleView = titleLabel

        let nav = inDailyNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        return nav
    }

    // MARK: - DailyLearnView state 별 스냅샷

    func testDailyLearnView_unavailable() {
        let nav = makeConfiguredNav(state: .unavailable)
        assertSnapshot(of: nav, as: .image)
    }

    func testDailyLearnView_zeroAttempt() {
        let nav = makeConfiguredNav(state: .zeroAttempt)
        assertSnapshot(of: nav, as: .image)
    }

    func testDailyLearnView_passed() {
        let nav = makeConfiguredNav(state: .passed, score: 85.0)
        assertSnapshot(of: nav, as: .image)
    }

    func testDailyLearnView_retestRequired() {
        let nav = makeConfiguredNav(state: .retestRequired, score: 55.0)
        assertSnapshot(of: nav, as: .image)
    }

    func testDailyLearnView_failed() {
        let nav = makeConfiguredNav(state: .failed, score: 40.0)
        assertSnapshot(of: nav, as: .image)
    }

    // MARK: - DailyLearnType 별 타이틀

    func testDailyLearnView_weeklyType() {
        let nav = makeConfiguredNav(state: .zeroAttempt, type: .weekly)
        assertSnapshot(of: nav, as: .image)
    }

    func testDailyLearnView_monthlyType() {
        let nav = makeConfiguredNav(state: .zeroAttempt, type: .monthly)
        assertSnapshot(of: nav, as: .image)
    }

    // MARK: - StudyContentCell

    func testStudyContentCell() {
        let cell = StudyContentCell()
        // 셀 너비: 393 - 18(leading) - 18(trailing) = 357
        cell.frame = CGRect(x: 0, y: 0, width: 357, height: 116)
        cell.configure(
            title: "1. 데이터베이스 기본 개념",
            description: "관계형 데이터베이스의 기본 개념과 SQL 문법을 학습합니다."
        )
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }
}
