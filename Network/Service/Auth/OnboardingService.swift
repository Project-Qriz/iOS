//
//  OnboardingService.swift
//  QRIZ
//
//  Created by 이창현 on 4/26/25.
//

import Foundation

protocol OnboardingService {
    func sendSurvey(keyConcepts: [String]) async throws
    
    func getPreviewTestList() async throws -> PreviewTestListResponse
    
    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse
    
    func analyzePreview() async throws -> AnalyzePreviewResponse
}

final class OnboardingServiceImpl: OnboardingService {

    // MARK: - Properties
    private let network: Network
    private let keychainManager: KeychainManager
    
    // MARK: - Initializers
    init(network: Network = NetworkImp(session: URLSession.shared), keyChainManager: KeychainManager) {
        self.network = network
        self.keychainManager = keyChainManager
    }
    
    // MARK: - Methods
    func sendSurvey(keyConcepts: [String]) async throws {
        let request = SurveyRequest(accessToken: getAccessToken(), keyConcepts: keyConcepts)
        // SurveyResponse 는 서비스에서 필요 없기 때문에 디버깅용
        let _ = try await network.send(request)
    }
    
    func getPreviewTestList() async throws -> PreviewTestListResponse {
        let request = PreviewTestListRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse {
        let request = PreviewSubmitRequest(accessToken: getAccessToken(), testSubmitDataList: testSubmitDataList)
        return try await network.send(request)
    }
    
    func analyzePreview() async throws -> AnalyzePreviewResponse {
        let request = AnalyzePreviewRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    // reissue로 인한 키체인의 accessToken이 변경되는 경우를 대비해서 매번 가져옴
    private func getAccessToken() -> String {
        let accessToken = keychainManager.retrieveToken(forKey: "accessToken") ?? ""
        if accessToken.isEmpty { print("OnboardingService failed to get accessToken") }
        return accessToken
    }
}
