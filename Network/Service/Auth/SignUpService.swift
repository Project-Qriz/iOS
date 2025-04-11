//
//  SignUpService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/15/25.
//

import Foundation

protocol SignUpService {
    
    /// 이메일 인증번호 전송 및 중복 확인
    func sendEmail(_ email: String) async throws -> EmailSendResponse
    
    /// 인증번호 인증
    func EmailAuthentication(authNumber: String) async throws -> EmailAuthenticationResponse
    
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

final class AuthServiceImpl: SignUpService {
    
    // MARK: - Properties
    
    private let network: Network
    
    // MARK: - Initialize
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    // MARK: - Functions
    
    func sendEmail(_ email: String) async throws -> EmailSendResponse {
        let request = EmailSendRequest(email: email)
        return try await network.send(request)
    }
    
    func EmailAuthentication(authNumber: String) async throws -> EmailAuthenticationResponse {
        let request = EmailAuthenticationRequest(authNumber: authNumber)
        return try await network.send(request)
    }
    
    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse {
        let request = UsernameDuplicationRequest(username: username)
        return try await network.send(request)
    }
    
    func join(
        username: String,
        password: String,
        nickname: String,
        email: String
    ) async throws -> JoinResponse {
        let request = JoinRequest(
            username: username,
            password: password,
            nickname: nickname,
            email: email
        )
        return try await network.send(request)
    }
}
