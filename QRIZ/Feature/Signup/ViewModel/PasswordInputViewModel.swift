//
//  PasswordInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/9/25.
//

import Foundation
import Combine

final class PasswordInputViewModel {
    
    // MARK: - Properties
    
    private var password: String = ""
    private var confirmPassword: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .passwordTextChanged(let newPassword):
                    self.password = newPassword
                    self.validate()
                    
                case .confirmPasswordTextChanged(let newConfirm):
                    self.confirmPassword = newConfirm
                    self.validate()
                    
                case .buttonTapped:
                    print("회원가입API 호출")
                    outputSubject.send(.navigateToAlertView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validate() {
        let characterRequirement = password.isValidCharacterRequirement
        let lengthRequirement = password.isValidLengthRequirement
        let passwordValid = characterRequirement && lengthRequirement
        let confirmValid = !confirmPassword.isEmpty && confirmPassword == password
        
        outputSubject.send(.characterRequirementChanged(characterRequirement))
        outputSubject.send(.lengthRequirementChanged(lengthRequirement))
        outputSubject.send(.confirmValidChanged(confirmValid))
        
        let canSignUp = passwordValid && confirmValid
        outputSubject.send(.updateSignupButtonState(canSignUp))
    }
}

extension PasswordInputViewModel {
    enum Input {
        case passwordTextChanged(String)
        case confirmPasswordTextChanged(String)
        case buttonTapped
    }
    
    enum Output {
        case characterRequirementChanged(Bool)
        case lengthRequirementChanged(Bool)
        case confirmValidChanged(Bool)
        case updateSignupButtonState(Bool)
        case navigateToAlertView
    }
}
