//
//  LoginService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/29/25.
//

import Foundation
import os.log

protocol LoginService {
    
    /// 로그인
    func login(id: String, password: String) async throws  -> LoginResponse
}

final class LoginServiceImpl: LoginService {
    
    // MARK: - Properties
    
    private let network: Network
    private let keychainManager: KeychainManager
    
    // MARK: - Initialize
    
    init(network: Network = NetworkImp(session: URLSession.shared), keychainManager: KeychainManager) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    // MARK: - Functions
    
    func login(id: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(id: id, password: password)
        
        if let networkImp = network as? NetworkImp {
            let (loginResponse, httpResponse) = try await networkImp.sendWithHeaders(request)
            
            if let authorizationHeader = httpResponse.allHeaderFields["Authorization"] as? String {
                let accessToken = authorizationHeader.replacingOccurrences(of: "Bearer ", with: "")
                let saved = keychainManager.save(token: accessToken, forKey: "accessToken")
                os_log("%{public}@", saved ? "Access token saved" : "Failed to save access token")
            } else {
                os_log("Authorization header missing", type: .error)
            }
            
            return loginResponse
        } else {
            return try await network.send(request)
        }
    }
}
