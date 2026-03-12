// MistakeNote/Tests/MistakeNoteTests/SnapshotTests/ProblemDetailSnapshotTests.swift

import XCTest
import SnapshotTesting
@testable import MistakeNote

@MainActor
class ProblemDetailSnapshotTests: MistakeNoteSnapshotTestCase {

    func testLoadingState() {
        // fetchDetail이 절대 완료되지 않는 ViewModel → 로딩 상태 유지
        let vm = ProblemDetailViewModel {
            try await Task.sleep(nanoseconds: 999_999_999_999)
            throw URLError(.cancelled)
        }
        let vc = ProblemDetailViewController(viewModel: vm)
        let nav = inNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()

        assertSnapshot(of: nav, as: .image)
    }
}
