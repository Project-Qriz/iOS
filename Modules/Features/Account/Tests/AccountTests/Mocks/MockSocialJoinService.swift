//
//  MockSocialJoinService.swift
//  AccountTests
//

import Foundation
import QRIZNetwork

final class MockSocialJoinService: SocialJoinService, @unchecked Sendable {
    var joinResult: Result<SocialLoginResponse, Error> = .success(
        SocialLoginResponse(
            code: 1,
            msg: "소셜 회원가입 성공",
            data: .init(
                refreshToken: "refresh",
                refreshExpiry: nil,
                user: UserInfo(
                    name: "신규",
                    userId: "social-new",
                    email: "new@test.com",
                    previewTestStatus: .notStarted,
                    provider: "KAKAO"
                ),
                reAgreementRequired: false,
                ageVerificationRequired: false
            )
        )
    )
    private(set) var lastOnboardingToken: String?
    private(set) var lastOver14Confirmed: Bool?
    private(set) var lastAgreedTermIds: [Int]?

    func join(onboardingToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) async throws -> SocialLoginResponse {
        lastOnboardingToken = onboardingToken
        lastOver14Confirmed = over14Confirmed
        lastAgreedTermIds = agreedTermIds
        return try joinResult.get()
    }
}
