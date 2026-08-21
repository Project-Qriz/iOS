import Testing
import Foundation
@testable import QRIZNetwork

@Suite("JoinRequest body 인코딩 테스트")
struct JoinRequestBodyTests {
    @Test("over14Confirmed/agreedTermIds가 body에 포함된다")
    func bodyIncludesNewFields() throws {
        let request = JoinRequest(
            username: "test", password: "pw", nickname: "닉네임", email: "a@b.com",
            over14Confirmed: true, agreedTermIds: [1, 2]
        )

        let body = JoinRequestBody(
            username: "test",
            password: "pw",
            nickname: "닉네임",
            email: "a@b.com",
            over14Confirmed: true,
            agreedTermIds: [1, 2]
        )

        let data = try JSONEncoder().encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["over14Confirmed"] as? Bool == true)
        #expect(json?["agreedTermIds"] as? [Int] == [1, 2])
        #expect(json?["username"] as? String == "test")
    }
}
