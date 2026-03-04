//
//  ConceptBookViewModel.swift
//  Conceptbook
//
//  Created by 김세훈 on 4/14/25.
//

import Foundation
import Combine
import QRIZUtils

@MainActor
final class ConceptBookViewModel {

    // MARK: - Properties

    private let subjects: [QRIZUtils.Subject] = QRIZUtils.Subject.allCases
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Functions

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    self.outputSubject.send(.subjectsLoaded(self.subjects))

                case .cardViewTapped(let chapter):
                    self.outputSubject.send(.navigateToChapterDetailView(chapter))
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension ConceptBookViewModel {
    enum Input {
        case viewDidLoad
        case cardViewTapped(Chapter)
    }

    enum Output {
        case subjectsLoaded([QRIZUtils.Subject])
        case navigateToChapterDetailView(Chapter)
    }
}
