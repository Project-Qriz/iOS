import SwiftUI
import XCTest
import SnapshotTesting
@testable import Home

@MainActor
final class ReviewRequestPopupSnapshotTests: HomeSnapshotTestCase {

    func testInitialState() {
        let view = ReviewRequestPopupView(onPostpone: {}, onReview: {})
        let vc = UIHostingController(rootView: view)
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
