//
//  AccountRecoveryService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

import Foundation


protocol AccountRecoveryService {
    
    /// 아이디 찾기
    func findID(email: String) async throws -> FindIDResponse
    
    /// 비밀번호 찾기
    func findPassword(email: String) async throws -> FindPasswordResponse
    
    /// 비밀번호 초기화 인증번호 검증
    func verifyPasswordReset(authNumber: String) async throws -> VerifyPasswordResetResponse
    
    /// 비밀번호 초기화
    func resetPassword(password: String) async throws -> PasswordResetResponse
}

final class AccountRecoveryServiceImpl: AccountRecoveryService {
    
    // MARK: - Properties
    
    private let network: Network
    
    // MARK: - Initialize
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    // MARK: - Functions
    
    func findID(email: String) async throws -> FindIDResponse {
        let request = FindIDRequest(email: email)
        return try await network.send(request)
    }
    
    func findPassword(email: String) async throws -> FindPasswordResponse {
        let request = FindPasswordRequest(email: email)
        return try await network.send(request)
    }
    
    func verifyPasswordReset(authNumber: String) async throws -> VerifyPasswordResetResponse {
        let request = VerifyPasswordResetRequest(authNumber: authNumber)
        return try await network.send(request)
    }
    
    func resetPassword(password: String) async throws -> PasswordResetResponse {
        let request = PasswordResetRequest(password: password)
        return try await network.send(request)
    }
}
