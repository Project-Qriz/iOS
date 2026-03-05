//
//  LoginService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/29/25.
//

import Foundation

public protocol LoginService {
    /// 로그인
    func login(id: String, password: String) async throws -> LoginResponse
}

public final class LoginServiceImpl: LoginService {
    
    // MARK: - Properties
    
    private let network: Network
    
    // MARK: - Initialization

    public init(network: Network = NetworkImpl()) {
        self.network = network
    }
    
    // MARK: - Methods

    public func login(id: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(id: id, password: password)
        return try await network.send(request)
    }
}
