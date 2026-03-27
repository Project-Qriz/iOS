//
//  LoginViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account
import Network

@MainActor
@Suite("LoginViewModel 테스트", .serialized)
struct LoginViewModelTests {

    private func makeSUT(
        loginService: MockLoginService = .init(),
        socialService: MockSocialLoginService = .init()
    ) -> LoginViewModel {
        LoginViewModel(
            loginService: loginService,
            userInfoService: MockUserInfoService(),
            socialLoginService: socialService
        )
    }

    // MARK: - 필드 유효성 검사

    @Test("유효한 ID + 비밀번호 → isLoginButtonEnabled true")
    func validFieldsEnableLoginButton() {
        let sut = makeSUT()
        let outputs = collect(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.passwordTextChanged("Valid@123"))
        }

        #expect(outputs.contains(.isLoginButtonEnabled(true)))
    }

    @Test("ID만 유효 + 약한 비밀번호 → isLoginButtonEnabled false")
    func weakPasswordDisablesLoginButton() {
        let sut = makeSUT()
        let outputs = collect(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.passwordTextChanged("weak"))
        }

        #expect(outputs.contains(.isLoginButtonEnabled(false)))
    }

    @Test("빈 ID → isLoginButtonEnabled false")
    func emptyIDDisablesLoginButton() {
        let sut = makeSUT()
        let outputs = collect(sut.output) {
            sut.send(.idTextChanged(""))
            sut.send(.passwordTextChanged("Valid@123"))
        }

        #expect(outputs.contains(.isLoginButtonEnabled(false)))
    }

    // MARK: - 로그인 결과

    @Test("loginButtonTapped 성공 → loginSucceeded")
    func loginSucceeds() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.passwordTextChanged("Valid@123"))
            sut.send(.loginButtonTapped)
        }

        #expect(outputs.contains(.loginSucceeded))
    }

    @Test("loginButtonTapped 실패 → showErrorAlert")
    func loginFailureShowsErrorAlert() async throws {
        let loginService = MockLoginService()
        loginService.loginResult = .failure(NetworkError.serverError)
        let sut = makeSUT(loginService: loginService)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.passwordTextChanged("Valid@123"))
            sut.send(.loginButtonTapped)
        }

        let hasErrorAlert = outputs.contains {
            if case .showErrorAlert = $0 { return true }
            return false
        }
        #expect(hasErrorAlert)
    }

    // MARK: - 소셜 로그인 중복 탭 방지

    @Test("소셜 로그인 진행 중 재탭 → 두 번째 요청 무시")
    func socialLoginInProgressIgnoresSecondTap() async throws {
        let socialService = MockSocialLoginService()
        socialService.loginDelay = 200_000_000 // 0.2초

        let sut = makeSUT(socialService: socialService)

        sut.send(.socialLoginSelected(.kakao, presenter: nil))
        sut.send(.socialLoginSelected(.kakao, presenter: nil))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(socialService.loginCallCount == 1)
    }

    @Test("소셜 로그인 완료 후 재탭 → 새 요청 허용")
    func socialLoginAllowsNewRequestAfterCompletion() async throws {
        let socialService = MockSocialLoginService()
        let sut = makeSUT(socialService: socialService)

        sut.send(.socialLoginSelected(.kakao, presenter: nil))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        sut.send(.socialLoginSelected(.kakao, presenter: nil))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(socialService.loginCallCount == 2)
    }
}
