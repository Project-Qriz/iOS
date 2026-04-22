import XCTest
import SnapshotTesting
@testable import MistakeNote

@MainActor
class ProblemDetailSnapshotTests: MistakeNoteSnapshotTestCase {

    func testLoadingState() {
        // fetchDetail이 절대 완료되지 않는 ViewModel → 로딩 상태 유지
        let vm = ProblemDetailViewModel {
            try await neverReturns()
        }
        let vc = ProblemDetailViewController(viewModel: vm)
        let nav = inNav(vc)
        assertSnapshot(of: nav, as: .image(on: .iPhone16Pro))
    }
}
