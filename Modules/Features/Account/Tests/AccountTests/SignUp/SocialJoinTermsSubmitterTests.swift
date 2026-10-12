//
//  SocialJoinTermsSubmitterTests.swift
//  AccountTests
//

import Testing
@testable import Account
import QRIZNetwork
import QRIZUtils

@MainActor
@Suite("SocialJoinTermsSubmitter 테스트", .serialized)
struct SocialJoinTermsSubmitterTests {

    private let agreement = TermsAgreement(over14Confirmed: true, agreedTermIds: [1, 2])

    private func makeSUT(
        service: MockSocialJoinService,
        analytics: SpyAnalyticsService = .init(),
        onJoined: @escaping (SocialLoginResponse) -> Void = { _ in }
    ) -> SocialJoinTermsSubmitter {
        SocialJoinTermsSubmitter(
            onboarding: SocialOnboarding(onboardingToken: "onboarding-token", expiresIn: 1200),
            socialJoinService: service,
            userInfo: .shared,
            analyticsService: analytics,
            onJoined: onJoined
        )
    }

    @Test("가입 성공 → 온보딩 토큰과 동의 내용으로 join 호출, 사용자 정보 저장 후 onJoined")
    func joinSucceeds() async throws {
        let service = MockSocialJoinService()
        var joined: SocialLoginResponse?
        let sut = makeSUT(service: service, onJoined: { joined = $0 })

        try await sut.submit(agreement)

        #expect(service.lastOnboardingToken == "onboarding-token")
        #expect(service.lastOver14Confirmed == true)
        #expect(service.lastAgreedTermIds == [1, 2])
        #expect(joined?.data.user.userId == "social-new")
        #expect(UserInfoManager.shared.userId == "social-new")
    }

    @Test("가입 성공 → provider 기준으로 sign_up, login 이벤트를 순서대로 기록")
    func joinLogsSignUpAndLogin() async throws {
        let analytics = SpyAnalyticsService()
        let sut = makeSUT(service: MockSocialJoinService(), analytics: analytics)

        try await sut.submit(agreement)

        #expect(analytics.loggedEvents == [
            String(describing: AnalyticsEvent.signUp(.kakao)),
            String(describing: AnalyticsEvent.login(.kakao))
        ])
    }

    @Test("409 under_age → 재시도 불가 알럿(endsFlow), onJoined 호출 안 함")
    func underAgeEndsFlow() async {
        let service = MockSocialJoinService()
        service.joinResult = .failure(NetworkError.clientError(
            httpStatus: 409, serverCode: -1, message: "under age", reason: "under_age", detailCode: 2003
        ))
        var joinedCalled = false
        let analytics = SpyAnalyticsService()
        let sut = makeSUT(service: service, analytics: analytics, onJoined: { _ in joinedCalled = true })

        await #expect(throws: TermsAgreementSubmissionError(
            title: "가입할 수 없어요",
            description: "만 14세 미만은 QRIZ에 가입할 수 없습니다.",
            endsFlow: true
        )) {
            try await sut.submit(agreement)
        }
        #expect(!joinedCalled)
        #expect(analytics.loggedEvents.isEmpty)
    }

    @Test("401 온보딩 토큰 만료 → 다시 로그인 안내(endsFlow)")
    func expiredTokenEndsFlow() {
        let error = SocialJoinTermsSubmitter.submissionError(for: NetworkError.unAuthorizedError(detailCode: nil))
        #expect(error.endsFlow)
        #expect(error.title == "가입 가능 시간이 지났어요")
    }

    @Test("기타 실패(400/5xx) → 재시도 가능한 일반 알럿")
    func otherFailureIsRetryable() {
        let badRequest = SocialJoinTermsSubmitter.submissionError(for: NetworkError.clientError(
            httpStatus: 400, serverCode: -1, message: "필수 약관 누락", reason: nil, detailCode: nil
        ))
        let serverError = SocialJoinTermsSubmitter.submissionError(for: NetworkError.serverError(httpStatus: 500))

        #expect(!badRequest.endsFlow)
        #expect(!serverError.endsFlow)
        #expect(serverError.title == "가입에 실패했습니다.")
    }
}
