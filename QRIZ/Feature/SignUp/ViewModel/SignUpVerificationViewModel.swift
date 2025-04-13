//
//  SignUpVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine

final class SignUpVerificationViewModel: EmailVerificationViewModel {
    
    // MARK: - Properties
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let authService: SignUpService
    
    // MARK: - Initialize
    
    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        signUpService: SignUpService
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.authService = signUpService
        super.init()
    }
    
    override func sendVerificationCode(email: String) {
        outputSubject.send(.emailVerificationInProgress)
        
        Task {
            do {
                _ = try await authService.sendEmail(email)
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
                _ = try await authService.EmailAuthentication(email: email, authNumber: authNumber)
                outputSubject.send(.codeVerificationSuccess)
                countdownTimer.stop()
            } catch {
                outputSubject.send(.codeVerificationFailure)
            }
        }
    }
}
