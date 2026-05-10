//
//  ResetPasswordViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account
import QRIZNetwork

@MainActor
@Suite("ResetPasswordViewModel 테스트", .serialized)
struct ResetPasswordViewModelTests {

    private func makeSUT(service: MockAccountRecoveryService = .init()) -> ResetPasswordViewModel {
        ResetPasswordViewModel(accountRecoveryService: service)
    }

    // MARK: - 비밀번호 유효성 검사

    @Test("유효한 비밀번호 → passwordValid true")
    func validPasswordEmitsPasswordValidTrue() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.passwordTextChanged("Valid@1234")) }

        #expect(outputs.contains(.characterRequirementChanged(true)))
        #expect(outputs.contains(.lengthRequirementChanged(true)))
        #expect(outputs.contains(.passwordValidChanged(true)))
    }

    @Test("확인 비밀번호 일치 → confirmValid true, 버튼 활성화")
    func matchingConfirmPasswordEnablesButton() {
        let sut = makeSUT()
        sut.send(.passwordTextChanged("Valid@1234"))
        let outputs = collect(sut.output) { sut.send(.confirmPasswordTextChanged("Valid@1234")) }

        #expect(outputs.contains(.confirmValidChanged(true)))
        #expect(outputs.contains(.updateButtonState(true)))
    }

    // MARK: - 비밀번호 재설정

    @Test("buttonTapped 성공 → showResetCompleteAlert")
    func buttonTappedSuccessShowsCompleteAlert() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) {
            sut.send(.passwordTextChanged("Valid@1234"))
            sut.send(.confirmPasswordTextChanged("Valid@1234"))
            sut.send(.buttonTapped)
        }

        #expect(outputs.contains(.showResetCompleteAlert))
    }

    @Test("buttonTapped 네트워크 실패 → showErrorAlert")
    func buttonTappedFailureShowsErrorAlert() async throws {
        let service = MockAccountRecoveryService()
        service.resetPasswordResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(service: service)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.passwordTextChanged("Valid@1234"))
            sut.send(.confirmPasswordTextChanged("Valid@1234"))
            sut.send(.buttonTapped)
        }

        let hasErrorAlert = outputs.contains {
            if case .showErrorAlert = $0 { return true }
            return false
        }
        #expect(hasErrorAlert)
    }
}
