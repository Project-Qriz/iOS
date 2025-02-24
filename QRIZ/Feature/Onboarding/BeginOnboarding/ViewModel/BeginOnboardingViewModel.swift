//
//  BeginOnboardingViewModel.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import Foundation
import Combine

final class BeginOnboardingViewModel {

    enum Input {
        case didButtonClicked
    }
    
    enum Output {
        case moveToCheckConcept
    }

    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didButtonClicked:
                self.output.send(.moveToCheckConcept)
            }
        }
        .store(in: &subscriptions)

        return output.eraseToAnyPublisher()
    }
}
