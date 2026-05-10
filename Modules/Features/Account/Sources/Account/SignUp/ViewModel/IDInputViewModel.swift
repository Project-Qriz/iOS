//
//  IdInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine
import os
import QRIZUtils
import QRIZNetwork

@MainActor
final class IDInputViewModel {

    // MARK: - Properties

    private let signUpFlowViewModel: SignUpFlowViewModel
    private let signUpService: SignUpService
    private var id: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger.make(category: "IDInputViewModel")

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        signUpService: SignUpService
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.signUpService = signUpService
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .idTextChanged(let newId):
            id = newId
            validateID(newId)

        case .duplicateCheckButtonTapped:
            checkUsernameDuplicate(id)

        case .nextButtonTapped:
            signUpFlowViewModel.updateID(id)
            outputSubject.send(.navigateToPasswordInputView)
        }
    }

    private func validateID(_ text: String) {
        let isValid = text.isValidId
        outputSubject.send(.isIDValid(isValid))
    }

    private func checkUsernameDuplicate(_ id: String) {
        Task {
            do {
                let response = try await signUpService.checkUsernameDuplication(username: id)
                let available = response.data.available
                outputSubject.send(.duplicateCheckResult(message: response.msg, isAvailable: available))
                outputSubject.send(.updateNextButtonState(available))
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(_, let serverCode, let message):
                        if serverCode == -1 {
                            outputSubject.send(.duplicateCheckResult(message: message, isAvailable: false))
                            outputSubject.send(.updateNextButtonState(false))
                        } else {
                            outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                            logger.error("Client error in checkUsernameDuplicate: \(networkError.debugDescription, privacy: .public)")
                        }
                    default:
                        outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                    }
                } else {
                    outputSubject.send(.showErrorAlert(title: "아이디 중복 확인에 실패했습니다."))
                    logger.error("Unhandled error in checkUsernameDuplicate: \(String(describing: error), privacy: .public)")
                }
            }
        }
    }
}

extension IDInputViewModel {
    enum Input {
        case idTextChanged(String)
        case duplicateCheckButtonTapped
        case nextButtonTapped
    }

    enum Output: Equatable {
        case isIDValid(Bool)
        case duplicateCheckResult(message: String, isAvailable: Bool)
        case updateNextButtonState(Bool)
        case showErrorAlert(title: String)
        case navigateToPasswordInputView
    }
}
