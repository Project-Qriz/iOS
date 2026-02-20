//
//  WeeklyRecommendService.swift
//  QRIZ
//
//  Created by 김세훈 on 7/20/25.
//

import Foundation
import QRIZUtils

public protocol WeeklyRecommendService {
    /// 주간 추천 개념 조회
    func fetchWeeklyRecommend() async throws -> WeeklyRecommendResponse
}

public final class WeeklyRecommendServiceImpl: WeeklyRecommendService {
    
    // MARK: Properties
    
    private let network : Network
    private let keychain: KeychainManager
    
    // MARK: Initialize
    
    public init(
        network: Network  = NetworkImpl(session: .shared),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network  = network
        self.keychain = keychain
    }
    
    // MARK: Functions
    
    public func fetchWeeklyRecommend() async throws -> WeeklyRecommendResponse {
        let access = keychain.retrieveToken(forKey: TokenKey.accessToken.rawValue) ?? ""
        let request = WeeklyRecommendRequest(accessToken: access)
        return try await network.send(request)
    }
}
