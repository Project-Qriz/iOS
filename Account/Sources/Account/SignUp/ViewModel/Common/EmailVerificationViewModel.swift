//
//  EmailVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 2/13/25.
//

import Foundation
import Combine
import os
import Network
import QRIZUtils

@MainActor
class EmailVerificationViewModel {

    // MARK: - Properties

    private var email: String?
    private var authNumber: String?
    let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    let countdownTimer: CountdownTimer
    let logger: Logger

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(logCategory: String, totalTime: Int = 180) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: logCategory)
        self.countdownTimer = CountdownTimer(totalTime: totalTime)

        countdownTimer.remainingTimePublisher
            .sink { [weak self] remainingTime in
                guard let self else { return }
                outputSubject.send(.updateRemainingTime(remainingTime))

                if remainingTime <= 0 {
                    outputSubject.send(.timerExpired)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .emailTextChanged(let email):
            validateEmail(email)

        case .sendButtonTapped:
            guard let email = self.email else { return }
            sendVerificationCode(email: email)

        case .codeTextChanged(let authNumber):
            validateCode(authNumber)

        case .confirmButtonTapped:
            guard
                let email = self.email,
                let authNumber = self.authNumber
            else { return }
            verifyCode(email: email, authNumber: authNumber)

        case .nextButtonTapped:
            outputSubject.send(.navigateToNextView)
        }
    }

    private func validateEmail(_ email: String) {
        let isValid = email.isValidEmail
        self.email = email
        outputSubject.send(.isEmailValid(isValid))
    }

    private func validateCode(_ authNumber: String) {
        let isValid = authNumber.count == 6
        self.authNumber = authNumber
        outputSubject.send(.isCodeValid(isValid))
    }

    // MARK: - Abstract

    func sendVerificationCode(email: String) {
        fatalError("sendVerificationCode(_:) must be overridden")
    }

    func verifyCode(email: String, authNumber: String) {
        fatalError("verifyCode(_:_:) must be overridden")
    }

    // MARK: - Shared Error Handling

    func handleSendVerificationError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .clientError(_, let serverCode, let message):
                if serverCode == -1 {
                    outputSubject.send(.emailVerificationDuplicate(message))
                } else {
                    outputSubject.send(.showErrorAlert(title: "이메일을 올바르게 입력해주세요."))
                    logger.error("Network error alert in sendVerificationCode: \(networkError.debugDescription, privacy: .public)")
                }
            default:
                outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                logger.error("Unhandled network error in sendVerificationCode: \(networkError.debugDescription, privacy: .public)")
            }
        } else {
            outputSubject.send(.showErrorAlert(title: "이메일 인증에 실패했습니다."))
            logger.error("Unhandled error in sendVerificationCode: \(String(describing: error), privacy: .public)")
        }
    }

    func handleVerifyCodeError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .clientError(let statusCode, _, let message) where statusCode == 400:
                outputSubject.send(.codeVerificationFailure(message))
            default:
                outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
            }
            logger.error("NetworkError in verifyCode: \(networkError.debugDescription, privacy: .public)")
        } else {
            outputSubject.send(.showErrorAlert(title: "인증번호 검증에 실패했습니다."))
            logger.error("Unhandled error in verifyCode: \(String(describing: error), privacy: .public)")
        }
    }
}

extension EmailVerificationViewModel {
    enum Input {
        case emailTextChanged(String)
        case sendButtonTapped
        case codeTextChanged(String)
        case confirmButtonTapped
        case nextButtonTapped
    }

    enum Output {
        case isEmailValid(Bool)
        case isCodeValid(Bool)
        case emailVerificationInProgress
        case emailVerificationSuccess
        case emailVerificationDuplicate(String)
        case showErrorAlert(title: String)
        case updateRemainingTime(Int)
        case timerExpired
        case codeVerificationSuccess
        case codeVerificationFailure(String)
        case navigateToNextView
    }
}
