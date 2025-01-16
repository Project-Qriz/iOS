//
//  EmailInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine

final class EmailInputViewModel {
    
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
                    print("이메일 인증번호 전송 및 중복 확인 API 실행")
                    print("이메일 저장")
                    outputSubject.send(.navigateToVerificationCodeView)
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

extension EmailInputViewModel {
    enum Input {
        case emailTextChanged(String)
        case buttonTapped
    }
    
    enum Output {
        case isNameValid(Bool)
        case navigateToVerificationCodeView
    }
}
