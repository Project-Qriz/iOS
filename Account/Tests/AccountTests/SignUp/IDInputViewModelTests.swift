//
//  IDInputViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account
@testable import Network

@MainActor
@Suite("IDInputViewModel 테스트", .serialized)
struct IDInputViewModelTests {

    private func makeSUT(service: MockSignUpService = .init()) -> IDInputViewModel {
        let flowVM = SignUpFlowViewModel(signUpService: service)
        return IDInputViewModel(signUpFlowViewModel: flowVM, signUpService: service)
    }

    // MARK: - 아이디 유효성 검사

    @Test("유효한 아이디 → isIDValid true")
    func validIDEmitsTrue() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.idTextChanged("hun12345")) }

        #expect(outputs.contains(.isIDValid(true)))
    }

    @Test("짧은 아이디 → isIDValid false")
    func shortIDEmitsFalse() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.idTextChanged("ab")) }

        #expect(outputs.contains(.isIDValid(false)))
    }

    // MARK: - 중복 확인

    @Test("중복 확인 - 사용 가능 → updateNextButtonState true")
    func duplicateCheckAvailableEnablesNextButton() async throws {
        let service = MockSignUpService()
        service.checkUsernameResult = .success(
            UsernameDuplicationResponse(code: 1, msg: "ok", data: .init(available: true))
        )
        let sut = makeSUT(service: service)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.duplicateCheckButtonTapped)
        }

        #expect(outputs.contains(.updateNextButtonState(true)))
    }

    @Test("중복 확인 - 사용 불가 → updateNextButtonState false")
    func duplicateCheckUnavailableDisablesNextButton() async throws {
        let service = MockSignUpService()
        service.checkUsernameResult = .success(
            UsernameDuplicationResponse(code: 1, msg: "ok", data: .init(available: false))
        )
        let sut = makeSUT(service: service)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.duplicateCheckButtonTapped)
        }

        #expect(outputs.contains(.updateNextButtonState(false)))
    }

    @Test("중복 확인 - serverCode -1 → duplicateCheckResult(isAvailable: false)")
    func duplicateCheckServerCodeMinusOneShowsDuplicateMessage() async throws {
        let service = MockSignUpService()
        service.checkUsernameResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: -1, message: "동일한 username이 존재합니다.")
        )
        let sut = makeSUT(service: service)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.idTextChanged("hun12345"))
            sut.send(.duplicateCheckButtonTapped)
        }

        let hasDuplicateResult = outputs.contains {
            if case .duplicateCheckResult(_, let isAvailable) = $0 {
                return !isAvailable
            }
            return false
        }
        #expect(hasDuplicateResult)
        #expect(outputs.contains(.updateNextButtonState(false)))
    }

    @Test("nextButtonTapped → navigateToPasswordInputView")
    func nextButtonTappedNavigates() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.nextButtonTapped) }

        #expect(outputs.contains(.navigateToPasswordInputView))
    }
}
