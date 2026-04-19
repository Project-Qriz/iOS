import Foundation
import Testing
import Combine
@testable import MyPage
import Network

@MainActor
@Suite("SettingsViewModel 테스트", .serialized)
struct SettingsViewModelTests {

    private func makeSUT(
        userName: String = "테스트",
        email: String = "test@test.com",
        provider: String = "kakao",
        myPageService: MockMyPageService? = nil,
        socialLoginService: MockSocialLoginService? = nil
    ) -> SettingsViewModel {
        SettingsViewModel(
            userName: userName,
            email: email,
            provider: provider,
            myPageService: myPageService ?? MockMyPageService(),
            socialLoginService: socialLoginService ?? MockSocialLoginService()
        )
    }

    // MARK: - 동기 탭 이벤트

    @Test("viewDidLoad → setupProfile emit")
    func viewDidLoad_emitsSetupProfile() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .setupProfile(let userName, let email) = first else {
            Issue.record("Expected .setupProfile, got \(first)")
            return
        }
        #expect(userName == "테스트")
        #expect(email == "test@test.com")
    }

    @Test("didTapResetPassword → navigateToResetPassword emit")
    func didTapResetPassword_emitsNavigateToResetPassword() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapResetPassword)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .navigateToResetPassword = first else {
            Issue.record("Expected .navigateToResetPassword, got \(first)")
            return
        }
    }

    @Test("didTapLogout → showLogoutAlert emit")
    func didTapLogout_emitsShowLogoutAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapLogout)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showLogoutAlert = first else {
            Issue.record("Expected .showLogoutAlert, got \(first)")
            return
        }
    }

    @Test("didTapDeleteAccount → navigateToDeleteAccount emit")
    func didTapDeleteAccount_emitsNavigateToDeleteAccount() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapDeleteAccount)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .navigateToDeleteAccount = first else {
            Issue.record("Expected .navigateToDeleteAccount, got \(first)")
            return
        }
    }

    // MARK: - didConfirmLogout

    @Test("didConfirmLogout kakao 성공 → logoutSucceeded emit")
    func didConfirmLogout_kakao_emitsLogoutSucceeded() async throws {
        let sut = makeSUT(provider: "kakao")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout google 성공 → logoutSucceeded emit")
    func didConfirmLogout_google_emitsLogoutSucceeded() async throws {
        let sut = makeSUT(provider: "google")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout apple 성공 → logoutSucceeded emit")
    func didConfirmLogout_apple_emitsLogoutSucceeded() async throws {
        let sut = makeSUT(provider: "apple")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout email 성공 → logoutSucceeded emit")
    func didConfirmLogout_email_emitsLogoutSucceeded() async throws {
        // email provider: SettingsViewModel의 switch에서 case .email: break → 서비스 호출 없이 logoutSucceeded
        let sut = makeSUT(provider: "email")
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .logoutSucceeded = first else {
            Issue.record("Expected .logoutSucceeded, got \(first)")
            return
        }
    }

    @Test("didConfirmLogout NetworkError 실패 → showErrorAlert emit")
    func didConfirmLogout_networkError_emitsShowErrorAlert() async throws {
        let socialLoginService = MockSocialLoginService()
        socialLoginService.logoutKakaoResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(provider: "kakao", socialLoginService: socialLoginService)
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == "로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요.")
    }

    @Test("didConfirmLogout 일반 Error 실패 → showErrorAlert emit")
    func didConfirmLogout_failure_emitsShowErrorAlert() async throws {
        let socialLoginService = MockSocialLoginService()
        socialLoginService.logoutKakaoResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(provider: "kakao", socialLoginService: socialLoginService)
        let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
        var received: [SettingsViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmLogout)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let message) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(message == "로그아웃에 실패했습니다. 잠시 후 다시 시도해 주세요.")
    }
}
