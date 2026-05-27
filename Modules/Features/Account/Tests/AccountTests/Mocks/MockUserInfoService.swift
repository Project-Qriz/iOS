//
//  MockUserInfoService.swift
//  AccountTests
//

import Foundation
import QRIZNetwork
import QRIZUtils

final class MockUserInfoService: UserInfoService, @unchecked Sendable {

    var getUserInfoResult: Result<UserInfoResponse, Error> = .success(
        UserInfoResponse(
            code: 1,
            msg: "ok",
            data: UserInfo(
                name: "테스트",
                userId: "test123",
                email: "test@test.com",
                previewTestStatus: .notStarted,
                provider: nil
            )
        )
    )

    func getUserInfo() async throws -> UserInfoResponse {
        try getUserInfoResult.get()
    }
}
