//
//  FindIDViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account
import Network

@MainActor
@Suite("FindIDViewModel 테스트", .serialized)
struct FindIDViewModelTests {

    private func makeSUT(service: MockAccountRecoveryService = .init()) -> FindIDViewModel {
        FindIDViewModel(accountRecoveryService: service)
    }

    // MARK: - 이메일 유효성 검사

    @Test("유효한 이메일 → isEmailValid true")
    func validEmailEmitsTrue() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.emailTextChanged("test@example.com")) }

        #expect(outputs.contains(.isEmailValid(true)))
    }

    @Test("유효하지 않은 이메일 → isEmailValid false")
    func invalidEmailEmitsFalse() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.emailTextChanged("not-an-email")) }

        #expect(outputs.contains(.isEmailValid(false)))
    }

    // MARK: - 버튼 탭

    @Test("buttonTapped 성공 → showEmailSentAlert")
    func buttonTappedSuccessShowsAlert() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) {
            sut.send(.emailTextChanged("test@example.com"))
            sut.send(.buttonTapped)
        }

        #expect(outputs.contains(.showEmailSentAlert))
    }

    @Test("buttonTapped 실패 → showErrorAlert")
    func buttonTappedFailureShowsErrorAlert() async throws {
        let service = MockAccountRecoveryService()
        service.findIDResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(service: service)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.emailTextChanged("test@example.com"))
            sut.send(.buttonTapped)
        }

        let hasErrorAlert = outputs.contains {
            if case .showErrorAlert = $0 { return true }
            return false
        }
        #expect(hasErrorAlert)
    }

    @Test("이메일 미입력 상태에서 buttonTapped → 요청 없음")
    func buttonTappedWithoutEmailDoesNothing() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) {
            sut.send(.buttonTapped)
        }

        #expect(outputs.isEmpty)
    }
}
