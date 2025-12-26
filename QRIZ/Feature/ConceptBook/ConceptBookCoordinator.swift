//
//  ConceptBookCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol ConceptBookCoordinator: Coordinator {
    func showChapterDetailView(chapter: Chapter)
    func showConceptPDFView(chapter: Chapter,conceptItem: ConceptItem)
}

@MainActor
final class ConceptBookCoordinatorImpl: ConceptBookCoordinator, NavigationGuard {

    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController?

    // NavigationGuard
    var isNavigating: Bool = false
    
    func start() -> UIViewController {
        let conceptBookVM = ConceptBookViewModel()
        let conceptBookVC = ConceptBookViewController(conceptBookVM: conceptBookVM)
        conceptBookVC.coordinator = self
        let nav = UINavigationController(rootViewController: conceptBookVC)
        self.navigationController = nav
        return nav
    }
    
    func showChapterDetailView(chapter: Chapter) {
        guardNavigation {
            let chapterDetailVM = ChapterDetailViewModel(chapter: chapter)
            let chapterDetailVC = ChapterDetailViewController(chapterDetailVM: chapterDetailVM)
            chapterDetailVC.hidesBottomBarWhenPushed = true
            chapterDetailVC.coordinator = self
            navigationController?.pushViewController(chapterDetailVC, animated: true)
        }
    }

    func showConceptPDFView(chapter: Chapter,conceptItem: ConceptItem) {
        guardNavigation {
            let conceptPDFVM = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
            let conceptPDFVC = ConceptPDFViewController(conceptPDFViewModel: conceptPDFVM)
            navigationController?.pushViewController(conceptPDFVC, animated: true)
        }
    }
}
