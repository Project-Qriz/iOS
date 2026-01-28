//
//  MistakeNoteCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MistakeNoteCoordinator: Coordinator {
    func showClipDetail(clipId: Int)
}

@MainActor
final class MistakeNoteCoordinatorImpl: MistakeNoteCoordinator {

    // MARK: - Properties

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
