//
//  UserInfoService.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

protocol UserInfoService {
    func getUserInfo() async throws -> UserInfoResponse
}

final class UserInfoServiceImpl: UserInfoService {
    
    private let network: Network
    private let keychainManager: KeychainManager
    
    init(network: Network = NetworkImp(session: URLSession.shared), keychainManager: KeychainManager = KeychainManagerImpl()) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    func getUserInfo() async throws -> UserInfoResponse {
        let request = UserInfoRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    private func getAccessToken() -> String {
        let accessToken = keychainManager.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        if accessToken.isEmpty { print("OnboardingService failed to get accessToken") }
        return accessToken
    }
}
