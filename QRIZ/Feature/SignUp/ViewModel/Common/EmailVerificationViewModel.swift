//
//  EmailVerificationViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 2/13/25.
//

import Foundation
import Combine

class EmailVerificationViewModel {
    
    // MARK: - Properties
    
    private var email: String?
    private var authNumber: String?
    let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    let countdownTimer: CountdownTimer
    
    // MARK: - Initialize
    
    init(totalTime: Int = 180) {
        self.countdownTimer = CountdownTimer(totalTime: totalTime)
        
        countdownTimer.remainingTimePublisher()
            .sink { [weak self] remainingTime in
                guard let self else { return }
                self.outputSubject.send(.updateRemainingTime(remainingTime))
                
                if remainingTime <= 0 {
                    self.outputSubject.send(.timerExpired)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .emailTextChanged(let email):
                    self.validateEmail(email)
                    
                case .sendButtonTapped:
                    guard let email = email else { return }
                    self.sendVerificationCode(email: email)
                    
                case .codeTextChanged(let authNumber):
                    self.validateCode(authNumber)
                    
                case .confirmButtonTapped:
                    guard
                        let email = email,
                        let authNumber = authNumber
                    else { return }
                    self.verifyCode(email: email, authNumber: authNumber)
                    
                case .nextButtonTapped:
                    self.outputSubject.send(.navigateToNextView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
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
    
    // 하위 클래스에서 반드시 구현하도록 강제
    func sendVerificationCode(email: String) {
        fatalError("sendVerificationCode(_:) must be implemented in subclass")
    }
    
    // 하위 클래스에서 반드시 구현하도록 강제
    func verifyCode(email: String, authNumber: String) {
        fatalError("verifyCode() must be implemented in subclass")
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
