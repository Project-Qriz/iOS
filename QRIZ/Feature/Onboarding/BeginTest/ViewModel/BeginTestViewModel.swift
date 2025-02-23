//
//  BeginTestViewModel.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import Foundation
import Combine

final class BeginTestViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case didButtonClicked
    }
    
    enum Output {
        case moveToPreviewTest
    }
    
    // MARK: - Properties
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didButtonClicked:
                self.output.send(.moveToPreviewTest)
            }
        }
        .store(in: &subscriptions)

        return output.eraseToAnyPublisher()
    }
}
