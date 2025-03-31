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
    
    private let loginService: LoginService
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private var id: String = ""
    private var password: String = ""
    
    // MARK: - Initialize
    
    init(loginService: LoginService) {
        self.loginService = loginService
    }
    
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
                    self.login()
                    
                case .accountActionSelected(let action):
                    self.outputSubject.send(.navigateToAccountAction(action))
                    
                case .socialLoginSelected(let socialLogin):
                    self.handleSocialLogin(socialLogin)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateFields() {
        let isValid = id.isValidId && password.isValidPassword
        outputSubject.send(.isLoginButtonEnabled(isValid))
    }
    
    private func handleSocialLogin(_ socialLogin: SocialLogin) {
        switch socialLogin {
        case .google:
            print("구글 로그인")
        case .naver:
            print("네이버 로그인")
        case .facebook:
            print("페이스북 로그인")
        }
    }
    
    private func login() {
        Task {
            do {
                let _ = try await loginService.Login(id: id, password: password)
                outputSubject.send(.loginSucceeded)
            } catch {
                if let networkError = error as? NetworkError {
                    outputSubject.send(.showErrorAlert(networkError.errorMessage))
                } else {
                    outputSubject.send(.showErrorAlert("비밀번호 변경에 실패했습니다."))
                }
            }
        }
    }
}

extension LoginViewModel {
    enum Input {
        case idTextChanged(String)
        case passwordTextChanged(String)
        case loginButtonTapped
        case accountActionSelected(AccountAction)
        case socialLoginSelected(SocialLogin)
    }
    
    enum Output {
        case isLoginButtonEnabled(Bool)
        case showErrorAlert(String)
        case navigateToAccountAction(AccountAction)
        case loginSucceeded
    }
    
    enum AccountAction: String {
        case findId = "아이디 찾기"
        case findPassword = "비밀번호 찾기"
        case signUp = "회원가입"
    }
    
    enum SocialLogin: String {
        case google = "구글"
        case naver = "네이버"
        case facebook = "페북"
    }
}
