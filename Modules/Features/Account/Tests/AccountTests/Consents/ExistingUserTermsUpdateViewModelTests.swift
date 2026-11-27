import Testing
@testable import Account
import QRIZNetwork

@MainActor
@Suite("ExistingUserTermsUpdateViewModel 테스트", .serialized)
struct ExistingUserTermsUpdateViewModelTests {

    private func makeSUT(
        termsService: MockTermsService = .init(),
        consentsService: MockConsentsService = .init(),
        accessToken: String? = "test-token",
        onComplete: @escaping () -> Void = {}
    ) -> ExistingUserTermsUpdateViewModel {
        ExistingUserTermsUpdateViewModel(
            termsService: termsService,
            consentsService: consentsService,
            accessTokenProvider: { accessToken },
            onComplete: onComplete
        )
    }

    @Test("onAppear → 개인정보 처리방침 항목만 privacyTerm에 채워진다")
    func onAppearLoadsPrivacyTermOnly() async throws {
        let sut = makeSUT()
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.privacyTerm?.kind == .term(id: 2))
    }

    @Test("약관이 아직 로딩 중일 때 두 체크박스를 켜도 제출 버튼이 활성화되지 않는다")
    func togglingBeforeLoadDoesNotEnableSubmit() async throws {
        let sut = makeSUT()
        sut.onAppear()
        // loadTerms()의 await가 재개되기 전(allTerms가 아직 빈 배열인 시점)에 토글한다.
        sut.toggleAge()
        sut.togglePrivacy()

        #expect(sut.isSubmitEnabled == false)
    }

    @Test("연령확인/개인정보 둘 다 체크해야 제출 버튼이 활성화된다")
    func bothChecksRequiredToEnableSubmit() async throws {
        let sut = makeSUT()
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.isSubmitEnabled == false)
        sut.toggleAge()
        #expect(sut.isSubmitEnabled == false)
        sut.togglePrivacy()
        #expect(sut.isSubmitEnabled == true)
    }

    @Test("제출 시 화면에 없는 약관(서비스 이용약관)은 자동으로 포함되고, 개인정보는 체크한 경우에만 포함된다")
    func submitAutoAgreesHiddenTerms() async throws {
        let consentsService = MockConsentsService()
        let sut = makeSUT(consentsService: consentsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAge()
        sut.togglePrivacy()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(consentsService.lastAgreedTermIds == [1, 2])
        #expect(consentsService.lastOver14Confirmed == true)
    }

    @Test("개인정보를 체크하지 않고 제출하면 그 id는 제외된 채 서비스 이용약관만 포함된다")
    func submitExcludesUncheckedPrivacy() async throws {
        // isSubmitEnabled 가드 없이 submitTapped를 직접 호출해도(버튼이 비활성화된 상태를 가정하지 않고)
        // 로직 자체가 privacyAgreed를 정확히 반영하는지 확인한다.
        let consentsService = MockConsentsService()
        let sut = makeSUT(consentsService: consentsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAge()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(consentsService.lastAgreedTermIds == [1])
    }

    @Test("약관 목록 조회 실패 시 errorAlert가 표시된다")
    func fetchFailureShowsErrorAlert() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(termsService: termsService)

        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorAlert != nil)
    }

    @Test("제출 성공 → onComplete 호출")
    func submitSuccessCallsOnComplete() async throws {
        var completed = false
        let sut = makeSUT(onComplete: { completed = true })
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAge()
        sut.togglePrivacy()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(completed == true)
    }

    @Test("제출이 400으로 실패하면 약관을 재조회하고, 재제출 시 새 약관 id로 보낸다")
    func submitBadRequestRefetchesTerms() async throws {
        let termsService = MockTermsService()
        let consentsService = MockConsentsService()
        consentsService.submitResult = .failure(Self.badRequest)
        let sut = makeSUT(termsService: termsService, consentsService: consentsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAge()
        sut.togglePrivacy()

        // 팝업을 띄워둔 사이 처리방침이 개정되어 id가 2 → 3으로 바뀐 상황
        termsService.fetchTermsResult = .success(TermsResponse(code: 1, msg: "ok", data: [
            TermsListItem(id: 1, type: .service, documentUrl: nil),
            TermsListItem(id: 3, type: .privacy, documentUrl: "https://example.com/privacy-v1.1")
        ]))
        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(termsService.fetchTermsCallCount == 2)
        #expect(sut.privacyTerm?.kind == .term(id: 3))
        #expect(sut.errorAlert != nil)
        // 바뀐 처리방침을 다시 확인하도록 개인정보 동의만 해제하고, 연령확인은 유지한다.
        #expect(sut.privacyAgreed == false)
        #expect(sut.ageConfirmed == true)
        #expect(sut.isSubmitEnabled == false)

        consentsService.submitResult = MockConsentsService().submitResult
        sut.togglePrivacy()
        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(consentsService.lastAgreedTermIds == [1, 3])
    }

    @Test("제출이 400이 아닌 에러로 실패하면 약관을 재조회하지 않는다")
    func submitServerErrorDoesNotRefetch() async throws {
        let termsService = MockTermsService()
        let consentsService = MockConsentsService()
        consentsService.submitResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(termsService: termsService, consentsService: consentsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAge()
        sut.togglePrivacy()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(termsService.fetchTermsCallCount == 1)
        #expect(sut.privacyAgreed == true)
        #expect(sut.errorAlert != nil)
    }

    private static let badRequest = NetworkError.clientError(
        httpStatus: 400, serverCode: -1, message: "유효하지 않은 약관입니다.", reason: nil, detailCode: nil
    )

    @Test("액세스 토큰이 없으면 제출하지 않고 errorAlert를 표시한다")
    func submitWithoutAccessTokenShowsErrorAlert() async throws {
        let consentsService = MockConsentsService()
        let sut = makeSUT(consentsService: consentsService, accessToken: nil)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAge()
        sut.togglePrivacy()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorAlert != nil)
        #expect(consentsService.lastAgreedTermIds == nil)
    }
}
