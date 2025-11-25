//
//  DeleteAccountViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/16/25.
//

import Foundation
import Combine
import os

final class DeleteAccountViewModel {
    
    // MARK: - Properties
    
    private let myPageService: MyPageService
    private let socialLoginService: SocialLoginService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ",
                                category: "DeleteAccountViewModel")
    
    // MARK: - Initialize
    
    init(
        myPageService: MyPageService,
        socialLoginService: SocialLoginService
    ) {
        self.myPageService = myPageService
        self.socialLoginService = socialLoginService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .didTapDelete:
                    outputSubject.send(.showConfirmAlert)
                    
                case .didConfirmDelete:
                    Task { [weak self] in
                        await self?.performDelete()
                    }
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    private func performDelete() async {
        do {
            let provider = SocialLogin(from: UserInfoManager.shared.provider)
            try await deleteByProvider(provider)
            outputSubject.send(.deletionSucceeded)
            
        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(deleteAccount): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert("잠시 후 다시 시도해 주세요."))
            logger.error("Unhandled error(deleteAccount): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    @MainActor
    private func deleteByProvider(_ provider: SocialLogin) async throws {
        switch provider {
        case .kakao:
            try await socialLoginService.unlinkKakao()
            _ = try await myPageService.deleteSocialAccount(socialLoginType: .kakao)
        case .google:
            _ = try await myPageService.deleteSocialAccount(socialLoginType: .google)
        case .apple:
            _ = try await myPageService.deleteSocialAccount(socialLoginType: .apple)
        case .email:
            _ = try await myPageService.deleteAccount()
        }
    }
}

extension DeleteAccountViewModel {
    enum Input {
        case didTapDelete
        case didConfirmDelete
    }
    
    enum Output {
        case showConfirmAlert
        case deletionSucceeded
        case showErrorAlert(String)
    }
}
