//
//  TermsAgreementModalViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account
import QRIZNetwork

@MainActor
@Suite("TermsAgreementModalViewModel 테스트", .serialized)
struct TermsAgreementModalViewModelTests {

    private func makeSUT(service: MockSignUpService = .init()) -> TermsAgreementModalViewModel {
        let flowVM = SignUpFlowViewModel(signUpService: service)
        return TermsAgreementModalViewModel(signUpFlowViewModel: flowVM)
    }

    // MARK: - 초기화

    @Test("viewDidLoad → initialTerms(2개 항목)")
    func viewDidLoadEmitsInitialTerms() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.viewDidLoad) }

        let hasInitialTerms = outputs.contains {
            if case .initialTerms(let terms) = $0 { return terms.count == 2 }
            return false
        }
        #expect(hasInitialTerms)
    }

    // MARK: - 전체 동의 토글

    @Test("allToggle → 모두 isAgreed true, allAgreeChanged(true)")
    func allToggleAgreesAll() {
        let sut = makeSUT()
        sut.send(.viewDidLoad)
        let outputs = collect(sut.output) { sut.send(.allToggle) }

        #expect(outputs.contains(.allAgreeChanged(true)))
        #expect(outputs.contains(.termChanged(index: 0, isAgreed: true)))
        #expect(outputs.contains(.termChanged(index: 1, isAgreed: true)))
        #expect(outputs.contains(.updateSignUpButtonState(true)))
    }

    @Test("allToggle 두 번 → 모두 false로 복귀")
    func allToggleTwiceUnagreesAll() {
        let sut = makeSUT()
        sut.send(.viewDidLoad)
        sut.send(.allToggle)
        let outputs = collect(sut.output) { sut.send(.allToggle) }

        #expect(outputs.contains(.allAgreeChanged(false)))
        #expect(outputs.contains(.updateSignUpButtonState(false)))
    }

    // MARK: - 개별 약관 토글

    @Test("termToggle(0) → index 0만 true, allAgreeChanged(false)")
    func termToggleSingleItemPartialAgreement() {
        let sut = makeSUT()
        sut.send(.viewDidLoad)
        let outputs = collect(sut.output) { sut.send(.termToggle(index: 0)) }

        #expect(outputs.contains(.termChanged(index: 0, isAgreed: true)))
        #expect(outputs.contains(.allAgreeChanged(false)))
        #expect(outputs.contains(.updateSignUpButtonState(false)))
    }

    @Test("모든 항목 개별 토글 → allAgreeChanged(true), 버튼 활성화")
    func allItemsToggledIndividuallyEnablesButton() {
        let sut = makeSUT()
        sut.send(.viewDidLoad)
        sut.send(.termToggle(index: 0))
        let outputs = collect(sut.output) { sut.send(.termToggle(index: 1)) }

        #expect(outputs.contains(.allAgreeChanged(true)))
        #expect(outputs.contains(.updateSignUpButtonState(true)))
    }

    // MARK: - 회원가입

    @Test("signUpButtonTapped 성공 → signUpSucceeded")
    func signUpButtonTappedSuccessEmitsSignUpSucceeded() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) {
            sut.send(.signUpButtonTapped)
        }

        #expect(outputs.contains(.signUpSucceeded))
    }

    @Test("signUpButtonTapped 실패 → showErrorAlert")
    func signUpButtonTappedFailureShowsErrorAlert() async throws {
        let service = MockSignUpService()
        service.joinResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(service: service)

        let outputs = try await collectAsync(sut.output) {
            sut.send(.signUpButtonTapped)
        }

        let hasErrorAlert = outputs.contains {
            if case .showErrorAlert = $0 { return true }
            return false
        }
        #expect(hasErrorAlert)
    }
}
