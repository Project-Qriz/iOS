//
//  LoginService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/29/25.
//

import Foundation

protocol LoginService {
    
    /// 로그인
    func Login(id: String, password: String) async throws  -> LoginResponse
}

final class LoginServiceImpl: LoginService {
    
    // MARK: - Properties
    
    private let network: Network
    
    // MARK: - Initialize
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    // MARK: - Functions
    
    func Login(id: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(id: id, password: password)
        return try await network.send(request)
    }
}
