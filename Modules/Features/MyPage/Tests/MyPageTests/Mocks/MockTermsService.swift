import Foundation
import QRIZNetwork

final class MockTermsService: TermsService, @unchecked Sendable {

    var fetchTermsResult: Result<TermsResponse, Error> = .success(
        TermsResponse(code: 1, msg: "ok", data: [
            TermsListItem(id: 1, type: .service, documentUrl: nil),
            TermsListItem(id: 2, type: .privacy, documentUrl: "https://example.com/privacy")
        ])
    )

    func fetchTerms() async throws -> TermsResponse {
        try fetchTermsResult.get()
    }
}
