//
//  FindIdViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine

final class FindIdViewModel {
    
    // MARK: - Properties
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .emailTextChanged(let text):
                    self.validateEmail(text)
                    
                case .buttonTapped:
                    print("이메일 발송API 호출")
                    outputSubject.send(.navigateToAlerView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateEmail(_ text: String) {
        let isValid = text.isValidEmail
        outputSubject.send(.isNameValid(isValid))
    }
}

extension FindIdViewModel {
    enum Input {
        case emailTextChanged(String)
        case buttonTapped
    }
    
    enum Output {
        case isNameValid(Bool)
        case navigateToAlerView
    }
}
