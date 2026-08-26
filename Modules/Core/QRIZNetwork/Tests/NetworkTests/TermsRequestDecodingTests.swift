import Testing
import Foundation
@testable import QRIZNetwork

@Suite("TermsResponse 디코딩 테스트")
struct TermsRequestDecodingTests {
    @Test("실제 서버 스키마(type/version/effectiveDate/required 포함)를 디코딩한다")
    func decodesMixedDocumentUrl() throws {
        let json = #"""
        {
          "code": 1, "msg": "현행 약관 목록 조회 성공",
          "data": [
            {"id": 1, "type": "SERVICE", "version": "1.0", "effectiveDate": "2025-01-01", "required": true, "documentUrl": null},
            {"id": 2, "type": "PRIVACY", "version": "1.0", "effectiveDate": "2025-01-01", "required": true, "documentUrl": "https://example.com/privacy"}
          ]
        }
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(TermsResponse.self, from: json)

        #expect(response.data.count == 2)
        #expect(response.data[0].type == .service)
        #expect(response.data[0].documentUrl == nil)
        #expect(response.data[1].type == .privacy)
        #expect(response.data[1].documentUrl == "https://example.com/privacy")
    }

    @Test("알 수 없는 type 문자열이 오면 디코딩에 실패한다")
    func unknownTypeFailsDecoding() {
        let json = #"""
        {
          "code": 1, "msg": "ok",
          "data": [
            {"id": 3, "type": "MARKETING", "documentUrl": null}
          ]
        }
        """#.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(TermsResponse.self, from: json)
        }
    }
}
