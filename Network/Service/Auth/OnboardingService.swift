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
    
    // MARK: - Initializers
    init(network: Network = NetworkImp(session: URLSession.shared)) {
        self.network = network
    }
    
    // MARK: - Methods
    func sendSurvey(keyConcepts: [String]) async throws {
        let request = SurveyRequest(keyConcepts: keyConcepts)
        // SurveyResponse 는 서비스에서 필요 없기 때문에 디버깅용
        let _ = try await network.send(request)
    }
    
    func getPreviewTestList() async throws -> PreviewTestListResponse {
        let request = PreviewTestListRequest()
        return try await network.send(request)
    }
    
    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse {
        let request = PreviewSubmitRequest(testSubmitDataList: testSubmitDataList)
        return try await network.send(request)
    }
    
    func analyzePreview() async throws -> AnalyzePreviewResponse {
        let request = AnalyzePreviewRequest()
        return try await network.send(request)
    }
}
