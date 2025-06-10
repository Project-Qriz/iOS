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
}
