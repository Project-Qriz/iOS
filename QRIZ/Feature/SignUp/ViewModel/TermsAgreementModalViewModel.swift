//
//  TermsAgreementModalViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/15/25.
//

import Foundation
import Combine

final class TermsAgreementModalViewModel {
    
    // MARK: - Properties
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .dismissButtonTapped:
                    outputSubject.send(.dismissModal)
                }
            }
            .store(in: &cancellables)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension TermsAgreementModalViewModel {
    enum Input {
        case dismissButtonTapped
    }
    
    enum Output {
        case dismissModal
    }
}
