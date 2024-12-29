//
//  LoginViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 12/28/24.
//

import Foundation
import Combine

final class LoginViewModel {
    
    // MARK: - Properties
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private var id: String = ""
    private var password: String = ""
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .idTextChanged(let newID):
                    self.id = newID
                    self.validateFields()
                case .passwordTextChanged(let newPassword):
                    self.password = newPassword
                    self.validateFields()
                case .loginButtonTapped:
                    print("ViewModel에서 로그인 버튼 클릭 이벤트를 입력 받았습니다.")
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateFields() {
        let isValid = id.isValidID && password.isValidPassword
        outputSubject.send(.isLoginButtonEnabled(isValid))
    }
}

extension LoginViewModel {
    enum Input {
        case idTextChanged(String)
        case passwordTextChanged(String)
        case loginButtonTapped
    }
    enum Output {
        case isLoginButtonEnabled(Bool)
    }
}
