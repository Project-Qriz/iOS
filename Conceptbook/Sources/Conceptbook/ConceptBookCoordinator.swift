//
//  ConceptBookCoordinator.swift
//  Conceptbook
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit
import QRIZUtils

@MainActor
public protocol ConceptBookCoordinator: Coordinator {
    func showChapterDetailView(chapter: Chapter)
    func showConceptPDFView(chapter: Chapter, conceptItem: ConceptItem)
}

@MainActor
public final class ConceptBookCoordinatorImpl: ConceptBookCoordinator, NavigationGuard {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController?

    // MARK: - NavigationGuard

    public var isNavigating: Bool = false

    // MARK: - Initialize

    public init() {}

    // MARK: - Functions

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
            let conceptPDFVM = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
            let conceptPDFVC = ConceptPDFViewController(conceptPDFViewModel: conceptPDFVM)
            self.navigationController?.pushViewController(conceptPDFVC, animated: true)
        }
    }
}
