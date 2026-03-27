//
//  MockSocialLoginService.swift
//  AccountTests
//

import UIKit
import Foundation
@testable import Network
import QRIZUtils

final class MockSocialLoginService: SocialLoginService, @unchecked Sendable {

    var loginResult: Result<SocialLoginResponse, Error> = .success(
        SocialLoginResponse(
            code: 1,
            msg: "ok",
            data: .init(
                refreshToken: nil,
                refreshExpiry: nil,
                user: UserInfo(
                    name: "테스트",
                    userId: "social123",
                    email: "social@test.com",
                    previewTestStatus: .notStarted,
                    provider: "KAKAO"
                )
            )
        )
    )
    var loginDelay: UInt64 = 0
    private(set) var loginCallCount = 0

    func loginWithKakao() async throws -> SocialLoginResponse {
        loginCallCount += 1
        if loginDelay > 0 { try await Task.sleep(nanoseconds: loginDelay) }
        return try loginResult.get()
    }

    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse {
        loginCallCount += 1
        if loginDelay > 0 { try await Task.sleep(nanoseconds: loginDelay) }
        return try loginResult.get()
    }

    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse {
        loginCallCount += 1
        return try loginResult.get()
    }

    func logoutKakao() async throws {}
    func unlinkKakao() async throws {}
    func logoutGoogle() async throws {}
    func logoutApple() async throws {}
}
