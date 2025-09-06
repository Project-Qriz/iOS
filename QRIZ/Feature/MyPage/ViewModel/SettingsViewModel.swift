//
//  SettingsViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import Foundation
import Combine

enum SettingsOption: String, CaseIterable {
    case resetPassword = "비밀번호 재설정"
    case logout = "로그아웃"
    case deleteAccount = "계정 탈퇴"
}

final class SettingsViewModel {
    
    // MARK: - Properties
    
    private let userName: String
    private let email: String
    private let myPageService: MyPageService
    private let socialLoginService: SocialLoginService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(
        userName: String,
        email: String,
        myPageService: MyPageService,
        socialLoginService: SocialLoginService
    ) {
        self.userName = userName
        self.email = email
        self.myPageService = myPageService
        self.socialLoginService = socialLoginService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    self.outputSubject.send(.setupProfile(userName: userName, email: email))
                
                case .didTapResetPassword:
                    outputSubject.send(.navigateToResetPassword)
                
                case .didTapLogout:
                    outputSubject.send(.showLogoutAlert)
                    
                case .didTapDeleteAccount:
                    outputSubject.send(.navigateToDeleteAccount)
                    
                case .didConfirmLogout:
                    Task { [weak self] in
                        await self?.performLogout()
                    }
                    
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    private func performLogout() async {
        do {
            let provider = SocialLogin(from: UserInfoManager.shared.provider)
            
            switch provider {
            case .kakao: try await socialLoginService.logoutKakao()
            case .google: break
            case .apple: break
            case .email: break
            }
            print("카카오 로그아웃 연결 해제")
            outputSubject.send(.logoutSucceeded)
            
        } catch {
            outputSubject.send(.showErrorAlert("로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요."))
        }
    }
}

extension SettingsViewModel {
    enum Input {
        case viewDidLoad
        case didTapResetPassword
        case didTapLogout
        case didTapDeleteAccount
        case didConfirmLogout
    }
    
    enum Output {
        case setupProfile(userName: String, email: String)
        case navigateToResetPassword
        case showLogoutAlert
        case navigateToDeleteAccount
        case logoutSucceeded
        case showErrorAlert(String)
    }
}
