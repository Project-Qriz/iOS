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
protocol ProblemDetailCoordinating: AnyObject {
    func navigateToConceptTab()
    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem)
}

@MainActor
final class ProblemDetailViewController: UIHostingController<ProblemDetailView> {

    weak var coordinator: ProblemDetailCoordinating?
    private let viewModel: ProblemDetailViewModel
    private let input: PassthroughSubject<ProblemDetailViewModel.Input, Never> = .init()
    private let learnButtonTapInput: PassthroughSubject<Void, Never> = .init()
    private let conceptTapInput: PassthroughSubject<String, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ProblemDetailViewModel) {
        self.viewModel = viewModel
        let swiftUIView = ProblemDetailView(
            viewModel: viewModel,
            learnButtonTapInput: learnButtonTapInput,
            conceptTapInput: conceptTapInput
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
        let conceptTapped = conceptTapInput.map { ProblemDetailViewModel.Input.conceptTapped(concept: $0) }
        let mergedInput = input.merge(with: learnButtonTapped, conceptTapped)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .navigateToConceptTab:
                    self.coordinator?.navigateToConceptTab()
                case .navigateToConceptDetail(let chapter, let conceptItem):
                    self.coordinator?.navigateToConcept(chapter: chapter, conceptItem: conceptItem)
                }
            }
            .store(in: &cancellables)
    }
}
