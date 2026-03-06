//
//  SignUpVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Network

@MainActor
final class SignUpVerificationViewModel: EmailVerificationViewModel {
    
    // MARK: - Properties
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let signUpService: SignUpService
    
    // MARK: - Initialization
    
    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        signUpService: SignUpService
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.signUpService = signUpService
        super.init(logCategory: "SignUpVerificationViewModel")
    }
    
    // MARK: - Override
    
    override func sendVerificationCode(email: String) {
        outputSubject.send(.emailVerificationInProgress)
        
        Task {
            do {
                _ = try await signUpService.sendEmail(email)
                outputSubject.send(.emailVerificationSuccess)
                signUpFlowViewModel.updateEmail(email)
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
                _ = try await signUpService.emailAuthentication(email: email, authNumber: authNumber)
                outputSubject.send(.codeVerificationSuccess)
                countdownTimer.stop()
            } catch {
                handleVerifyCodeError(error)
            }
        }
    }
}
