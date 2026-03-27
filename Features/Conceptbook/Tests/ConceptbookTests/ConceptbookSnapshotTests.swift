//
//  ConceptbookSnapshotTests.swift
//  ConceptbookTests
//

import XCTest
import SnapshotTesting
@testable import Conceptbook
import QRIZUtils
import DesignSystem

@MainActor
class ConceptbookSnapshotTests: ConceptbookSnapshotTestCase {

    func testChapterInfoView() {
        let view = ChapterInfoView()
        view.configure(subjectTitle: Chapter.dataModeling.cardTitle, itemCount: Chapter.dataModeling.cardItemCount)
        assertSnapshot(of: snapshotView(view, width: 375), as: .image)
    }

    func testMenuListView() {
        let view = MenuListView()
        view.configure(with: Chapter.dataModeling.conceptItems)
        assertSnapshot(of: snapshotView(view, width: 375), as: .image)
    }

    func testSubjectCardView() {
        let view = SubjectCardView(
            image: UIImage.designSystemImage(named: Chapter.dataModeling.assetName),
            title: Chapter.dataModeling.cardTitle,
            itemCount: Chapter.dataModeling.cardItemCount
        )
        assertSnapshot(of: snapshotView(view, width: 160), as: .image)
    }
}
