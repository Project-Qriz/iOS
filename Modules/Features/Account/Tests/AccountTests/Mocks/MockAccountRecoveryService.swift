//
//  MockAccountRecoveryService.swift
//  AccountTests
//

import Foundation
@testable import Network

final class MockAccountRecoveryService: AccountRecoveryService, @unchecked Sendable {

    var findIDResult: Result<FindIDResponse, Error> = .success(
        FindIDResponse(code: 1, msg: "ok")
    )
    var findPasswordResult: Result<FindPasswordResponse, Error> = .success(
        FindPasswordResponse(code: 1, msg: "ok")
    )
    var verifyPasswordResetResult: Result<VerifyPasswordResetResponse, Error> = .success(
        VerifyPasswordResetResponse(code: 1, msg: "ok", data: .init(resetToken: "mock-token"))
    )
    var resetPasswordResult: Result<PasswordResetResponse, Error> = .success(
        PasswordResetResponse(code: 1, msg: "ok", data: nil)
    )
    private(set) var storedResetToken: String = ""

    func findID(email: String) async throws -> FindIDResponse {
        try findIDResult.get()
    }

    func findPassword(email: String) async throws -> FindPasswordResponse {
        try findPasswordResult.get()
    }

    func verifyPasswordReset(email: String, authNumber: String) async throws -> VerifyPasswordResetResponse {
        try verifyPasswordResetResult.get()
    }

    func resetPassword(password: String) async throws -> PasswordResetResponse {
        try resetPasswordResult.get()
    }

    func setResetToken(resetToken: String) {
        storedResetToken = resetToken
    }
}
