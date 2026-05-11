//
//  EmailVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 2/13/25.
//

import Foundation
import Combine
import os
import QRIZNetwork
import QRIZUtils

// MARK: - Protocol

@MainActor
protocol EmailVerificationViewModelType: AnyObject {
    var output: AnyPublisher<EmailVerificationOutput, Never> { get }
    func send(_ input: EmailVerificationInput)
}

// MARK: - Input / Output

enum EmailVerificationInput {
    case emailTextChanged(String)
    case sendButtonTapped
    case codeTextChanged(String)
    case confirmButtonTapped
    case nextButtonTapped
}

enum EmailVerificationOutput {
    case isEmailValid(Bool)
    case isCodeValid(Bool)
    case emailVerificationInProgress
    case emailVerificationSuccess
    case emailVerificationDuplicate(String)
    case showErrorAlert(title: String)
    case updateRemainingTime(Int)
    case timerExpired
    case codeVerificationSuccess
    case codeVerificationFailure
    case navigateToNextView
}

@MainActor
final class EmailVerificationCore {

    // MARK: - Properties

    private var email: String?
    private var authNumber: String?
    private var cancellables = Set<AnyCancellable>()
    private let countdownTimer: CountdownTimer
    private let logger: Logger
    private let outputSubject: PassthroughSubject<EmailVerificationOutput, Never> = .init()

    var output: AnyPublisher<EmailVerificationOutput, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(logCategory: String, totalTime: Int = 180) {
        self.logger = Logger.make(category: logCategory)
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

    func handle(
        _ input: EmailVerificationInput,
        onSendCode: (String) -> Void,
        onVerifyCode: (String, String) -> Void
    ) {
        switch input {
        case .emailTextChanged(let email):
            validateEmail(email)

        case .sendButtonTapped:
            guard let email else { return }
            onSendCode(email)

        case .codeTextChanged(let authNumber):
            validateCode(authNumber)

        case .confirmButtonTapped:
            guard let email, let authNumber else { return }
            onVerifyCode(email, authNumber)

        case .nextButtonTapped:
            outputSubject.send(.navigateToNextView)
        }
    }

    func sendEmailVerificationInProgress() {
        outputSubject.send(.emailVerificationInProgress)
    }

    func handleSendCodeSuccess() {
        outputSubject.send(.emailVerificationSuccess)
        countdownTimer.reset()
        countdownTimer.start()
    }

    func handleVerifyCodeSuccess() {
        outputSubject.send(.codeVerificationSuccess)
        countdownTimer.stop()
    }

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
            case .clientError(let statusCode, _, _) where statusCode == 400:
                outputSubject.send(.codeVerificationFailure)
            default:
                outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
            }
            logger.error("NetworkError in verifyCode: \(networkError.debugDescription, privacy: .public)")
        } else {
            outputSubject.send(.showErrorAlert(title: "인증번호 검증에 실패했습니다."))
            logger.error("Unhandled error in verifyCode: \(String(describing: error), privacy: .public)")
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
}
