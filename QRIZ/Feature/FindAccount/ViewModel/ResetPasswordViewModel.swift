//
//  ResetPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 2/1/25.
//

import Foundation
import Combine

final class ResetPasswordViewModel {
    
    // MARK: - Properties
    
    private let accountRecoveryService: AccountRecoveryService
    private var password: String = ""
    private var confirmPassword: String = ""
    private var confirmPasswordDidEdit: Bool = false
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(accountRecoveryService: AccountRecoveryService) {
        self.accountRecoveryService = accountRecoveryService
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
                    self.resetPassword()
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
        
        let canReset = passwordValid && (confirmPasswordDidEdit ? (confirmPassword == password) : false)
        outputSubject.send(.updateSignUpButtonState(canReset))
    }
    
    private func resetPassword() {
        Task {
            do {
                let _ = try await accountRecoveryService.resetPassword(password: confirmPassword)
                outputSubject.send(.navigateToAlertView)
            } catch {
                if let networkError = error as? NetworkError {
                    outputSubject.send(.showErrorAlert(networkError.errorMessage))
                } else {
                    outputSubject.send(.showErrorAlert("비밀번호 변경에 실패했습니다."))
                }
            }
        }
    }
}

extension ResetPasswordViewModel {
    enum Input {
        case passwordTextChanged(String)
        case confirmPasswordTextChanged(String)
        case buttonTapped
    }
    
    enum Output {
        case characterRequirementChanged(Bool)
        case lengthRequirementChanged(Bool)
        case confirmValidChanged(Bool)
        case updateSignUpButtonState(Bool)
        case showErrorAlert(String)
        case navigateToAlertView
    }
}
