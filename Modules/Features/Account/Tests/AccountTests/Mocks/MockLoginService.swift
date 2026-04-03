//
//  MockLoginService.swift
//  AccountTests
//

import Foundation
@testable import Network
import QRIZUtils

final class MockLoginService: LoginService, @unchecked Sendable {

    var loginResult: Result<LoginResponse, Error> = .success(
        LoginResponse(
            code: 1,
            msg: "ok",
            data: .init(
                refreshToken: nil,
                refreshExpiry: nil,
                user: UserInfo(
                    name: "테스트",
                    userId: "test123",
                    email: "test@test.com",
                    previewTestStatus: .notStarted,
                    provider: nil
                )
            )
        )
    )

    func login(id: String, password: String) async throws -> LoginResponse {
        try loginResult.get()
    }
}
