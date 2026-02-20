//
//  DailyService.swift
//  QRIZ
//
//  Created by 이창현 on 5/1/25.
//

import Foundation
import QRIZUtils

public protocol DailyService {
    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse
    
    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse
    
    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws
    
    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse
    
    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse
    
    func getDailyPlan() async throws -> DailyPlanResponse
    
    func resetPlan() async throws -> DailyResetResponse

    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse
}

public final class DailyServiceImpl: DailyService {
    
    // MARK: - Properties
    private let network: Network
    private let keychainManager: KeychainManager
    
    // MARK: - Initializers
    public init(network: Network = NetworkImpl(session: URLSession.shared), keychainManager: KeychainManager = KeychainManagerImpl()) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    // MARK: - Methods
    public func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse {
        let request = DailyDetailAndStatusRequest(accessToken: getAccessToken(), dayNumber: dayNumber)
        return try await network.send(request)
    }
    
    public func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse {
        let request = DailyTestListRequest(accessToken: getAccessToken(), dayNumber: dayNumber)
        return try await network.send(request)
    }
    
    public func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws {
        let request = DailySubmitRequest(accessToken: getAccessToken(), dayNumber: dayNumber, dailySubmitData: dailySubmitData)
        _ = try await network.send(request)
    }
    
    public func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse {
        let request = DailyResultRequest(accessToken: getAccessToken(), dayNumber: dayNumber)
        return try await network.send(request)
    }
    
    public func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse {
        let request = DailyWeeklyScoreRequest(accessToken: getAccessToken(), day: dayNumber)
        return try await network.send(request)
    }
    
    public func getDailyPlan() async throws -> DailyPlanResponse {
        let request = DailyPlanRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    public func resetPlan() async throws -> DailyResetResponse {
        let request = DailyResetRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }

    public func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse {
        let request = DailyResultDetailRequest(
            accessToken: getAccessToken(),
            dayNumber: dayNumber,
            questionId: questionId
        )
        return try await network.send(request)
    }

    private func getAccessToken() -> String {
        keychainManager.retrieveToken(forKey: TokenKey.accessToken.rawValue) ?? ""
    }
}
