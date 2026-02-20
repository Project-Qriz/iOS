//
//  AccountRecoveryService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

import Foundation

public protocol AccountRecoveryService {
    
    /// 아이디 찾기
    func findID(email: String) async throws -> FindIDResponse
    
    /// 비밀번호 찾기
    func findPassword(email: String) async throws -> FindPasswordResponse
    
    /// 비밀번호 초기화 인증번호 검증
    func verifyPasswordReset(email: String, authNumber: String) async throws -> VerifyPasswordResetResponse
    
    /// 비밀번호 초기화
    func resetPassword(password: String) async throws -> PasswordResetResponse
    
    // 비밀번호 초기화에 필요한 resetToken 저장
    func setResetToken(resetToken: String)
}

public final class AccountRecoveryServiceImpl: AccountRecoveryService {
    
    // MARK: - Properties
    
    private let network: Network
    private var resetToken: String = ""
    
    // MARK: - Initialize
    
    public init(network: Network = NetworkImpl(session: URLSession.shared)) {
        self.network = network
    }
    
    // MARK: - Functions
    
    public func findID(email: String) async throws -> FindIDResponse {
        let request = FindIDRequest(email: email)
        return try await network.send(request)
    }
    
    public func findPassword(email: String) async throws -> FindPasswordResponse {
        let request = FindPasswordRequest(email: email)
        return try await network.send(request)
    }
    
    public func verifyPasswordReset(email: String, authNumber: String) async throws -> VerifyPasswordResetResponse {
        let request = VerifyPasswordResetRequest(email: email, authNumber: authNumber)
        return try await network.send(request)
    }
    
    public func resetPassword(password: String) async throws -> PasswordResetResponse {
        if resetToken.isEmpty {
            throw NetworkError.unknownError
        }
        
        let request = PasswordResetRequest(password: password, resetToken: resetToken)
        return try await network.send(request)
    }
    
    public func setResetToken(resetToken: String) {
        self.resetToken = resetToken
    }
}
