import Foundation
import os
import Combine
import QRIZUtils
import QRIZNetwork

@MainActor
final class SettingsViewModel {

    // MARK: - Properties

    private let userName: String
    private let email: String
    private let provider: String
    private let myPageService: any MyPageService
    private let socialLoginService: any SocialLoginService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let logger = Logger.make(category: "SettingsViewModel")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        userName: String,
        email: String,
        provider: String,
        myPageService: any MyPageService,
        socialLoginService: any SocialLoginService
    ) {
        self.userName = userName
        self.email = email
        self.provider = provider
        self.myPageService = myPageService
        self.socialLoginService = socialLoginService
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
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
                    Task {
                        await self.performLogout()
                    }

                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    private func performLogout() async {
        do {
            let loginType = SocialLogin(from: provider)

            switch loginType {
            case .kakao: try await socialLoginService.logoutKakao()
            case .google: try await socialLoginService.logoutGoogle()
            case .apple: try await socialLoginService.logoutApple()
            case .email: break
            }
            outputSubject.send(.logoutSucceeded)

        } catch {
            logger.error("Logout failed: \(error.localizedDescription, privacy: .public)")
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
