//
//  SnapshotTestHelpers.swift
//  ConceptbookTests
//

import UIKit
import XCTest

@MainActor
class ConceptbookSnapshotTestCase: XCTestCase {
    func snapshotView(_ view: UIView, width: CGFloat = 375) -> UIView {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()
        return view
    }
}
