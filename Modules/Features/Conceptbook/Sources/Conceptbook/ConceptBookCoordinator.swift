//
//  ConceptBookCoordinator.swift
//  Conceptbook
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit
import QRIZUtils
import ConceptbookInterface

@MainActor
public protocol ConceptBookCoordinator: Coordinator {
    func showChapterDetailView(chapter: Chapter)
    func showConceptPDFView(chapter: Chapter, conceptItem: ConceptItem)
}

@MainActor
public final class ConceptBookCoordinatorImpl: ConceptBookCoordinator, NavigationGuard {

    // MARK: - Properties

    private var navigationController: UINavigationController?
    public var isNavigating: Bool = false // NavigationGuard

    // MARK: - Initialization

    public init() {}

    // MARK: - Methods

    public func start() -> UIViewController {
        let conceptBookVM = ConceptBookViewModel()
        let conceptBookVC = ConceptBookViewController(conceptBookVM: conceptBookVM)
        conceptBookVC.coordinator = self
        let nav = UINavigationController(rootViewController: conceptBookVC)
        self.navigationController = nav
        return nav
    }

    public func showChapterDetailView(chapter: Chapter) {
        guardNavigation {
            let chapterDetailVM = ChapterDetailViewModel(chapter: chapter)
            let chapterDetailVC = ChapterDetailViewController(chapterDetailVM: chapterDetailVM)
            chapterDetailVC.hidesBottomBarWhenPushed = true
            chapterDetailVC.coordinator = self
            self.navigationController?.pushViewController(chapterDetailVC, animated: true)
        }
    }

    public func showConceptPDFView(chapter: Chapter, conceptItem: ConceptItem) {
        guardNavigation {
            let conceptPDFVC = makeConceptPDFViewController(chapter: chapter, conceptItem: conceptItem)
            self.navigationController?.pushViewController(conceptPDFVC, animated: true)
        }
    }
}

@MainActor
public func makeConceptBookCoordinator() -> any ConceptBookCoordinator {
    ConceptBookCoordinatorImpl()
}

@MainActor
public func makeConceptPDFViewController(chapter: Chapter, conceptItem: ConceptItem) -> UIViewController {
    let vm = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
    return ConceptPDFViewController(conceptPDFViewModel: vm)
}

public struct DefaultConceptbookFactory: ConceptbookFactory {
    public init() {}

    @MainActor
    public func makeConceptPDFViewController(chapter: Chapter, conceptItem: ConceptItem) -> UIViewController {
        let vm = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        return ConceptPDFViewController(conceptPDFViewModel: vm)
    }
}
