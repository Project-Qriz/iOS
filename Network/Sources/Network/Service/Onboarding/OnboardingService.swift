//
//  OnboardingService.swift
//  QRIZ
//
//  Created by 이창현 on 4/26/25.
//

import Foundation
import QRIZUtils

public protocol OnboardingService {
    func sendSurvey(keyConcepts: [String]) async throws
    
    func getPreviewTestList() async throws -> PreviewTestListResponse
    
    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse
    
    func analyzePreview() async throws -> AnalyzePreviewResponse
}

public final class OnboardingServiceImpl: OnboardingService {

    // MARK: - Properties

    private let network: Network
    private let keychainManager: KeychainManager
    
    // MARK: - Initialization

    public init(network: Network = NetworkImpl(session: URLSession.shared), keychainManager: KeychainManager = KeychainManagerImpl()) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    // MARK: - Methods

    public func sendSurvey(keyConcepts: [String]) async throws {
        let request = SurveyRequest(accessToken: getAccessToken(), keyConcepts: keyConcepts)
        // SurveyResponse 는 서비스에서 필요 없기 때문에 디버깅용
        _ = try await network.send(request)
    }
    
    public func getPreviewTestList() async throws -> PreviewTestListResponse {
        let request = PreviewTestListRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    public func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse {
        let request = PreviewSubmitRequest(accessToken: getAccessToken(), testSubmitDataList: testSubmitDataList)
        return try await network.send(request)
    }
    
    public func analyzePreview() async throws -> AnalyzePreviewResponse {
        let request = AnalyzePreviewRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    private func getAccessToken() -> String {
        keychainManager.retrieveToken(forKey: TokenKey.accessToken.rawValue) ?? ""
    }
}
