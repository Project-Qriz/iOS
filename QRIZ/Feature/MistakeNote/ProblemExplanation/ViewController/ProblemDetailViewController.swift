//
//  ProblemDetailViewController.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import UIKit
import SwiftUI
import Combine

@MainActor
final class ProblemDetailViewController: UIHostingController<ProblemDetailView> {

    weak var coordinator: MistakeNoteCoordinator?
    private let viewModel: ProblemDetailViewModel
    private let input: PassthroughSubject<ProblemDetailViewModel.Input, Never> = .init()
    private let learnButtonTapInput: PassthroughSubject<Void, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let onNavigateToConcept: () -> Void

    init(viewModel: ProblemDetailViewModel, onNavigateToConcept: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onNavigateToConcept = onNavigateToConcept
        let swiftUIView = ProblemDetailView(
            viewModel: viewModel,
            learnButtonTapInput: learnButtonTapInput
        )
        super.init(rootView: swiftUIView)
        self.hidesBottomBarWhenPushed = true
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        input.send(.viewDidLoad)
    }

    private func bind() {
        let learnButtonTapped = learnButtonTapInput.map { ProblemDetailViewModel.Input.learnButtonTapped }
        let mergedInput = input.merge(with: learnButtonTapped)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .navigateToConcept:
                    self.onNavigateToConcept()
                }
            }
            .store(in: &cancellables)
    }
}
