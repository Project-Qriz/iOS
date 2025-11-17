//
//  LoginViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 12/28/24.
//

import UIKit
import Combine
import os

final class LoginViewModel {
    
    // MARK: - Properties
    
    private let loginService: LoginService
    private let userInfoService: UserInfoService
    private let socialLoginService: SocialLoginService
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "LoginViewModel")
    
    private var id: String = ""
    private var password: String = ""
    
    // MARK: - Initialize
    
    init(
        loginService: LoginService,
        userInfoService: UserInfoService,
        socialLoginService: SocialLoginService = SocialLoginServiceImpl()
    ) {
        self.loginService = loginService
        self.userInfoService = userInfoService
        self.socialLoginService = socialLoginService 
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
                    
                case .socialLoginSelected(let socialLogin, let presenter):
                    self.handleSocialLogin(socialLogin, presenter: presenter)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateFields() {
        let isValid = id.isValidId && password.isValidPassword
        outputSubject.send(.isLoginButtonEnabled(isValid))
    }
    
    private func handleSocialLogin(_ socialLogin: SocialLogin, presenter: UIViewController?) {
        switch socialLogin {
        case .google:
            guard let presenter = presenter else {
                logger.error("Google login requires a presenter VC")
                return
            }
            googleLogin(presenting: presenter)
        case .kakao: kakaoLogin()
        case .apple:
            guard let presenter = presenter else {
                logger.error("Apple login requires a presenter VC")
                return
            }
            appleLogin(presenting: presenter)
        case .email: break
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
    
    private func kakaoLogin() {
        Task {
            do {
                let _ = try await socialLoginService.loginWithKakao()
                let userInfo = try await userInfoService.getUserInfo()
                UserInfoManager.shared.update(from: userInfo.data)
                outputSubject.send(.loginSucceeded)
            } catch {
                outputSubject.send(.showErrorAlert(title: "카카오 로그인 실패", descrption: "잠시 후 다시 시도해 주세요."))
                logger.error("Kakao social login failed: \(String(describing: error), privacy: .public)")
            }
        }
    }
    
    private func googleLogin(presenting: UIViewController) {
        Task {
            do {
                _ = try await socialLoginService.loginWithGoogle(presenting: presenting)
                let userInfo = try await userInfoService.getUserInfo()
                UserInfoManager.shared.update(from: userInfo.data)
                outputSubject.send(.loginSucceeded)
            } catch {
                outputSubject.send(.showErrorAlert(title: "구글 로그인 실패", descrption: "잠시 후 다시 시도해 주세요."))
                logger.error("Google social login failed: \(String(describing: error), privacy: .public)")
            }
        }
    }
    
    private func appleLogin(presenting: UIViewController) {
        Task {
            do {
                _ = try await socialLoginService.loginWithApple(presenting: presenting)
                let userInfo = try await userInfoService.getUserInfo()
                UserInfoManager.shared.update(from: userInfo.data)
                outputSubject.send(.loginSucceeded)
            } catch {
                outputSubject.send(.showErrorAlert(title: "애플 로그인 실패", descrption: "잠시 후 다시 시도해 주세요."))
                logger.error("Apple social login failed: \(String(describing: error), privacy: .public)")
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
        case socialLoginSelected(SocialLogin, presenter: UIViewController?)
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
}
