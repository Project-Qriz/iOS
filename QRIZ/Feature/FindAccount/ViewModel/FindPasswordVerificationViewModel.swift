//
//  FindPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine

final class FindPasswordVerificationViewModel: EmailVerificationViewModel {
    
    // MARK: - Properties
    
    let accountRecoveryService: AccountRecoveryService
    
    // MARK: - Initialize
    
    init(accountRecoveryService: AccountRecoveryService) {
        self.accountRecoveryService = accountRecoveryService
    }
    
    override func sendVerificationCode(email: String) {
        outputSubject.send(.emailVerificationInProgress)
        
        Task {
            do {
                _ = try await accountRecoveryService.findPassword(email: email)
                outputSubject.send(.emailVerificationSuccess)
                
                Task {
                    await MainActor.run {
                        countdownTimer.reset()
                        countdownTimer.start()
                    }
                }
            } catch {
                if let networkError = error as? NetworkError {
                    outputSubject.send(.emailVerificationFailure(networkError.errorMessage))
                }
            }
        }
    }
    
    override func verifyCode(email: String, authNumber: String) {
        Task {
            do {
                _ = try await accountRecoveryService.verifyPasswordReset(email: email, authNumber: authNumber)
                outputSubject.send(.codeVerificationSuccess)
                countdownTimer.stop()
            } catch {
                outputSubject.send(.codeVerificationFailure)
            }
        }
    }
}

