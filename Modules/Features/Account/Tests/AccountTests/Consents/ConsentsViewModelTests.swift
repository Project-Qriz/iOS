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
        onAccountDestroyed: @escaping () -> Void = {}
    ) -> ConsentsViewModel {
        ConsentsViewModel(
            termsService: termsService,
            consentsService: consentsService,
            myPageService: myPageService,
            accessTokenProvider: { "test-token" },
            reAgreementRequired: reAgreementRequired,
            ageVerificationRequired: ageVerificationRequired,
            onComplete: onComplete,
            onAccountDestroyed: onAccountDestroyed
        )
    }

    @Test("재동의만 필요 → 연령확인 섹션 없이 약관 목록만 로드")
    func reAgreementOnlyLoadsTermsOnly() async throws {
        let sut = makeSUT(reAgreementRequired: true, ageVerificationRequired: false)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.count == 2)
        #expect(sut.showsAgeSection == false)
    }

    @Test("연령확인만 필요 → 약관 없이 연령확인 섹션만 표시")
    func ageVerificationOnlyShowsAgeSection() async throws {
        let sut = makeSUT(reAgreementRequired: false, ageVerificationRequired: true)
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.terms.isEmpty)
        #expect(sut.showsAgeSection == true)
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
}
