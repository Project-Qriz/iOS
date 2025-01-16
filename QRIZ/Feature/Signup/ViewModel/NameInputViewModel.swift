//
//  NameInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/7/25.
//

import Foundation
import Combine

final class NameInputViewModel {
    
    // MARK: - Properties
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .nameTextChanged(let text):
                    self.validateName(text)
                case .buttonTapped:
                    print("name 저장")
                    outputSubject.send(.navigateToEmailInputView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateName(_ text: String) {
        let isValid = text.isValidName
        outputSubject.send(.isNameValid(isValid))
    }
}

extension NameInputViewModel {
    enum Input {
        case nameTextChanged(String)
        case buttonTapped
    }
    
    enum Output {
        case isNameValid(Bool)
        case navigateToEmailInputView
    }
}
