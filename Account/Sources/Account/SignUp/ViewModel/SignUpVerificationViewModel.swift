//
//  SignUpVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine
import Network

@MainActor
final class SignUpVerificationViewModel: EmailVerificationViewModelType {
    
    // MARK: - Properties
    
    private let core: EmailVerificationCore
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let signUpService: SignUpService
    
    var output: AnyPublisher<EmailVerificationOutput, Never> {
        core.output
    }
    
    // MARK: - Initialization
    
    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        signUpService: SignUpService
    ) {
        self.core = EmailVerificationCore(logCategory: "SignUpVerificationViewModel")
        self.signUpFlowViewModel = signUpFlowViewModel
        self.signUpService = signUpService
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
                _ = try await signUpService.sendEmail(email)
                core.outputSubject.send(.emailVerificationSuccess)
                signUpFlowViewModel.updateEmail(email)
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
                _ = try await signUpService.emailAuthentication(email: email, authNumber: authNumber)
                core.outputSubject.send(.codeVerificationSuccess)
                core.countdownTimer.stop()
            } catch {
                core.handleVerifyCodeError(error)
            }
        }
    }
}
