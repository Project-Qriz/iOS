//
//  FindPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine
import Network

@MainActor
final class FindPasswordVerificationViewModel: EmailVerificationViewModelType {
    
    // MARK: - Properties
    
    private let core: EmailVerificationCore
    private let accountRecoveryService: AccountRecoveryService
    
    var output: AnyPublisher<EmailVerificationOutput, Never> {
        core.output
    }
    
    // MARK: - Initialization
    
    init(accountRecoveryService: AccountRecoveryService) {
        self.core = EmailVerificationCore(logCategory: "FindPasswordVerificationViewModel")
        self.accountRecoveryService = accountRecoveryService
    }
    
    // MARK: - Methods
    
    func send(_ input: EmailVerificationInput) {
        core.handle(
            input,
            onSendCode: { [weak self] email in self?.sendVerificationCode(email: email) },
            onVerifyCode: { [weak self] email, code in self?.verifyCode(email: email, authNumber: code) }
        )
    }
    
    private func sendVerificationCode(email: String) {
        core.outputSubject.send(.emailVerificationInProgress)
        
        Task {
            do {
                _ = try await accountRecoveryService.findPassword(email: email)
                core.outputSubject.send(.emailVerificationSuccess)
                core.countdownTimer.reset()
                core.countdownTimer.start()
            } catch {
                core.handleSendVerificationError(error)
            }
        }
    }
    
    private func verifyCode(email: String, authNumber: String) {
        Task {
            do {
                let response = try await accountRecoveryService.verifyPasswordReset(email: email, authNumber: authNumber)
                accountRecoveryService.setResetToken(resetToken: response.data.resetToken)
                core.outputSubject.send(.codeVerificationSuccess)
                core.countdownTimer.stop()
            } catch {
                core.handleVerifyCodeError(error)
            }
        }
    }
}
