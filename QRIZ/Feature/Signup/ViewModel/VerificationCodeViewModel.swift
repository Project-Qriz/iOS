//
//  VerificationCodeInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/10/25.
//

import Foundation
import Combine

final class VerificationCodeViewModel {
    
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
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    self.countdownTimer.start()
                    
                case .viewWillDisappear:
                    self.countdownTimer.stop()
                    
                case .codeTextChanged(let text):
                    self.validateCode(text)
                    
                case .resendCodeTapped:
                    self.resendCode()
                    
                case .buttonTapped:
                    self.verifyCode()
                    
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateCode(_ text: String) {
        let isValid = text.count == 6
        outputSubject.send(.isCodeValid(isValid))
    }
    
    private func verifyCode() {
        // TODO: 이메일 인증번호 검증 API 호출
        let success = Bool.random()
        if success {
            outputSubject.send(.navigateToIdInputView)
        } else {
            outputSubject.send(.verificationFailed)
        }
    }
    
    private func resendCode() {
        print("인증번호 다시 받기 API 호출")
        countdownTimer.reset()
        countdownTimer.start()
    }
}

extension VerificationCodeViewModel {
    enum Input {
        case viewDidLoad
        case viewWillDisappear
        case codeTextChanged(String)
        case resendCodeTapped
        case buttonTapped
    }
    
    enum Output {
        case isCodeValid(Bool)
        case verificationFailed
        case updateRemainingTime(Int)
        case navigateToIdInputView
    }
}
