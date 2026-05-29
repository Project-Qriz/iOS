//
//  SnapshotServiceStubs.swift
//  AccountTests
//

import UIKit
import QRIZNetwork

final class StubLoginService: LoginService, @unchecked Sendable {
    func login(id: String, password: String) async throws -> LoginResponse { fatalError("stub") }
}

final class StubUserInfoService: UserInfoService, @unchecked Sendable {
    func getUserInfo() async throws -> UserInfoResponse { fatalError("stub") }
}

final class StubSocialLoginService: SocialLoginService, @unchecked Sendable {
    func loginWithKakao() async throws -> SocialLoginResponse { fatalError("stub") }
    func logoutKakao() async throws {}
    func unlinkKakao() async throws {}
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse { fatalError("stub") }
    func logoutGoogle() async throws {}
    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse { fatalError("stub") }
    func logoutApple() async throws {}
}

final class StubSignUpService: SignUpService, @unchecked Sendable {
    func sendEmail(_ email: String) async throws -> EmailSendResponse { fatalError("stub") }
    func emailAuthentication(email: String, authNumber: String) async throws -> EmailAuthenticationResponse { fatalError("stub") }
    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse { fatalError("stub") }
    func join(username: String, password: String, nickname: String, email: String) async throws -> JoinResponse { fatalError("stub") }
}

final class StubAccountRecoveryService: AccountRecoveryService, @unchecked Sendable {
    func findID(email: String) async throws -> FindIDResponse { fatalError("stub") }
    func findPassword(email: String) async throws -> FindPasswordResponse { fatalError("stub") }
    func verifyPasswordReset(email: String, authNumber: String) async throws -> VerifyPasswordResetResponse { fatalError("stub") }
    func resetPassword(password: String) async throws -> PasswordResetResponse { fatalError("stub") }
    func setResetToken(resetToken: String) {}
}
