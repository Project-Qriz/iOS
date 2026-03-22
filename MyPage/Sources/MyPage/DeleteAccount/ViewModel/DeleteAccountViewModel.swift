import Foundation
import Combine
import os
import QRIZUtils
import Network

final class DeleteAccountViewModel {

    // MARK: - Properties

    private let provider: String
    private let myPageService: MyPageService
    private let socialLoginService: SocialLoginService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger.make(category: "DeleteAccountViewModel")

    // MARK: - Initialize

    init(
        provider: String,
        myPageService: MyPageService,
        socialLoginService: SocialLoginService
    ) {
        self.provider = provider
        self.myPageService = myPageService
        self.socialLoginService = socialLoginService
    }

    // MARK: - Functions

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
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
            let provider = SocialLogin(from: provider)
            try await deleteByProvider(provider)
            outputSubject.send(.deletionSucceeded)

        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(deleteAccount): \(error.debugDescription, privacy: .public)")

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
