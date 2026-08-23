import Testing
import Foundation
@testable import QRIZNetwork

@Suite("로그인 응답 재동의/연령확인 플래그 디코딩 테스트")
struct LoginResponseConsentDecodingTests {

    @Test("data 최상위에 플래그가 있으면 needsConsent가 이를 반영한다")
    func topLevelFlags() throws {
        let json = #"""
        {"code": 1, "msg": "ok", "data": {
            "refreshToken": null, "refreshExpiry": null,
            "reAgreementRequired": true, "ageVerificationRequired": false,
            "user": {"name": "n", "userId": "u", "email": "e", "previewTestStatus": "NOT_STARTED", "provider": null}
        }}
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(LoginResponse.self, from: json)
        #expect(response.data.needsConsent == true)
    }

    @Test("data.user 내부에 플래그가 있으면 needsConsent가 이를 반영한다")
    func nestedUserFlags() throws {
        let json = #"""
        {"code": 1, "msg": "ok", "data": {
            "refreshToken": null, "refreshExpiry": null,
            "user": {
                "name": "n", "userId": "u", "email": "e", "previewTestStatus": "NOT_STARTED", "provider": null,
                "reAgreementRequired": false, "ageVerificationRequired": true
            }
        }}
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(LoginResponse.self, from: json)
        #expect(response.data.needsConsent == true)
    }

    @Test("플래그가 전혀 없으면 needsConsent는 false")
    func noFlags() throws {
        let json = #"""
        {"code": 1, "msg": "ok", "data": {
            "refreshToken": null, "refreshExpiry": null,
            "user": {"name": "n", "userId": "u", "email": "e", "previewTestStatus": "NOT_STARTED", "provider": null}
        }}
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(LoginResponse.self, from: json)
        #expect(response.data.needsConsent == false)
    }
}
