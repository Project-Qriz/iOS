//
//  PasswordInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/9/25.
//

import Foundation
import Combine

@MainActor
final class PasswordInputViewModel {

    // MARK: - Properties

    private let signUpFlowViewModel: SignUpFlowViewModel
    private var password: String = ""
    private var confirmPassword: String = ""
    private var confirmPasswordDidEdit: Bool = false
    private let outputSubject: PassthroughSubject<Output, Never> = .init()

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(signUpFlowViewModel: SignUpFlowViewModel) {
        self.signUpFlowViewModel = signUpFlowViewModel
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .passwordTextChanged(let newPassword):
            password = newPassword
            validate()

        case .confirmPasswordTextChanged(let newConfirm):
            confirmPassword = newConfirm
            confirmPasswordDidEdit = true
            validate()

        case .buttonTapped:
            signUpFlowViewModel.updatePassword(confirmPassword)
            outputSubject.send(.showTermsAgreementModal)
        }
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
        outputSubject.send(.passwordValidChanged(passwordValid))

        let canSignUp = passwordValid && (confirmPasswordDidEdit ? (confirmPassword == password) : false)
        outputSubject.send(.updateButtonState(canSignUp))
    }
}

extension PasswordInputViewModel {
    enum Input {
        case passwordTextChanged(String)
        case confirmPasswordTextChanged(String)
        case buttonTapped
    }

    enum Output: Equatable {
        case characterRequirementChanged(Bool)
        case lengthRequirementChanged(Bool)
        case passwordValidChanged(Bool)
        case confirmValidChanged(Bool)
        case updateButtonState(Bool)
        case showTermsAgreementModal
    }
}
