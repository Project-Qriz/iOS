//
//  MockTermsService.swift
//  AccountTests
//

import Foundation
@testable import QRIZNetwork

final class MockTermsService: TermsService, @unchecked Sendable {
    static let defaultResult: Result<TermsResponse, Error> = .success(
        TermsResponse(code: 1, msg: "ok", data: [
            TermsListItem(id: 1, title: "서비스 이용약관", documentUrl: nil),
            TermsListItem(id: 2, title: "개인정보 처리방침", documentUrl: "https://example.com/privacy")
        ])
    )

    var fetchTermsResult: Result<TermsResponse, Error> = MockTermsService.defaultResult

    func fetchTerms() async throws -> TermsResponse {
        try fetchTermsResult.get()
    }
}
