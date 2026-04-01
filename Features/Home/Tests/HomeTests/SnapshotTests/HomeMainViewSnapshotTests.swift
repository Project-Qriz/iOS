import UIKit
import XCTest
import SnapshotTesting
@testable import Home
import QRIZUtils

@MainActor
class HomeMainViewSnapshotTests: HomeSnapshotTestCase {

    // MARK: - Helpers

    // Note: makeKeyAndVisible()을 호출하지 않아 safeAreaLayoutGuide 인셋이 0으로 렌더링됨.
    // 실기기 레이아웃과 다를 수 있으나 프로젝트 전체 스냅샷 테스트의 공통 전제임.
    private func makeView(state: HomeState) -> HomeMainView {
        let view = HomeMainView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.apply(state)
        view.layoutIfNeeded()
        return view
    }

    private func makeState(
        userName: String = "홍길동",
        examStatus: ExamStatus = .none,
        entryState: EntryCardState = .mock,
        dailyPlans: [DailyPlanEntity] = [],
        selectedIndex: Int = 0
    ) -> HomeState {
        HomeState(
            userName: userName,
            examStatus: examStatus,
            entryState: entryState,
            dailyPlans: dailyPlans,
            selectedIndex: selectedIndex
        )
    }

    private func makePlan(id: Int, completed: Bool = false, today: Bool = false) -> DailyPlanEntity {
        DailyPlanEntity(
            id: id,
            dayNumber: "Day\(id)",
            completed: completed,
            planDate: "2026-04-01",
            completionDate: nil,
            plannedSkills: [],
            reviewDay: false,
            comprehensiveReviewDay: false,
            today: today,
            lastDay: false
        )
    }

    // MARK: - Snapshot Tests

    func testHomeMainView_previewLocked() {
        let state = makeState(entryState: .preview)
        let view = makeView(state: state)
        assertSnapshot(of: view, as: .image)
    }

    func testHomeMainView_examNone_noPlans() {
        let state = makeState(examStatus: .none, entryState: .mock)
        let view = makeView(state: state)
        assertSnapshot(of: view, as: .image)
    }

    func testHomeMainView_examRegistered_withPlans() {
        let detail = ExamDetail(examDateText: "2026-12-31", examName: "2026년 1회", applyPeriod: "2026.01.01~2026.01.10")
        let state = makeState(
            examStatus: .registered(dDay: 30, detail: detail),
            entryState: .mock,
            dailyPlans: (1...3).map { makePlan(id: $0, today: $0 == 1) },
            selectedIndex: 0
        )
        let view = makeView(state: state)
        assertSnapshot(of: view, as: .image)
    }
}
