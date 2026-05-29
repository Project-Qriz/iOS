//
//  MockSignUpService.swift
//  AccountTests
//

import Foundation
import QRIZNetwork

final class MockSignUpService: SignUpService, @unchecked Sendable {

    var sendEmailResult: Result<EmailSendResponse, Error> = .success(
        EmailSendResponse(code: 1, msg: "ok", data: "인증번호 발송")
    )
    var emailAuthResult: Result<EmailAuthenticationResponse, Error> = .success(
        EmailAuthenticationResponse(code: 1, msg: "ok")
    )
    var checkUsernameResult: Result<UsernameDuplicationResponse, Error> = .success(
        UsernameDuplicationResponse(
            code: 1,
            msg: "ok",
            data: .init(available: true)
        )
    )
    var joinResult: Result<JoinResponse, Error> = .success(
        .success(JoinResponseSuccess(
            code: 1,
            msg: "ok",
            data: .init(id: 1, username: "test", nickname: "테스트")
        ))
    )

    func sendEmail(_ email: String) async throws -> EmailSendResponse {
        try sendEmailResult.get()
    }

    func emailAuthentication(email: String, authNumber: String) async throws -> EmailAuthenticationResponse {
        try emailAuthResult.get()
    }

    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse {
        try checkUsernameResult.get()
    }

    func join(username: String, password: String, nickname: String, email: String) async throws -> JoinResponse {
        try joinResult.get()
    }
}
