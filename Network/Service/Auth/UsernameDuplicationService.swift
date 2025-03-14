//
//  UsernameDuplicationService.swift
//  QRIZ
//
//  Created by 김세훈 on 3/13/25.
//

import Foundation

protocol UsernameDuplicationService {
    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse
}

final class UsernameDuplicationServiceImpl: UsernameDuplicationService {
    
    private let network: Network
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    func checkUsernameDuplication(username: String) async throws -> UsernameDuplicationResponse {
        let request = UsernameDuplicationRequest(username: username)
        return try await network.send(request)
    }
}
