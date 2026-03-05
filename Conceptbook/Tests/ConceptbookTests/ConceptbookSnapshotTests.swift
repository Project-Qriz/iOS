//
//  ConceptbookSnapshotTests.swift
//  ConceptbookTests
//

import XCTest
import iOSSnapshotTestCase
@testable import Conceptbook
import QRIZUtils
import DesignSystem

@MainActor
class ConceptbookSnapshotTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false

        let referenceImagesDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .path
        setenv("FB_REFERENCE_IMAGE_DIR", referenceImagesDir, 1)
    }

    // MARK: - ChapterInfoView

    func testChapterInfoView() {
        let view = ChapterInfoView()
        view.configure(subjectTitle: Chapter.dataModeling.cardTitle, itemCount: Chapter.dataModeling.cardItemCount)
        let size = view.systemLayoutSizeFitting(CGSize(width: 375, height: UIView.layoutFittingCompressedSize.height))
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()

        FBSnapshotVerifyView(view)
    }

    // MARK: - MenuListView

    func testMenuListView() {
        let view = MenuListView()
        view.configure(with: Chapter.dataModeling.conceptItems)
        let size = view.systemLayoutSizeFitting(CGSize(width: 375, height: UIView.layoutFittingCompressedSize.height))
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()

        FBSnapshotVerifyView(view)
    }

    // MARK: - SubjectCardView

    func testSubjectCardView() {
        let view = SubjectCardView(
            image: UIImage.designSystemImage(named: Chapter.dataModeling.assetName),
            title: Chapter.dataModeling.cardTitle,
            itemCount: Chapter.dataModeling.cardItemCount
        )
        let size = view.systemLayoutSizeFitting(CGSize(width: 160, height: UIView.layoutFittingCompressedSize.height))
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()

        FBSnapshotVerifyView(view)
    }
}
