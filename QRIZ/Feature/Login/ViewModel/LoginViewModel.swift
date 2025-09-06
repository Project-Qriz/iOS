//
//  LoginViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 12/28/24.
//

import Foundation
import Combine
import os

final class LoginViewModel {
    
    // MARK: - Properties
    
    private let loginService: LoginService
    private let userInfoService: UserInfoService
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "LoginViewModel")
    
    private var id: String = ""
    private var password: String = ""
    
    // MARK: - Initialize
    
    init(
        loginService: LoginService,
        userInfoService: UserInfoService
    ) {
        self.loginService = loginService
        self.userInfoService = userInfoService
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
                _ = try await loginService.login(id: id, password: password)
                let userInfo = try await userInfoService.getUserInfo()
                UserInfoManager.shared.update(from: userInfo.data)
                outputSubject.send(.loginSucceeded)
            } catch {
                let title = "아이디 또는 비밀번호 확인"
                let description = "아이디와 비밀번호를 정확하게 입력해 주세요."
                
                if let networkError = error as? NetworkError {
                    outputSubject.send(.showErrorAlert(title: title, descrption: description))
                    logger.error("Network error in login: \(networkError.description, privacy: .public)")

                } else {
                    outputSubject.send(.showErrorAlert(title: title, descrption: description))
                    logger.error("Unhandled error in login: \(String(describing: error), privacy: .public)")
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
        case showErrorAlert(title: String, descrption: String? = nil)
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
