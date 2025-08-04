//
//  WeeklyRecommendService.swift
//  QRIZ
//
//  Created by 김세훈 on 7/20/25.
//

import Foundation

protocol WeeklyRecommendService {
    /// 주간 추천 개념 조회
    func fetchWeeklyRecommend() async throws -> WeeklyRecommendResponse
}

final class WeeklyRecommendServiceImpl: WeeklyRecommendService {
    
    // MARK: Properties
    
    private let network : Network
    private let keychain: KeychainManager
    
    // MARK: Initialize
    
    init(
        network: Network  = NetworkImpl(session: .shared),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network  = network
        self.keychain = keychain
    }
    
    // MARK: Functions
    
    func fetchWeeklyRecommend() async throws -> WeeklyRecommendResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = WeeklyRecommendRequest(accessToken: access)
        return try await network.send(request)
    }
}
