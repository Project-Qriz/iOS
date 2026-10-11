//
//  SocialJoinRequest.swift
//  QRIZ
//

/// 엄격 모드 신규 소셜 회원의 가입 완료 요청. 응답 스키마는 소셜 로그인 성공 응답과 같다.
public struct SocialJoinRequest: Request, Sendable {
    public typealias Response = SocialLoginResponse

    public let path = "/api/auth/social/join"
    public let method: HTTPMethod = .post
    private let onboardingToken: String
    public let over14Confirmed: Bool
    public let agreedTermIds: [Int]

    public var body: Encodable? {
        SocialJoinRequestBody(over14Confirmed: over14Confirmed, agreedTermIds: agreedTermIds)
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: onboardingToken
        ]
    }

    public init(onboardingToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) {
        self.onboardingToken = onboardingToken
        self.over14Confirmed = over14Confirmed
        self.agreedTermIds = agreedTermIds
    }
}

/// `socialAccessToken`은 온보딩 토큰에 revoke용 토큰이 없을 때만 쓰는 fallback이라 보내지 않는다.
private struct SocialJoinRequestBody: Encodable {
    let over14Confirmed: Bool
    let agreedTermIds: [Int]
}
