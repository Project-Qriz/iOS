import XCTest
import SnapshotTesting
import SwiftUI
@testable import MistakeNote
import QRIZUtils

@MainActor
class SubjectFilterSheetSnapshotTests: MistakeNoteSnapshotTestCase {

    private func makeVC(
        availableConcepts: Set<String> = ["엔터티", "속성", "관계", "식별자"],
        initialSelectedConcepts: Set<String> = []
    ) -> UIViewController {
        let view = SubjectFilterSheet(
            isPresented: .constant(true),
            availableConcepts: availableConcepts,
            initialSubject: .one,
            initialSelectedConcepts: initialSelectedConcepts
        )
        return UIHostingController(rootView: view)
    }

    func testInitialState() {
        let vc = makeVC()
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }

    func testWithSelectedConcepts() {
        let vc = makeVC(initialSelectedConcepts: ["엔터티", "속성"])
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
