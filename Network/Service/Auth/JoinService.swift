//
//  JoinService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/12/25.
//

import Foundation

protocol JoinService {
    func join(
        username: String,
        password: String,
        nickname: String,
        email: String
    ) async throws -> JoinResponse
}

final class JoinServiceImpl: JoinService {
    
    private let network: Network
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    func join(
        username: String,
        password: String,
        nickname: String,
        email: String
    ) async throws -> JoinResponse {
        let request = JoinRequest(
            username: username,
            password: password,
            nickname: nickname,
            email: email
        )
        return try await network.send(request)
    }
}
