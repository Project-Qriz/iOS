//
//  DailyService.swift
//  QRIZ
//
//  Created by 이창현 on 5/1/25.
//

import Foundation

protocol DailyService {
    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse
    
    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse
    
    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws
    
    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse
    
    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse
}

final class DailyServiceImpl: DailyService {
    
    // MARK: - Properties
    private let network: Network
    private let keychainManager: KeychainManager
    
    // MARK: - Initializers
    init(network: Network = NetworkImpl(session: URLSession.shared), keychainManager: KeychainManager = KeychainManagerImpl()) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    // MARK: - Methods
    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse {
        let request = DailyDetailAndStatusRequest(accessToken: getAccessToken(), dayNumber: dayNumber)
        return try await network.send(request)
    }
    
    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        let request = DailyTestListRequest(accessToken: getAccessToken(), dayNumber: dayNumber)
        return try await network.send(request)
    }
    
    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        let request = DailySubmitRequest(accessToken: getAccessToken(), dayNumber: dayNumber, dailySubmitData: dailySubmitData)
        _ = try await network.send(request)
    }
    
    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse {
        let request = DailyResultRequest(accessToken: getAccessToken(), dayNumber: dayNumber)
        return try await network.send(request)
    }
    
    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse {
        let request = DailyWeeklyScoreRequest(accessToken: getAccessToken(), day: dayNumber)
        return try await network.send(request)
    }
    
    private func getAccessToken() -> String {
        let accessToken = keychainManager.retrieveToken(forKey: "accessToken") ?? ""
        if accessToken.isEmpty { print("DailyService failed to get accessToken") }
        return accessToken
    }
}
