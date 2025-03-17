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
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private var password: String = ""
    private var confirmPassword: String = ""
    private var confirmPasswordDidEdit: Bool = false
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
                case .passwordTextChanged(let newPassword):
                    self.password = newPassword
                    self.validate()
                    
                case .confirmPasswordTextChanged(let newConfirm):
                    self.confirmPassword = newConfirm
                    self.confirmPasswordDidEdit = true
                    self.validate()
                    
                case .buttonTapped:
                    self.signUpFlowViewModel.updatePassword(self.confirmPassword)
                    self.performJoin()
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validate() {
        let characterRequirement = password.isValidCharacterRequirement
        let lengthRequirement = password.isValidLengthRequirement
        let passwordValid = characterRequirement && lengthRequirement
        
        if confirmPasswordDidEdit {
            let confirmValid = passwordValid && (confirmPassword == password)
            outputSubject.send(.confirmValidChanged(confirmValid))
        }
        
        outputSubject.send(.characterRequirementChanged(characterRequirement))
        outputSubject.send(.lengthRequirementChanged(lengthRequirement))
        
        let canSignUp = passwordValid && (confirmPasswordDidEdit ? (confirmPassword == password) : false)
        outputSubject.send(.updateSignupButtonState(canSignUp))
    }
    
    private func performJoin() {
        Task {
            do {
                let joinResponse = try await signUpFlowViewModel.join()
                outputSubject.send(.navigateToAlertView)
            } catch {
                // 오류 얼랏 호출
            }
        }
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
