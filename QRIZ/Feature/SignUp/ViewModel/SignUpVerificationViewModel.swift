//
//  SignUpVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine
import os

final class SignUpVerificationViewModel: EmailVerificationViewModel {
    
    // MARK: - Properties
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let signUpService: SignUpService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "SignUpVerificationViewModel")
    
    // MARK: - Initialize
    
    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        signUpService: SignUpService
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.signUpService = signUpService
        super.init()
    }
    
    override func sendVerificationCode(email: String) {
        outputSubject.send(.emailVerificationInProgress)
        
        Task {
            do {
                _ = try await signUpService.sendEmail(email)
                outputSubject.send(.emailVerificationSuccess)
                Task {
                    await MainActor.run {
                        countdownTimer.reset()
                        countdownTimer.start()
                    }
                }
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(_, let serverCode, let message):
                        if serverCode == -1 {
                            outputSubject.send(.emailVerificationDuplicate(message))
                        } else {
                            let errorMessage = "이메일을 올바르게 입력해주세요."
                            outputSubject.send(.showErrorAlert(title: errorMessage))
                            logger.error("Network error alert in sendVerificationCode: \(networkError.description, privacy: .public)")
                        }
                    default:
                        outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                        logger.error("Unhandled network error in sendVerificationCode: \(networkError.description, privacy: .public)")
                    }
                } else {
                    let genericErrorMessage = "이메일 인증에 실패했습니다."
                    outputSubject.send(.showErrorAlert(title: genericErrorMessage))
                    logger.error("Unhandled error in sendVerificationCode: \(String(describing: error), privacy: .public)")
                }
            }
        }
    }
    
    override func verifyCode(email: String, authNumber: String) {
        Task {
            do {
                _ = try await signUpService.EmailAuthentication(email: email, authNumber: authNumber)
                outputSubject.send(.codeVerificationSuccess)
                countdownTimer.stop()
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(let statusCode, _, let message) where statusCode == 400:
                        outputSubject.send(.codeVerificationFailure(message))
                    default:
                        outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                    }
                    logger.error("NetworkError in verifyCode: \(networkError.description, privacy: .public)")
                } else {
                    let errorMessage = "인증번호 검증에 실패했습니다."
                    outputSubject.send(.showErrorAlert(title: errorMessage))
                    logger.error("Unhandled error in verifyCode: \(String(describing: error), privacy: .public)")
                }
            }
        }
    }
}
