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
}

@MainActor
final class ConceptBookCoordinatorImp: ConceptBookCoordinator {
    
    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController?
    
    func start() -> UIViewController {
        let conceptBookVM = ConceptBookViewModel()
        let conceptBookVC = ConceptBookViewController(conceptBookVM: conceptBookVM)
        conceptBookVC.coordinator = self
        let nav = UINavigationController(rootViewController: conceptBookVC)
        self.navigationController = nav
        return nav
    }
    
    func showChapterDetailView(chapter: Chapter) {
        let chapterDetailVM = ChapterDetailViewModel(chapter: chapter)
        let chapterDetailVC = ChapterDetailViewController(chapterDetailVM: chapterDetailVM)
        navigationController?.pushViewController(chapterDetailVC, animated: true)
    }
}
