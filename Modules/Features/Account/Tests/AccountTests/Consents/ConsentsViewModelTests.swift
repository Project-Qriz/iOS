import Testing
@testable import Account
import QRIZNetwork

@MainActor
@Suite("ConsentsViewModel 테스트", .serialized)
struct ConsentsViewModelTests {

    private func makeSUT(
        termsService: MockTermsService = .init(),
        consentsService: MockConsentsService = .init(),
        myPageService: MockMyPageService = .init(),
        reAgreementRequired: Bool = true,
        ageVerificationRequired: Bool = false,
        onComplete: @escaping () -> Void = {},
        onAccountDestroyed: @escaping () -> Void = {},
        onDeclined: @escaping () -> Void = {}
    ) -> ConsentsViewModel {
        ConsentsViewModel(
            termsService: termsService,
            consentsService: consentsService,
            myPageService: myPageService,
            accessTokenProvider: { "test-token" },
            reAgreementRequired: reAgreementRequired,
            ageVerificationRequired: ageVerificationRequired,
            onComplete: onComplete,
            onAccountDestroyed: onAccountDestroyed,
            onDeclined: onDeclined
        )
    }

    @Test("재동의만 필요 → 연령확인 섹션 없이 약관 섹션만 표시, 약관은 미체크 상태로 로드")
    func reAgreementOnlyLoadsTermsOnly() async throws {
        let sut = makeSUT(reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.count == 2)
        #expect(sut.showsTermsSection == true)
        #expect(sut.showsAgeSection == false)
        let noneAgreed = sut.terms.allSatisfy { $0.isAgreed == false }
        #expect(noneAgreed)
    }

