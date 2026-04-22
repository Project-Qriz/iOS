//
//  SplashViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/3/25.
//

import Combine
import QRIZUtils
import Network

@MainActor
final class SplashViewModel {

    // MARK: - Properties

    private let userInfoService: UserInfoService
    private let keychain: KeychainManager
    private let userInfo: UserInfoManager
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(userInfoService: UserInfoService, keychain: KeychainManager, userInfo: UserInfoManager = .shared) {
        self.userInfoService = userInfoService
        self.keychain = keychain
        self.userInfo = userInfo
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidAppear:
                    Task { await self.performInitialChecks() }
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    private func performInitialChecks() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        let isLoggedIn = await validateSession()
        
        outputSubject.send(.finished(isLoggedIn: isLoggedIn))
    }

    private func validateSession() async -> Bool {
        do {
            let response = try await userInfoService.getUserInfo()
            let user = response.data
            userInfo.update(
                name: user.name,
                userId: user.userId,
                email: user.email,
                previewTestStatus: user.previewTestStatus,
                provider: user.provider
            )
            return true
        } catch {
            keychain.deleteToken(forKey: TokenKey.accessToken.rawValue)
            return false
        }
    }
}

extension SplashViewModel {
    enum Input {
        case viewDidAppear
    }

    enum Output {
        case finished(isLoggedIn: Bool)
    }
}
