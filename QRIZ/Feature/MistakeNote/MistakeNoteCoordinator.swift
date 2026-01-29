//
//  MistakeNoteCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MistakeNoteCoordinator: Coordinator {
    var delegate: MistakeNoteCoordinatorDelegate? { get set }
    func showClipDetail(clipId: Int)
}

@MainActor
protocol MistakeNoteCoordinatorDelegate: AnyObject {
    func moveFromMistakeNoteToConcept(_ coordinator: MistakeNoteCoordinator)
}

@MainActor
final class MistakeNoteCoordinatorImpl: MistakeNoteCoordinator {

    // MARK: - Properties

    weak var delegate: MistakeNoteCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController?
    private let service: MistakeNoteService

    // MARK: - Initializers

    init(service: MistakeNoteService = MistakeNoteServiceImpl()) {
        self.service = service
    }

    // MARK: - Methods

    func start() -> UIViewController {
        let mistakeNoteVC = MistakeNoteViewController()
        mistakeNoteVC.delegate = self
        let nav = UINavigationController(rootViewController: mistakeNoteVC)
        navigationController = nav
        return nav
    }

    func showClipDetail(clipId: Int) {
        let viewModel = ProblemDetailViewModel { [service] in
            let response = try await service.getClipDetail(clipId: clipId)
            return response.data
        }
        let vc = ProblemDetailViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        let vm = ConceptPDFViewModel(chapter: chapter, conceptItem: conceptItem)
        let vc = ConceptPDFViewController(conceptPDFViewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - MistakeNoteViewControllerDelegate

extension MistakeNoteCoordinatorImpl: MistakeNoteViewControllerDelegate {
    func mistakeNoteViewController(
        _ viewController: MistakeNoteViewController,
        didSelectClipWithId clipId: Int
    ) {
        showClipDetail(clipId: clipId)
    }
}

// MARK: - ProblemDetailCoordinating

extension MistakeNoteCoordinatorImpl: ProblemDetailCoordinating {
    func navigateToConceptTab() {
        delegate?.moveFromMistakeNoteToConcept(self)
    }

    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem) {
        showConcept(chapter: chapter, conceptItem: conceptItem)
    }
}
