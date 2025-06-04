//
//  SplashViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/3/25.
//

import Combine

@MainActor
final class SplashViewModel {

    // MARK: - Properties

    private let userInfoService: UserInfoService
    private let keychain: KeychainManager
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialize

    init(userInfoService: UserInfoService, keychain: KeychainManager) {
        self.userInfoService = userInfoService
        self.keychain = keychain
    }

    // MARK: - Functions

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
        let isLoggedIn = await validateSession()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        outputSubject.send(.finished(isLoggedIn: isLoggedIn))
    }

    private func validateSession() async -> Bool {
        do {
            let response = try await userInfoService.getUserInfo()
            UserInfoManager.shared.update(from: response.data)
            return true
        } catch {
            keychain.deleteToken(forKey: HTTPHeaderField.accessToken.rawValue)
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
