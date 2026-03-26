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
        myPageService: MockMyPageService = .init(),
        socialLoginService: MockSocialLoginService = .init()
    ) -> SettingsViewModel {
        SettingsViewModel(
            userName: userName,
            email: email,
            provider: provider,
            myPageService: myPageService,
            socialLoginService: socialLoginService
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
}
