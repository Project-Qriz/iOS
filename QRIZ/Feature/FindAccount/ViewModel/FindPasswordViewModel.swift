//
//  FindPasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine

final class FindPasswordViewModel {
    
    // MARK: - Properties
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private let countdownTimer: CountdownTimer
    
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
                    self.sendVerificationCode()
                    
                case .codeTextChanged(let code):
                    validateCode(code)
                    
                case .confirmButtonTapped:
                    verifyCode()
                    
                case .nextButtonTapped:
                    outputSubject.send(.navigateToPasswordResetView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    
    private func validateEmail(_ email: String) {
        let isValid = email.isValidEmail
        outputSubject.send(.isEmailValid(isValid))
    }
    
    private func validateCode(_ code: String) {
        let isValid = code.count == 6
        outputSubject.send(.isCodeValid(isValid))
    }
    
    // 이메일 전송 후 타이머 시작
    private func sendVerificationCode() {
        let apiResult = Bool.random()
        
        if apiResult {
            outputSubject.send(.emailVerificationSuccess)
            countdownTimer.reset()
            countdownTimer.start()
        } else {
            outputSubject.send(.emailVerificationFailure)
        }
    }
    
    // 인증 API 호출
    private func verifyCode() {
        let apiResult = Bool.random()
        let result: Output = apiResult ? .codeVerificationSuccess : .codeVerificationFailure
        outputSubject.send(result)
    }
}

extension FindPasswordViewModel {
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
        case emailVerificationSuccess
        case emailVerificationFailure
        case updateRemainingTime(Int)
        case timerExpired
        case codeVerificationSuccess
        case codeVerificationFailure
        case navigateToPasswordResetView
    }
}
