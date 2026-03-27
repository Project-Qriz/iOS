import Foundation
import Testing
import Combine
@testable import MyPage
import Network

@MainActor
@Suite("DeleteAccountViewModel 테스트", .serialized)
struct DeleteAccountViewModelTests {

    private func makeSUT(
        provider: String = "kakao",
        myPageService: MockMyPageService? = nil,
        socialLoginService: MockSocialLoginService? = nil
    ) -> DeleteAccountViewModel {
        DeleteAccountViewModel(
            provider: provider,
            myPageService: myPageService ?? MockMyPageService(),
            socialLoginService: socialLoginService ?? MockSocialLoginService()
        )
    }

    // MARK: - 동기 탭 이벤트

    @Test("didTapDelete → showConfirmAlert emit")
    func didTapDelete_emitsShowConfirmAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapDelete)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showConfirmAlert = first else {
            Issue.record("Expected .showConfirmAlert, got \(first)")
            return
        }
    }

    // MARK: - didConfirmDelete

    @Test("didConfirmDelete kakao 성공 → unlinkKakao 호출 후 deletionSucceeded emit")
    func didConfirmDelete_kakao_emitsDeletionSucceeded() async throws {
        // kakao: unlinkKakao() + deleteSocialAccount(.kakao) 순서로 호출
        let socialLoginService = MockSocialLoginService()
        let sut = makeSUT(provider: "kakao", socialLoginService: socialLoginService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(socialLoginService.unlinkKakaoCallCount == 1)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete google 성공 → deletionSucceeded emit")
    func didConfirmDelete_google_emitsDeletionSucceeded() async throws {
        let sut = makeSUT(provider: "google")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete apple 성공 → deletionSucceeded emit")
    func didConfirmDelete_apple_emitsDeletionSucceeded() async throws {
        let sut = makeSUT(provider: "apple")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete email 성공 → deletionSucceeded emit")
    func didConfirmDelete_email_emitsDeletionSucceeded() async throws {
        // email: deleteAccount() 호출 (MockMyPageService.deleteAccountResult 기본값 = 성공)
        let sut = makeSUT(provider: "email")
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .deletionSucceeded = first else {
            Issue.record("Expected .deletionSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmDelete NetworkError 실패 → showErrorAlert emit")
    func didConfirmDelete_networkError_emitsShowErrorAlert() async throws {
        // kakao provider: unlinkKakao 성공 유지, deleteSocialAccount만 NetworkError 실패
        let myPageService = MockMyPageService()
        myPageService.deleteSocialAccountResult = .failure(NetworkError.serverError)
        let sut = makeSUT(provider: "kakao", myPageService: myPageService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == NetworkError.serverError.errorMessage)
    }

    @Test("didConfirmDelete 일반 Error 실패 → showErrorAlert emit")
    func didConfirmDelete_genericError_emitsShowErrorAlert() async throws {
        let myPageService = MockMyPageService()
        myPageService.deleteSocialAccountResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(provider: "kakao", myPageService: myPageService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        // DeleteAccountViewModel.swift performDelete() 일반 catch 블록 문자열
        #expect(message == "잠시 후 다시 시도해 주세요.")
    }

    @Test("didConfirmDelete kakao unlinkKakao NetworkError 실패 → showErrorAlert emit")
    func didConfirmDelete_kakaoUnlinkNetworkError_emitsShowErrorAlert() async throws {
        // kakao: unlinkKakao() 자체가 NetworkError로 실패하는 경우
        let socialLoginService = MockSocialLoginService()
        socialLoginService.unlinkKakaoResult = .failure(NetworkError.serverError)
        let sut = makeSUT(provider: "kakao", socialLoginService: socialLoginService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == NetworkError.serverError.errorMessage)
    }

    @Test("didConfirmDelete kakao unlinkKakao 일반 Error 실패 → showErrorAlert emit")
    func didConfirmDelete_kakaoUnlinkGenericError_emitsShowErrorAlert() async throws {
        let socialLoginService = MockSocialLoginService()
        socialLoginService.unlinkKakaoResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(provider: "kakao", socialLoginService: socialLoginService)
        let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
        var received: [DeleteAccountViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmDelete)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == "잠시 후 다시 시도해 주세요.")
    }
}
