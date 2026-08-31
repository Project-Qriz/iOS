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

    @Test("알 수 없는 type 문자열이 와도 디코딩은 성공하고 .unknown으로 흡수된다")
    func unknownTypeDecodesAsUnknown() throws {
        let json = #"""
        {
          "code": 1, "msg": "ok",
          "data": [
            {"id": 3, "type": "MARKETING", "documentUrl": null}
          ]
        }
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(TermsResponse.self, from: json)

        #expect(response.data.count == 1)
        #expect(response.data[0].type == .unknown("MARKETING"))
    }

    @Test("알 수 없는 type이 섞여 있어도 나머지 알려진 항목은 그대로 디코딩된다")
    func unknownTypeMixedWithKnownTypesStillDecodesAll() throws {
        let json = #"""
        {
          "code": 1, "msg": "ok",
          "data": [
            {"id": 1, "type": "SERVICE", "documentUrl": null},
            {"id": 3, "type": "MARKETING", "documentUrl": null},
            {"id": 2, "type": "PRIVACY", "documentUrl": null}
          ]
        }
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(TermsResponse.self, from: json)

        #expect(response.data.count == 3)
        #expect(response.data[0].type == .service)
        #expect(response.data[1].type == .unknown("MARKETING"))
        #expect(response.data[2].type == .privacy)
    }
}
