//
//  PasswordInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/9/25.
//

import Foundation
import Combine
import os
import QRIZNetwork

@MainActor
final class PasswordInputViewModel {

    // MARK: - Properties

    private let signUpFlowViewModel: SignUpFlowViewModel
    private var password: String = ""
    private var confirmPassword: String = ""
    private var confirmPasswordDidEdit: Bool = false
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger.make(category: "PasswordInputViewModel")

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
            performJoin()
        }
    }

    private func performJoin() {
        Task {
            do {
                _ = try await signUpFlowViewModel.join()
                outputSubject.send(.signUpSucceeded)
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(_, _, let message, "under_age", _):
                        outputSubject.send(.showErrorAlert(title: message))
                    case .clientError(let statusCode, _, _, _, _) where statusCode == 400:
                        outputSubject.send(.showErrorAlert(title: "가입 실패", description: "처음부터 다시 진행해 주세요."))
                        logger.error("Client error 400 in performJoin: \(networkError.debugDescription, privacy: .public)")
                    default:
                        outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                    }
                } else {
                    outputSubject.send(.showErrorAlert(title: "회원가입 도중 오류가 발생했습니다."))
                    logger.error("Unhandled error in performJoin: \(String(describing: error), privacy: .public)")
                }
            }
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
        case signUpSucceeded
        case showErrorAlert(title: String, description: String? = nil)
    }
}
