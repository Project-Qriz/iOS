import Testing
import Foundation
@testable import QRIZNetwork

@Suite("ConsentsRequest body 인코딩 테스트")
struct ConsentsRequestBodyTests {
    @Test("over14Confirmed/agreedTermIds가 body에 포함된다")
    func bodyIncludesFields() throws {
        let request = ConsentsRequest(accessToken: "token", over14Confirmed: true, agreedTermIds: [1, 2])

        let encoder = JSONEncoder()
        let data = try request.body.map { try encoder.encode($0) } ?? Data()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["over14Confirmed"] as? Bool == true)
        #expect(json?["agreedTermIds"] as? [Int] == [1, 2])
    }

    @Test("Authorization 헤더에 accessToken이 실린다")
    func headerIncludesAccessToken() {
        let request = ConsentsRequest(accessToken: "token-abc", over14Confirmed: true, agreedTermIds: [])
        #expect(request.headers[HTTPHeaderField.authorization.rawValue] == "token-abc")
    }
}
