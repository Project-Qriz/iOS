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

    private func makeSUT(
        signUpService: MockSignUpService = .init(),
        termsService: MockTermsService = .init()
    ) -> TermsAgreementModalViewModel {
        let flowVM = SignUpFlowViewModel(signUpService: signUpService)
        return TermsAgreementModalViewModel(signUpFlowViewModel: flowVM, termsService: termsService)
    }

    // MARK: - 초기화

    @Test("viewDidLoad → initialTerms(연령확인 1개 + 서버 약관 2개 = 3개 항목)")
    func viewDidLoadEmitsInitialTerms() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) { sut.send(.viewDidLoad) }

        let hasInitialTerms = outputs.contains {
            if case .initialTerms(let terms) = $0 { return terms.count == 3 }
            return false
        }
        #expect(hasInitialTerms)
    }

    @Test("viewDidLoad → 첫 항목은 연령확인(.ageConfirmation)이다")
    func firstItemIsAgeConfirmation() async throws {
        let sut = makeSUT()
        let outputs = try await collectAsync(sut.output) { sut.send(.viewDidLoad) }

        let firstIsAgeConfirmation = outputs.contains {
            if case .initialTerms(let terms) = $0 { return terms.first?.kind == .ageConfirmation }
            return false
        }
        #expect(firstIsAgeConfirmation)
    }

    @Test("viewDidLoad → 약관 목록 fetch 실패 시 showErrorAlert")
    func fetchFailureShowsErrorAlert() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(termsService: termsService)

        let outputs = try await collectAsync(sut.output) { sut.send(.viewDidLoad) }

        let hasErrorAlert = outputs.contains {
            if case .showErrorAlert = $0 { return true }
            return false
        }
        #expect(hasErrorAlert)
    }

    // MARK: - 전체 동의 토글

    @Test("allToggle → 3개 항목 모두 isAgreed true")
    func allToggleAgreesAll() async throws {
        let sut = makeSUT()
        try await loadTerms(sut)
        let outputs = collect(sut.output) { sut.send(.allToggle) }

        #expect(outputs.contains(.allAgreeChanged(true)))
        #expect(outputs.contains(.termChanged(index: 0, isAgreed: true)))
        #expect(outputs.contains(.termChanged(index: 1, isAgreed: true)))
        #expect(outputs.contains(.termChanged(index: 2, isAgreed: true)))
    }

    // MARK: - 회원가입 (agreedTermIds/over14Confirmed 전달)

    @Test("signUpButtonTapped 성공 → signUpSucceeded")
    func signUpButtonTappedSuccessEmitsSignUpSucceeded() async throws {
        let sut = makeSUT()
        try await loadTerms(sut)
        sut.send(.allToggle)

        let outputs = try await collectAsync(sut.output) { sut.send(.signUpButtonTapped) }

        #expect(outputs.contains(.signUpSucceeded))
    }

    @Test("가입 실패(reason: under_age) → showErrorAlert(연령 미충족 안내)")
    func underAgeFailureShowsAgeAlert() async throws {
        let signUpService = MockSignUpService()
        signUpService.joinResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: -1, message: "만 14세 이상만 가입할 수 있습니다.", reason: "under_age", detailCode: 2003)
        )
        let sut = makeSUT(signUpService: signUpService)
        try await loadTerms(sut)
        sut.send(.allToggle)

        let outputs = try await collectAsync(sut.output) { sut.send(.signUpButtonTapped) }

        let hasAgeAlert = outputs.contains {
            if case .showErrorAlert(let title, _) = $0 { return title == "만 14세 이상만 가입할 수 있습니다." }
            return false
        }
        #expect(hasAgeAlert)
    }

    // MARK: - Helpers

    private func loadTerms(_ sut: TermsAgreementModalViewModel) async throws {
        _ = try await collectAsync(sut.output) { sut.send(.viewDidLoad) }
    }
}
