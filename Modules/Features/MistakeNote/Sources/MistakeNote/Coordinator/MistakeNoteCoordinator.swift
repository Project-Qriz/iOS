//
//  MistakeNoteCoordinator.swift
//  MistakeNote
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit
import QRIZUtils
import QRIZNetwork
import Conceptbook

@MainActor
public protocol MistakeNoteCoordinator: Coordinator {
    var delegate: MistakeNoteCoordinatorDelegate? { get set }
    func showClipDetail(clipId: Int)
}

@MainActor
public protocol MistakeNoteCoordinatorDelegate: AnyObject {
    func moveFromMistakeNoteToConcept(_ coordinator: MistakeNoteCoordinator)
    func moveFromMistakeNoteToExam(_ coordinator: MistakeNoteCoordinator, tab: MistakeNoteTab)
}

@MainActor
public final class MistakeNoteCoordinatorImpl: MistakeNoteCoordinator, NavigationGuard {

    // MARK: - Properties

    public weak var delegate: MistakeNoteCoordinatorDelegate?
    public var childCoordinators: [Coordinator] = []
    public var isNavigating: Bool = false
    private var navigationController: UINavigationController?
    private let service: MistakeNoteService

    // MARK: - Initialization

    public init(service: MistakeNoteService = MistakeNoteServiceImpl()) {
        self.service = service
    }

    // MARK: - Methods

    public func start() -> UIViewController {
        let viewModel = MistakeNoteListViewModel(service: service)
        viewModel.onNavigate = { [weak self] output in
            guard let self else { return }
            switch output {
            case .navigateToClipDetail(let clipId):
                self.showClipDetail(clipId: clipId)
            case .navigateToExam(let tab):
                self.delegate?.moveFromMistakeNoteToExam(self, tab: tab)
            }
        }
        let mistakeNoteVC = MistakeNoteViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: mistakeNoteVC)
        navigationController = nav
        return nav
    }

    public func showClipDetail(clipId: Int) {
        guardNavigation { [service] in
            let viewModel = ProblemDetailViewModel {
                let response = try await service.getClipDetail(clipId: clipId)
                return response.data.toEntity()
            }
            let vc = ProblemDetailViewController(viewModel: viewModel)
            vc.coordinator = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func showConcept(chapter: Chapter, conceptItem: ConceptItem) {
        guardNavigation {
            let vc = makeConceptPDFViewController(chapter: chapter, conceptItem: conceptItem)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

@MainActor
public func makeMistakeNoteCoordinator() -> any MistakeNoteCoordinator {
    MistakeNoteCoordinatorImpl()
}

// MARK: - ProblemDetailCoordinating

extension MistakeNoteCoordinatorImpl: ProblemDetailCoordinating {
    public func navigateToConceptTab() {
        delegate?.moveFromMistakeNoteToConcept(self)
    }

    public func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem) {
        showConcept(chapter: chapter, conceptItem: conceptItem)
    }
}
