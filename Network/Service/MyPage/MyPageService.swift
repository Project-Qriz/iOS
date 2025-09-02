//
//  MyPageService.swift
//  QRIZ
//
//  Created by 김세훈 on 6/10/25.
//

import Foundation

protocol MyPageService {
    /// 버전 정보
    func fetchVersion() async throws -> VersionResponse
    
    /// 플랜 초기화
    func resetPlan() async throws -> DailyResetResponse
    
    /// 계정 탈퇴
    func deleteAccount() async throws -> DeleteAccountResponse
    
    /// 카카오 계정 탈퇴
    func deleteKakaoAccount() async throws -> KakaoDeleteAccountResponse
}

final class MyPageServiceImpl: MyPageService {
    
    // MARK: - Properties
    
    private let network: Network
    private let keychain: KeychainManager
    
    // MARK: - Initialize
    
    init(
        network: Network = NetworkImpl(),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network = network
        self.keychain = keychain
    }
    
    // MARK: - Functions
    
    func fetchVersion() async throws -> VersionResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = VersionRequest(accessToken: access)
        return try await network.send(request)
    }
    
    func resetPlan() async throws -> DailyResetResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = DailyResetRequest(accessToken: access)
        return try await network.send(request)
    }
    
    func deleteAccount() async throws -> DeleteAccountResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = DeleteAccountRequest(accessToken: access)
        return try await network.send(request)
    }
    
    func deleteKakaoAccount() async throws -> KakaoDeleteAccountResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = KakaoDeleteAccountRequest(accessToken: access)
        return try await network.send(request)
    }
}
