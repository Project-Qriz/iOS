import XCTest
import SnapshotTesting
@testable import MistakeNote

@MainActor
class MistakeNoteSnapshotTests: MistakeNoteSnapshotTestCase {

    func testInitialState() {
        let vm = MistakeNoteListViewModel(service: StubMistakeNoteService())
        let vc = MistakeNoteViewController(viewModel: vm)
        let nav = inNav(vc)
        assertSnapshot(of: nav, as: .image(on: .iPhone16Pro))
    }
}
