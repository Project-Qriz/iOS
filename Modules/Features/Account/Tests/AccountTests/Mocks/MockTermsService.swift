//
//  MockTermsService.swift
//  AccountTests
//

import Foundation
@testable import QRIZNetwork

final class MockTermsService: TermsService, @unchecked Sendable {
    static let defaultResult: Result<TermsResponse, Error> = .success(
        TermsResponse(code: 1, msg: "ok", data: [
            TermsListItem(id: 1, type: .service, documentUrl: nil),
            TermsListItem(id: 2, type: .privacy, documentUrl: "https://example.com/privacy")
        ])
    )

    var fetchTermsResult: Result<TermsResponse, Error> = MockTermsService.defaultResult
    private(set) var fetchTermsCallCount = 0

    func fetchTerms() async throws -> TermsResponse {
        fetchTermsCallCount += 1
        return try fetchTermsResult.get()
    }
}
