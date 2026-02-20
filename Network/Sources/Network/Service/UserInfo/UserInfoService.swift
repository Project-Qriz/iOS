//
//  UserInfoService.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation
import QRIZUtils

public protocol UserInfoService {
    func getUserInfo() async throws -> UserInfoResponse
}

public final class UserInfoServiceImpl: UserInfoService {
    
    private let network: Network
    private let keychainManager: KeychainManager
    
    public init(network: Network = NetworkImpl(session: URLSession.shared), keychainManager: KeychainManager = KeychainManagerImpl()) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    public func getUserInfo() async throws -> UserInfoResponse {
        let request = UserInfoRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    private func getAccessToken() -> String {
        let accessToken = keychainManager.retrieveToken(forKey: TokenKey.accessToken.rawValue) ?? ""
        return accessToken
    }
}
