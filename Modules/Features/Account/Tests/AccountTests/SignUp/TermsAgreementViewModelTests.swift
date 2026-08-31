//
//  TermsAgreementViewModelTests.swift
//  AccountTests
//

import Testing
@testable import Account
import QRIZNetwork

@MainActor
@Suite("TermsAgreementViewModel 테스트", .serialized)
struct TermsAgreementViewModelTests {

    private func makeSUT(
        signUpService: MockSignUpService = .init(),
        termsService: MockTermsService = .init(),
        onDismiss: @escaping () -> Void = {},
        onTermsAgreed: @escaping () -> Void = {}
    ) -> (sut: TermsAgreementViewModel, flowVM: SignUpFlowViewModel) {
        let flowVM = SignUpFlowViewModel(signUpService: signUpService)
        let sut = TermsAgreementViewModel(
            signUpFlowViewModel: flowVM,
            termsService: termsService,
            onDismiss: onDismiss,
            onTermsAgreed: onTermsAgreed
        )
        return (sut, flowVM)
    }

    // MARK: - 초기화

    @Test("onAppear → 연령확인 1개 + 서버 약관 2개 = 3개 항목 로드")
    func onAppearLoadsThreeItems() async throws {
        let (sut, _) = makeSUT()
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.count == 3)
    }

    @Test("onAppear → 첫 항목은 연령확인(.ageConfirmation)이다")
    func firstItemIsAgeConfirmation() async throws {
        let (sut, _) = makeSUT()
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.first?.kind == .ageConfirmation)
    }

    @Test("onAppear → 클라이언트가 모르는 약관 타입은 목록에서 제외되고 나머지는 정상 로드된다")
    func onAppearSkipsUnknownTermType() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .success(
            TermsResponse(code: 1, msg: "ok", data: [
                TermsListItem(id: 1, type: .service, documentUrl: nil),
                TermsListItem(id: 3, type: .unknown("MARKETING"), documentUrl: nil),
                TermsListItem(id: 2, type: .privacy, documentUrl: "https://example.com/privacy")
            ])
        )
        let (sut, _) = makeSUT(termsService: termsService)

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        // 연령확인 1개 + service/privacy 2개 = 3개 (unknown 타입인 marketing은 제외)
        #expect(sut.terms.count == 3)
        #expect(sut.terms.contains { $0.id == 3 } == false)
    }

    @Test("onAppear → 약관 목록 fetch 실패 시 errorAlert 표시")
    func fetchFailureShowsErrorAlert() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .failure(NetworkError.serverError(httpStatus: 500))
        let (sut, _) = makeSUT(termsService: termsService)

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorAlert != nil)
    }

    // MARK: - 전체 동의 토글

    @Test("약관 목록이 아직 로딩 중(빈 배열)일 때 전체동의를 눌러도 제출 버튼이 활성화되지 않는다")
    func toggleAllTermsBeforeLoadDoesNotEnableSubmit() async throws {
        let (sut, _) = makeSUT()
        sut.onAppear()
        // loadTerms()의 await가 재개되기 전(terms가 아직 빈 배열인 시점)에 토글한다.
        sut.toggleAllTerms()

        #expect(sut.terms.isEmpty)
        #expect(sut.isSubmitEnabled == false)
    }

    @Test("toggleAllTerms → 3개 항목 모두 isAgreed true, 제출 버튼 활성화")
    func toggleAllTermsAgreesAll() async throws {
        let (sut, _) = makeSUT()
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.toggleAllTerms()

        let allAgreed = sut.terms.allSatisfy(\.isAgreed)
        #expect(allAgreed)
        #expect(sut.isSubmitEnabled == true)
    }

    // MARK: - 약관 동의 (agreedTermIds/over14Confirmed 저장 및 다음 화면 이동)

    @Test("submitTapped → onTermsAgreed 호출 (join API는 호출하지 않는다)")
    func submitTappedCallsOnTermsAgreed() async throws {
        let signUpService = MockSignUpService()
        var termsAgreedCalled = false
        let (sut, _) = makeSUT(signUpService: signUpService, onTermsAgreed: { termsAgreedCalled = true })
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()

        sut.submitTapped()

        #expect(termsAgreedCalled == true)
        #expect(signUpService.lastJoinOver14Confirmed == nil)
    }

    @Test("submitTapped → over14Confirmed/agreedTermIds가 SignUpFlowViewModel에 저장된다")
    func submitTappedStoresConsentStateOnFlowViewModel() async throws {
        let signUpService = MockSignUpService()
        let (sut, flowVM) = makeSUT(signUpService: signUpService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()
        sut.submitTapped()

        flowVM.updateEmail("a@b.com")
        flowVM.updateName("테스트")
        flowVM.updateID("test1234")
        flowVM.updatePassword("Valid@1234")
        _ = try await flowVM.join()

        #expect(signUpService.lastJoinOver14Confirmed == true)
        #expect(signUpService.lastJoinAgreedTermIds == [1, 2])
    }

    // MARK: - 취소

    @Test("dismissTapped → onDismiss 호출")
    func dismissTappedCallsOnDismiss() async throws {
        var dismissed = false
        let (sut, _) = makeSUT(onDismiss: { dismissed = true })

        sut.dismissTapped()

        #expect(dismissed == true)
    }
}
