//
//  FindPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine

final class FindPasswordViewModel {
    
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
                    
                case .sendButtonTapped:
                    self.tempAPI()
                    
                case .nextButtonTapped:
                    outputSubject.send(.navigateToPasswordResetView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateEmail(_ text: String) {
        let isValid = text.isValidEmail
        outputSubject.send(.isNameValid(isValid))
    }
    
    // 이메일 전송 api
    private func tempAPI() {
        let apiResult = Bool.random()
        let result: Output = apiResult ? .passwordVerificationSuccess : .passwordVerificationFailure
        outputSubject.send(result)
    }
}

extension FindPasswordViewModel {
    enum Input {
        case emailTextChanged(String)
        case sendButtonTapped
        case nextButtonTapped
    }
    
    enum Output {
        case isNameValid(Bool)
        case passwordVerificationSuccess
        case passwordVerificationFailure
        case navigateToPasswordResetView
    }
}
