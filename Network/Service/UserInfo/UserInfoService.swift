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
    
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    func getUserInfo() async throws -> UserInfoResponse {
        let request = UserInfoRequest()
        return try await network.send(request)
    }
}
