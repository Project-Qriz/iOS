import XCTest
import SwiftUI
import SnapshotTesting
@testable import Daily
import QRIZUtils

@MainActor
class DailyResultSnapshotTests: DailySnapshotTestCase {

    // MARK: - Helpers

    private func makeViewModel(type: DailyLearnType = .daily) -> DailyResultViewModel {
        DailyResultViewModel(dailyTestType: type, day: 1, dailyService: MockDailyService())
    }

    private func populate(
        _ vm: DailyResultViewModel,
        passed: Bool,
        subjectCount: Int = 2
    ) {
        vm.resultScoresData.nickname = "홍길동"
        vm.resultScoresData.subjectCount = subjectCount
        vm.resultScoresData.passed = passed
        vm.resultScoresData.dayNum = "DAY 1"
        vm.resultScoresData.subjectScores[0] = passed ? 85.0 : 45.0
        vm.resultScoresData.subjectScores[1] = passed ? 80.0 : 40.0
        vm.resultGradeListData.gradeResultList = [
            GradeResult(id: 1, questionId: 1, skillName: "DDL", question: "CREATE 문법을 올바르게 작성하시오.", correction: true),
            GradeResult(id: 2, questionId: 2, skillName: "DML", question: "SELECT 절에서 DISTINCT 키워드 사용법", correction: passed),
            GradeResult(id: 3, questionId: 3, skillName: "DCL", question: "GRANT 권한 부여 구문", correction: false),
        ]
    }

    private func makeSnapshotNav(_ vm: DailyResultViewModel) -> UINavigationController {
        let hostingVC = UIHostingController(rootView: DailyResultView(viewModel: vm))
        let nav = inDailyNav(hostingVC)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        return nav
    }

    // MARK: - Daily 타입

    func testDailyResultView_daily_passed() {
        let vm = makeViewModel(type: .daily)
        populate(vm, passed: true)
        assertSnapshot(of: makeSnapshotNav(vm), as: .image)
    }

    func testDailyResultView_daily_failed() {
        let vm = makeViewModel(type: .daily)
        populate(vm, passed: false)
        assertSnapshot(of: makeSnapshotNav(vm), as: .image)
    }

    // MARK: - Weekly 타입 (상세보기 버튼 포함)

    func testDailyResultView_weekly_passed() {
        let vm = makeViewModel(type: .weekly)
        populate(vm, passed: true)
        assertSnapshot(of: makeSnapshotNav(vm), as: .image)
    }

    func testDailyResultView_weekly_failed() {
        let vm = makeViewModel(type: .weekly)
        populate(vm, passed: false)
        assertSnapshot(of: makeSnapshotNav(vm), as: .image)
    }
}
