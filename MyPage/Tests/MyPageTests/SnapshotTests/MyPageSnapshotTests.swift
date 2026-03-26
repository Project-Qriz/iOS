// MyPage/Tests/MyPageTests/SnapshotTests/MyPageSnapshotTests.swift
import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class MyPageSnapshotTests: MyPageSnapshotTestCase {

    // MARK: - ViewController

    /// viewDidLoad → Task { fetchVersion() } fire-and-forget이므로 async 대기 필요.
    /// nav.view.frame 설정 → viewDidLoad 호출 → async Task 시작
    /// Task.sleep 이후 applySnapshot 완료 → 재레이아웃 후 스냅샷
    func testInitialState() async throws {
        let vm = MyPageViewModel(userName: "테스트", myPageService: MockMyPageService())
        let vc = MyPageViewController(viewModel: vm)
        let nav = inNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        nav.view.layoutIfNeeded()
        assertSnapshot(of: nav, as: .image)
    }

    // MARK: - 셀 컴포넌트

    /// ProfileCell: trailing 미연결 → explicit frame으로 full-width snapshot 보장
    /// height 60 = 22pt bold 레이블 높이 + 상하 여백
    func testProfileCell() {
        let cell = ProfileCell()
        cell.configure(with: "테스트")
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 60))
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    /// QuickActionsCell: centerY만 있어 contentView 수직 체인 불완전 → explicit frame 사용
    /// height 82 = MyPageLayoutFactory.quickActionEstimated
    /// configureActions는 액션 콜백용이므로 snapshot에서 호출 불필요
    func testQuickActionsCell() {
        let cell = QuickActionsCell()
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 82))
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    /// SupportHeaderCell: titleLabel.bottom 미연결 → explicit frame 사용
    /// height 70 = titleLabel 상단 여백(24) + 폰트 높이(≈21) + 하단 여백 + separator(1)
    func testSupportHeaderCell() {
        let cell = SupportHeaderCell()
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 70))
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    /// SupportMenuCell (version 없음): chevron 표시, versionLabel 숨김
    func testSupportMenuCell_withoutVersion() {
        let cell = SupportMenuCell()
        cell.configure(title: "서비스 이용약관")
        assertSnapshot(of: snapshotCell(cell), as: .image)
    }

    /// SupportMenuCell (version 있음): versionLabel 표시, chevron 숨김
    func testSupportMenuCell_withVersion() {
        let cell = SupportMenuCell()
        cell.configure(title: "버전 정보", version: "1.0.0")
        assertSnapshot(of: snapshotCell(cell), as: .image)
    }
}
