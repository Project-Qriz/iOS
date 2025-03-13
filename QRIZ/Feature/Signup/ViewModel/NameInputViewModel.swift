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
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private var name: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(signUpFlowViewModel: SignUpFlowViewModel) {
        self.signUpFlowViewModel = signUpFlowViewModel
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .nameTextChanged(let text):
                    self.validateName(text)
                    
                case .buttonTapped:
                    self.signUpFlowViewModel.updateName(name)
                    self.outputSubject.send(.navigateToEmailInputView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateName(_ text: String) {
        let isValid = text.isValidName
        name = isValid ? text : name
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
