import Testing
import Foundation
@testable import QRIZNetwork

@Suite("TermsResponse 디코딩 테스트")
struct TermsRequestDecodingTests {
    @Test("documentUrl이 있는 항목과 없는 항목을 모두 디코딩한다")
    func decodesMixedDocumentUrl() throws {
        let json = #"""
        {
          "code": 1, "msg": "ok",
          "data": [
            {"id": 1, "title": "서비스 이용약관", "documentUrl": null},
            {"id": 2, "title": "개인정보 처리방침", "documentUrl": "https://example.com/privacy"}
          ]
        }
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(TermsResponse.self, from: json)

        #expect(response.data.count == 2)
        #expect(response.data[0].documentUrl == nil)
        #expect(response.data[1].documentUrl == "https://example.com/privacy")
    }
}
