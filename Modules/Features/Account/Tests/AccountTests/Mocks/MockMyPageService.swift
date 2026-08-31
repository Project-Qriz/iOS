//
//  MockMyPageService.swift
//  AccountTests
//

import Foundation
@testable import QRIZNetwork
import QRIZUtils

final class MockMyPageService: MyPageService, @unchecked Sendable {
    var deleteAccountResult: Result<DeleteAccountResponse, Error> = .success(
        DeleteAccountResponse(code: 1, msg: "ok")
    )
    private(set) var deleteAccountCallCount = 0

    func fetchVersion() async throws -> VersionResponse {
        VersionResponse(code: 1, msg: "ok", data: .init(versionInfo: "1.0.0", updateInfo: "", date: ""))
    }

    func resetPlan() async throws -> DailyResetResponse {
        fatalError("Consents 테스트에서 사용하지 않음")
    }

    func deleteAccount() async throws -> DeleteAccountResponse {
        deleteAccountCallCount += 1
        return try deleteAccountResult.get()
    }

    func deleteSocialAccount(socialLoginType: SocialLogin) async throws -> SocialWithdrawResponse {
        fatalError("Consents 테스트에서 사용하지 않음")
    }
}
