//
//  FindIdViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine
import os
import QRIZUtils
import Network

@MainActor
final class FindIDViewModel {

    // MARK: - Properties

    private let accountRecoveryService: AccountRecoveryService
    private var email: String?
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger.make(category: "FindIDViewModel")

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
        case .emailTextChanged(let text):
            email = text
            validateEmail(text)

        case .buttonTapped:
            guard let email = self.email else { return }
            sendFindIDEmail(email: email)
        }
    }

    private func validateEmail(_ text: String) {
        let isValid = text.isValidEmail
        outputSubject.send(.isEmailValid(isValid))
    }

    private func sendFindIDEmail(email: String) {
        Task {
            do {
                _ = try await accountRecoveryService.findID(email: email)
                outputSubject.send(.showEmailSentAlert)
            } catch {
                if let networkError = error as? NetworkError {
                    outputSubject.send(.showErrorAlert(networkError.errorMessage))
                    logger.error("Network error in sendFindIDEmail: \(networkError.debugDescription, privacy: .public)")
                } else {
                    outputSubject.send(.showErrorAlert("이메일 발송에 실패했습니다."))
                    logger.error("Unhandled error in sendFindIDEmail: \(String(describing: error), privacy: .public)")
                }
            }
        }
    }
}

extension FindIDViewModel {
    enum Input {
        case emailTextChanged(String)
        case buttonTapped
    }

    enum Output: Equatable {
        case isEmailValid(Bool)
        case showErrorAlert(String)
        case showEmailSentAlert
    }
}
