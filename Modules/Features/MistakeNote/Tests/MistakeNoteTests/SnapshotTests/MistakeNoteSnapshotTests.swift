import XCTest
import SnapshotTesting
@testable import MistakeNote

@MainActor
class MistakeNoteSnapshotTests: MistakeNoteSnapshotTestCase {

    func testInitialState() {
        let vm = MistakeNoteListViewModel(service: StubMistakeNoteService())
        let vc = MistakeNoteViewController(viewModel: vm)
        let nav = inNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()

        assertSnapshot(of: nav, as: .image)
    }
}
