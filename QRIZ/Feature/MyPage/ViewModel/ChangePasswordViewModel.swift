//
//  ChangePasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/20/25.
//

import Foundation
import Combine
import os

// TODO: - ‼️‼️‼️ 화면 UI 와 비밀번호 변경 API 로직의 차이가 심해서 추후에 수정 후 다시 구현 필요‼️‼️‼️

final class ChangePasswordViewModel {
    
    // MARK: - Properties
    
    private let myPageService: MyPageService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPassword: String = ""
    private var newPassword: String = ""
    
    // MARK: - Initialize
    
    init(myPageService: MyPageService) {
        self.myPageService = myPageService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .didTapForgotPassword:
                    self.outputSubject.send(.navigateToFindPassword)
                    
                case .currentPasswordChanged(let password):
                    self.currentPassword = password
                    self.validatePassword()

                case .newPasswordChanged(let password):
                    self.newPassword = password
                    self.validatePassword()
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validatePassword() {
        let canSubmit = currentPassword.isValidPassword && newPassword.isValidPassword
        outputSubject.send(.updateChangeButtonState(canSubmit))
    }
}

extension ChangePasswordViewModel {
    enum Input {
        case currentPasswordChanged(String)
        case newPasswordChanged(String)
        case didTapForgotPassword
    }
    
    enum Output {
        case updateChangeButtonState(Bool)
        case navigateToFindPassword
    }
}
