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
                case .accountActionSelected(let action):
                    self.handleAccountAction(action)
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
    
    private func handleAccountAction(_ action: AccountAction) {
        switch action {
        case .findId:
            print("아이디 찾기 뷰로 이동")
        case .findPassword:
            print("비밀번호 찾기 뷰로 이동")
        case .signUp:
            print("회원가입 뷰로 이동")
        }
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
