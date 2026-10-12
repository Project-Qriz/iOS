import Testing
@testable import QRIZUtils

@Suite("AnalyticsEvent.LoginMethod provider 매핑 테스트")
struct LoginMethodTests {

    @Test("서버 provider 값(대문자)을 LoginMethod로 변환한다", arguments: [
        ("KAKAO", AnalyticsEvent.LoginMethod.kakao),
        ("GOOGLE", .google),
        ("APPLE", .apple)
    ])
    func mapsKnownProviders(provider: String, expected: AnalyticsEvent.LoginMethod) {
        #expect(AnalyticsEvent.LoginMethod(provider: provider) == expected)
    }

    @Test("nil이거나 알 수 없는 provider는 unknown")
    func unknownProvider() {
        #expect(AnalyticsEvent.LoginMethod(provider: nil) == .unknown)
        #expect(AnalyticsEvent.LoginMethod(provider: "NAVER") == .unknown)
    }
}