    @Test("연령확인만 필요 → 약관 섹션은 숨기지만 기존 동의 약관은 체크된 상태로 로드한다")
    func ageVerificationOnlyShowsAgeSection() async throws {
        let sut = makeSUT(reAgreementRequired: false, ageVerificationRequired: true)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.showsTermsSection == false)
        #expect(sut.showsAgeSection == true)
        #expect(sut.terms.count == 2)
        let allPreAgreed = sut.terms.allSatisfy(\.isAgreed)
        #expect(allPreAgreed)
    }

    @Test("약관 목록의 각 항목에 로컬 PDF 폴백 이름이 채워진다")
    func loadedTermsCarryBundledPDFName() async throws {
        let sut = makeSUT(reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.first?.pdfName == "TermsOfService")
        #expect(sut.terms.last?.pdfName == "PrivacyPolicy")
    }

    @Test("모든 항목 동의 시 isSubmitEnabled true")
    func allAgreedEnablesSubmit() async throws {
        let sut = makeSUT(reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.toggleAllTerms()
        #expect(sut.isSubmitEnabled == true)
    }

    @Test("제출 성공(둘 다 false) → onComplete 호출")
    func submitSuccessCallsOnComplete() async throws {
        var completed = false
        let sut = makeSUT(onComplete: { completed = true })
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(completed == true)
    }

    @Test("제출 시 재동의 대상이 아니면 기존 동의 상태(true)로 over14Confirmed를 채워 보낸다")
    func submitFillsOver14ConfirmedTrueWhenNotRequired() async throws {
        let consentsService = MockConsentsService()
        let sut = makeSUT(consentsService: consentsService, reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(consentsService.lastOver14Confirmed == true)
    }

    @Test("연령확인에서 체크 해제 상태로 제출 → 개인정보처리방침 재확인 알럿 표시")
    func ageUncheckedShowsPrivacyPolicyReconfirmation() async throws {
        let sut = makeSUT(reAgreementRequired: false, ageVerificationRequired: true)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        // ageConfirmed 기본값 false 상태 그대로 제출

        sut.submitTapped()
        #expect(sut.showAgeReconfirmAlert == true)
    }

    @Test("재확인 후에도 연령 미충족 확정 → onAccountDestroyed 호출, deleteAccount 1회 호출")
    func ageReconfirmedStillUnderAgeDestroysAccount() async throws {
        let myPageService = MockMyPageService()
        var destroyed = false
        let sut = makeSUT(
            myPageService: myPageService,
            reAgreementRequired: false,
            ageVerificationRequired: true,
            onAccountDestroyed: { destroyed = true }
        )
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.submitTapped()

        sut.ageReconfirmationDenied()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(destroyed == true)
        #expect(myPageService.deleteAccountCallCount == 1)
    }

    // MARK: - agreedTermIds

    @Test("재동의 대상이 아니면 기존 동의 약관 id를 그대로 실어 제출한다")
    func submitSendsExistingAgreedTermIdsWhenReAgreementNotRequired() async throws {
        let consentsService = MockConsentsService()
        let sut = makeSUT(consentsService: consentsService, reAgreementRequired: false, ageVerificationRequired: true)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAgeConfirmation()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(consentsService.lastAgreedTermIds == [1, 2])
        #expect(consentsService.lastOver14Confirmed == true)
    }

    @Test("재동의 대상이면 사용자가 체크한 약관 id만 제출한다")
    func submitSendsOnlyCheckedTermIdsWhenReAgreementRequired() async throws {
        let consentsService = MockConsentsService()
        let sut = makeSUT(consentsService: consentsService, reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleTerm(at: 0)

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(consentsService.lastAgreedTermIds == [1])
    }

    // MARK: - 제출 버튼 활성화

    @Test("연령확인만 필요한 경우 약관 로드 후 연령 체크만으로 제출 활성화")
    func ageOnlyEnablesSubmitAfterAgeChecked() async throws {
        let sut = makeSUT(reAgreementRequired: false, ageVerificationRequired: true)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.isSubmitEnabled == false)
        sut.toggleAgeConfirmation()
        #expect(sut.isSubmitEnabled == true)
    }

    @Test("약관 fetch 실패 시 제출은 비활성 상태로 남는다")
    func fetchFailureKeepsSubmitDisabled() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(termsService: termsService, reAgreementRequired: false, ageVerificationRequired: true)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.toggleAgeConfirmation()
        #expect(sut.isSubmitEnabled == false)
    }

    // MARK: - 재시도

    @Test("약관 fetch 실패 → 재시도 가능한 에러 알럿 표시")
    func fetchFailureShowsRetryableErrorAlert() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(termsService: termsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorAlert?.canRetryLoad == true)
        #expect(sut.terms.isEmpty)
    }

    @Test("retryLoadTerms → onAppear 가드와 무관하게 약관을 다시 조회한다")
    func retryLoadTermsRefetchesAfterFailure() async throws {
        let termsService = MockTermsService()
        termsService.fetchTermsResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(termsService: termsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.terms.isEmpty)

        termsService.fetchTermsResult = MockTermsService.defaultResult
        sut.retryLoadTerms()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.count == 2)
    }

    @Test("제출 실패 알럿은 약관 재조회로 복구하지 않는다(canRetryLoad == false)")
    func submitFailureAlertIsNotLoadRetryable() async throws {
        let consentsService = MockConsentsService()
        consentsService.submitResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(consentsService: consentsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorAlert?.canRetryLoad == false)
    }

    @Test("제출 후에도 플래그가 남으면 재시도를 안내하는 메시지를 보여준다")
    func stillRequiredAfterSubmitShowsRetryMessage() async throws {
        let consentsService = MockConsentsService()
        consentsService.submitResult = .success(
            ConsentsResponse(code: 1, msg: "ok", data: .init(reAgreementRequired: true, ageVerificationRequired: false))
        )
        let sut = makeSUT(consentsService: consentsService)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()

        sut.submitTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorAlert?.title == "제출이 완료되지 않았습니다.")
    }

    // MARK: - 재진입 / 거부

    @Test("onAppear 재진입 시 이미 토글한 체크가 초기화되지 않는다")
    func reappearDoesNotResetCheckedTerms() async throws {
        let sut = makeSUT(reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.toggleAllTerms()
        let agreedBeforeReappear = sut.terms.allSatisfy(\.isAgreed)
        #expect(agreedBeforeReappear)

        // 약관 상세 모달을 띄웠다 닫으면 SwiftUI가 onAppear를 다시 호출한다.
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        let agreedAfterReappear = sut.terms.allSatisfy(\.isAgreed)
        #expect(agreedAfterReappear)
        #expect(sut.isSubmitEnabled == true)
    }

    @Test("declineTapped → 계정 파기 없이 onDeclined만 호출")
    func declineTappedCallsOnDeclinedWithoutDestroyingAccount() async throws {
        let myPageService = MockMyPageService()
        var declined = false
        var destroyed = false
        let sut = makeSUT(
            myPageService: myPageService,
            onAccountDestroyed: { destroyed = true },
            onDeclined: { declined = true }
        )

        sut.declineTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(declined == true)
        #expect(destroyed == false)
        #expect(myPageService.deleteAccountCallCount == 0)
    }
}
