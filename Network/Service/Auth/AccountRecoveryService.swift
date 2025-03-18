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
}
