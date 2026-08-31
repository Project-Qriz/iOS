//
//  MockConsentsService.swift
//  AccountTests
//

import Foundation
@testable import QRIZNetwork

final class MockConsentsService: ConsentsService, @unchecked Sendable {
    var submitResult: Result<ConsentsResponse, Error> = .success(
        ConsentsResponse(code: 1, msg: "ok", data: .init(reAgreementRequired: false, ageVerificationRequired: false))
    )
    private(set) var lastOver14Confirmed: Bool?
    private(set) var lastAgreedTermIds: [Int]?

    func submitConsents(accessToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) async throws -> ConsentsResponse {
        lastOver14Confirmed = over14Confirmed
        lastAgreedTermIds = agreedTermIds
        return try submitResult.get()
    }
}
