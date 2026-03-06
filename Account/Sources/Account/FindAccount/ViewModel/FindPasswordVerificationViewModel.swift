//
//  FindPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Network

@MainActor
final class FindPasswordVerificationViewModel: EmailVerificationViewModel {
    
    // MARK: - Properties
    
    private let accountRecoveryService: AccountRecoveryService
    
    // MARK: - Initialization
    
    init(accountRecoveryService: AccountRecoveryService) {
        self.accountRecoveryService = accountRecoveryService
        super.init(logCategory: "FindPasswordVerificationViewModel")
    }
    
    // MARK: - Override
    
    override func sendVerificationCode(email: String) {
        outputSubject.send(.emailVerificationInProgress)
        
        Task {
            do {
                _ = try await accountRecoveryService.findPassword(email: email)
                outputSubject.send(.emailVerificationSuccess)
                countdownTimer.reset()
                countdownTimer.start()
            } catch {
                handleSendVerificationError(error)
            }
        }
    }
    
    override func verifyCode(email: String, authNumber: String) {
        Task {
            do {
                let response = try await accountRecoveryService.verifyPasswordReset(email: email, authNumber: authNumber)
                accountRecoveryService.setResetToken(resetToken: response.data.resetToken)
                outputSubject.send(.codeVerificationSuccess)
                countdownTimer.stop()
            } catch {
                handleVerifyCodeError(error)
            }
        }
    }
}
