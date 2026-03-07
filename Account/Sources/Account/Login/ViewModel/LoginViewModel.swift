//
//  LoginViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 12/28/24.
//

import UIKit
import Combine
import os
import QRIZUtils
import Network
import Auth

@MainActor
final class LoginViewModel {

    // MARK: - Properties

    private let loginService: LoginService
    private let userInfoService: UserInfoService
    private let socialLoginService: SocialLoginService
    private var id: String = ""
    private var password: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger.account(category: "LoginViewModel")

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(
        loginService: LoginService,
        userInfoService: UserInfoService,
        socialLoginService: SocialLoginService
    ) {
        self.loginService = loginService
        self.userInfoService = userInfoService
        self.socialLoginService = socialLoginService
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .idTextChanged(let newID):
            id = newID
            validateFields()

        case .passwordTextChanged(let newPassword):
            password = newPassword
            validateFields()

        case .loginButtonTapped:
            login()

        case .accountActionSelected(let action):
            outputSubject.send(.navigateToAccountAction(action))

        case .socialLoginSelected(let socialLogin, let presenter):
            handleSocialLogin(socialLogin, presenter: presenter)
        }
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
                let response = try await loginService.login(id: id, password: password)
                let user = response.data.user
                UserInfoManager.shared.update(name: user.name, userId: user.userId, email: user.email, previewTestStatus: user.previewTestStatus, provider: user.provider)
                outputSubject.send(.loginSucceeded)
            } catch {
                outputSubject.send(.showErrorAlert(title: "아이디 또는 비밀번호 확인", description: "아이디와 비밀번호를 정확하게 입력해 주세요."))
                logger.error("Login failed: \(String(describing: error), privacy: .public)")
            }
        }
    }

    private func kakaoLogin() {
        performSocialLogin(providerName: "카카오") {
            try await self.socialLoginService.loginWithKakao()
        }
    }

    private func googleLogin(presenting: UIViewController) {
        performSocialLogin(providerName: "구글") {
            try await self.socialLoginService.loginWithGoogle(presenting: presenting)
        }
    }

    private func appleLogin(presenting: UIViewController) {
        performSocialLogin(providerName: "애플") {
            try await self.socialLoginService.loginWithApple(presenting: presenting)
        }
    }

    private func performSocialLogin(
        providerName: String,
        action: @escaping () async throws -> SocialLoginResponse
    ) {
        Task {
            do {
                let response = try await action()
                let user = response.data.user
                UserInfoManager.shared.update(
                    name: user.name,
                    userId: user.userId,
                    email: user.email,
                    previewTestStatus: user.previewTestStatus,
                    provider: user.provider
                )
                outputSubject.send(.loginSucceeded)
            } catch let error as SocialAuthError where error == .cancelled {
                logger.info("\(providerName) login canceled by user.")
            } catch {
                outputSubject.send(.showErrorAlert(title: "\(providerName) 로그인 실패", description: "잠시 후 다시 시도해 주세요."))
                logger.error("\(providerName) social login failed: \(String(describing: error), privacy: .public)")
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
        case showErrorAlert(title: String, description: String? = nil)
        case navigateToAccountAction(AccountAction)
        case loginSucceeded
    }

    enum AccountAction: String {
        case findId = "아이디 찾기"
        case findPassword = "비밀번호 찾기"
        case signUp = "회원가입"
    }
}
