import UIKit
import XCTest
import SnapshotTesting
@testable import Exam

@MainActor
class ExamSummarySnapshotTests: ExamSnapshotTestCase {

    // MARK: - Helpers

    // Note: makeKeyAndVisible()을 호출하지 않아 safeAreaLayoutGuide 인셋이 0으로 렌더링됨.
    // 실기기 레이아웃과 다를 수 있으나 프로젝트 전체 스냅샷 테스트의 공통 전제임.
    private func makeConfiguredNav(examId: Int = 1) -> UINavigationController {
        let vm = ExamSummaryViewModel(examId: examId)
        let vc = ExamSummaryViewController(viewModel: vm)

        let nav = inExamNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        return nav
    }

    // MARK: - ExamSummaryView 스냅샷

    func testExamSummaryView() {
        let view = ExamSummaryView()
        // Note: safeAreaLayoutGuide 인셋 0 (window 미연결)
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.layoutIfNeeded()
        assertSnapshot(of: view, as: .image)
    }

    // MARK: - ExamSummaryViewController 스냅샷

    func testExamSummaryViewController() {
        let nav = makeConfiguredNav()
        assertSnapshot(of: nav, as: .image)
    }
}
