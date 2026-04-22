// MyPage/Tests/MyPageTests/MyPageSnapshotTestCase.swift
import UIKit
import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class MyPageSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro


    /// UIView 서브클래스용: width 고정, height intrinsic sizing
    func snapshotView(_ view: UIView, width: CGFloat = 393) -> UIView {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()
        return view
    }

    /// UICollectionViewCell용: contentView 기준 sizing
    /// 수직 Auto Layout 체인이 완전한 셀(SupportMenuCell)에만 사용.
    /// trailing 누락 또는 수직 체인 불완전한 셀(ProfileCell, QuickActionsCell, SupportHeaderCell)은 explicit frame을 사용.
    func snapshotCell(_ cell: UICollectionViewCell, width: CGFloat = 393) -> UICollectionViewCell {
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        cell.frame = CGRect(origin: .zero, size: size)
        cell.layoutIfNeeded()
        return cell
    }
}

extension ViewImageConfig {
    static let iPhone16Pro = ViewImageConfig(
        safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 393, height: 852),
        traits: UITraitCollection(traitsFrom: [
            UITraitCollection(horizontalSizeClass: .compact),
            UITraitCollection(verticalSizeClass: .regular),
            UITraitCollection(userInterfaceIdiom: .phone),
        ])
    )
}

// 파일 스코프 자유 함수 — @MainActor base class에서만 호출됨
@MainActor
func inNav(_ vc: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: vc)
}
