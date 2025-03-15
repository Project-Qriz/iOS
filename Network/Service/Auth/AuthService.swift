//
//  AuthService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/15/25.
//

import Foundation

protocol AuthService {
    /// 이메일 인증번호 전송 및 중복 확인
    func sendEmail(_ email: String) async throws -> EmailSendResponse
    
    /// 아이디 중복 체크
    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse
    
    /// 회원가입
    func join(
        username: String,
        password: String,
        nickname: String,
        email: String
    ) async throws -> JoinResponse
}

final class AuthServiceImpl: AuthService {
    
    private let emailSendService: EmailSendService
    private let usernameDuplicationService: UsernameDuplicationService
    private let joinService: JoinService
    
    init(emailSendService: EmailSendService,
         usernameDuplicationService: UsernameDuplicationService,
         joinService: JoinService) {
        self.emailSendService = emailSendService
        self.usernameDuplicationService = usernameDuplicationService
        self.joinService = joinService
    }
    
    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse {
        try await usernameDuplicationService.checkUsernameDuplication(username: username)
    }
    
    func sendEmail(_ email: String) async throws -> EmailSendResponse {
        try await emailSendService.sendEmail(email)
    }
    
    func join(
        username: String,
        password: String,
        nickname: String,
        email: String
    ) async throws -> JoinResponse {
        try await joinService.join(username: username, password: password, nickname: nickname, email: email)
    }
}

