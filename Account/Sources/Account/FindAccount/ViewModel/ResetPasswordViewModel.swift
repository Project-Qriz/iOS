//
//  ResetPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 2/1/25.
//

import Foundation
import Combine
import os
import Network

@MainActor
final class ResetPasswordViewModel {

    // MARK: - Properties

    private let accountRecoveryService: AccountRecoveryService
    private var password: String = ""
    private var confirmPassword: String = ""
    private var confirmPasswordDidEdit: Bool = false
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "ResetPasswordViewModel")

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(accountRecoveryService: AccountRecoveryService) {
        self.accountRecoveryService = accountRecoveryService
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
            resetPassword()
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

        let canReset = passwordValid && (confirmPasswordDidEdit ? (confirmPassword == password) : false)
        outputSubject.send(.updateButtonState(canReset))
    }

    private func resetPassword() {
        Task {
            do {
                _ = try await accountRecoveryService.resetPassword(password: confirmPassword)
                outputSubject.send(.showResetCompleteAlert)
            } catch {
                if let networkError = error as? NetworkError {
                    outputSubject.send(.showErrorAlert(networkError.errorMessage))
                    logger.error("Network error in resetPassword: \(networkError.debugDescription, privacy: .public)")
                } else {
                    outputSubject.send(.showErrorAlert("비밀번호 변경에 실패했습니다."))
                    logger.error("Unhandled error in resetPassword: \(String(describing: error), privacy: .public)")
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
        case updateButtonState(Bool)
        case showErrorAlert(String)
        case showResetCompleteAlert
    }
}
