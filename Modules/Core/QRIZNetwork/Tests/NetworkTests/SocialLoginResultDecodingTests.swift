import Testing
import Foundation
@testable import QRIZNetwork

@Suite("소셜 로그인 응답(관대/엄격 모드) 디코딩 테스트")
struct SocialLoginResultDecodingTests {

    @Test("user가 담긴 응답(기존 회원·관대 모드 신규 가입) → loggedIn")
    func decodesLoggedIn() throws {
        let json = #"""
        {"code": 1, "msg": "소셜 로그인 성공", "data": {
            "refreshToken": "r", "refreshExpiry": "2026-02-20T12:00:00",
            "reAgreementRequired": true, "ageVerificationRequired": true,
            "user": {"name": "qriz", "userId": "qriz1234", "email": "user@example.com", "previewTestStatus": "NOT_STARTED", "provider": "KAKAO"}
        }}
        """#.data(using: .utf8)!

        let result = try JSONDecoder().decode(SocialLoginResult.self, from: json)

        guard case .loggedIn(let response) = result else {
            Issue.record("loggedIn이어야 한다: \(result)")
            return
        }
        #expect(response.data.user.userId == "qriz1234")
        #expect(response.data.needsConsent == true)
    }

    @Test("엄격 모드 신규 회원 응답 → onboardingRequired와 토큰")
    func decodesOnboardingRequired() throws {
        let json = #"""
        {"code": 1, "msg": "가입을 완료하려면 연령 확인과 약관 동의가 필요합니다", "data": {
            "onboardingRequired": true, "onboardingToken": "onboarding-token", "expiresIn": 1200
        }}
        """#.data(using: .utf8)!

        let result = try JSONDecoder().decode(SocialLoginResult.self, from: json)

        guard case .onboardingRequired(let onboarding) = result else {
            Issue.record("onboardingRequired여야 한다: \(result)")
            return
        }
        #expect(onboarding == SocialOnboarding(onboardingToken: "onboarding-token", expiresIn: 1200))
    }
}

@Suite("SocialJoinRequest 인코딩 테스트")
struct SocialJoinRequestTests {

    @Test("over14Confirmed/agreedTermIds가 body에 포함되고 socialAccessToken은 보내지 않는다")
    func bodyIncludesFields() throws {
        let request = SocialJoinRequest(onboardingToken: "t", over14Confirmed: true, agreedTermIds: [1, 2])

        let data = try request.body.map { try JSONEncoder().encode($0) } ?? Data()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["over14Confirmed"] as? Bool == true)
        #expect(json?["agreedTermIds"] as? [Int] == [1, 2])
        #expect(json?["socialAccessToken"] == nil)
    }

    @Test("Authorization 헤더에 온보딩 토큰이 그대로 실리고 가입 경로로 요청한다")
    func headerAndPath() {
        let request = SocialJoinRequest(onboardingToken: "onboarding-token", over14Confirmed: true, agreedTermIds: [])

        #expect(request.headers[HTTPHeaderField.authorization.rawValue] == "onboarding-token")
        #expect(request.path == "/api/auth/social/join")
        #expect(request.method == .post)
    }
}
