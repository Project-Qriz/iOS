//
//  SocialJoinTermsSubmitter.swift
//  QRIZ
//

import QRIZNetwork
import QRIZUtils

/// 엄격 모드 신규 소셜 회원: 온보딩 토큰으로 `/api/auth/social/join`을 호출해 가입을 완료한다.
@MainActor
struct SocialJoinTermsSubmitter: TermsAgreementSubmitter {
    let onboarding: SocialOnboarding
    let socialJoinService: SocialJoinService
    let userInfo: UserInfoManager
    var analyticsService: any AnalyticsService = AnalyticsManager.shared
    let onJoined: (SocialLoginResponse) -> Void

    func submit(_ agreement: TermsAgreement) async throws {
        let response: SocialLoginResponse
        do {
            response = try await socialJoinService.join(
                onboardingToken: onboarding.onboardingToken,
                over14Confirmed: agreement.over14Confirmed,
                agreedTermIds: agreement.agreedTermIds
            )
        } catch {
            throw Self.submissionError(for: error)
        }

        let user = response.data.user
        userInfo.update(from: user)
        // 가입 완료와 동시에 로그인 상태가 되므로, 관대 모드 신규 가입(로그인 이벤트만 기록)과 지표를 맞추기 위해 둘 다 남긴다.
        let method = AnalyticsEvent.LoginMethod(provider: user.provider)
        analyticsService.log(.signUp(method))
        analyticsService.log(.login(method))
        onJoined(response)
    }

    static func submissionError(for error: Error) -> TermsAgreementSubmissionError {
        switch error {
        case let NetworkError.clientError(409, _, _, reason, detailCode)
            where reason == "under_age" || detailCode == 2003:
            // 서버가 회원을 만들지 않고 소셜 연동도 해제하므로 재시도할 수 없다.
            return TermsAgreementSubmissionError(
                title: "가입할 수 없어요",
                description: "만 14세 미만은 QRIZ에 가입할 수 없습니다.",
                endsFlow: true
            )
        case NetworkError.unAuthorizedError:
            // 온보딩 토큰(20분) 만료: 소셜 로그인부터 다시 해야 새 토큰을 받을 수 있다.
            return TermsAgreementSubmissionError(
                title: "가입 가능 시간이 지났어요",
                description: "소셜 로그인을 다시 진행해 주세요.",
                endsFlow: true
            )
        default:
            return TermsAgreementSubmissionError(
                title: "가입에 실패했습니다.",
                description: "잠시 후 다시 시도해 주세요.",
                endsFlow: false
            )
        }
    }
}
