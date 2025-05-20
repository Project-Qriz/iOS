//
//  ExamService.swift
//  QRIZ
//
//  Created by ch on 5/6/25.
//

import Foundation

protocol ExamService {
    func getExamList() async throws -> ExamListResponse
    
    func getExamQuestion(examId: Int) async throws -> ExamQuestionResponse
    
    func submitTest(examId: Int, testSubmitData: [TestSubmitData]) async throws
    
    func getExamScore(examId: Int) async throws -> ExamScoreResponse
    
    func getExamResult(examId: Int) async throws -> ExamResultResponse
}

final class ExamServiceImpl: ExamService {
    
    // MARK: - Properties
    private let network: Network
    private let keychainManager: KeychainManager
    
    // MARK: - Initializers
    init(network: Network = NetworkImp(session: URLSession.shared), keychainManager: KeychainManager = KeychainManagerImpl()) {
        self.network = network
        self.keychainManager = keychainManager
    }
    
    // MARK: - Methods
    func getExamList() async throws -> ExamListResponse {
        let request = ExamListRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }
    
    func getExamQuestion(examId: Int) async throws -> ExamQuestionResponse {
        let request = ExamQuestionRequest(accessToken: getAccessToken(), examId: examId)
        return try await network.send(request)
    }
    
    func submitTest(examId: Int, testSubmitData: [TestSubmitData]) async throws {
        let request = TestSubmitRequest(accessToken: getAccessToken(), examId: examId, testSubmitData: testSubmitData)
        _ = try await network.send(request)
    }
    
    func getExamScore(examId: Int) async throws -> ExamScoreResponse {
        let request = ExamScoreRequest(accessToken: getAccessToken(), examId: examId)
        return try await network.send(request)
    }
    
    func getExamResult(examId: Int) async throws -> ExamResultResponse {
        let request = ExamResultRequest(accessToken: getAccessToken(), examId: examId)
        return try await network.send(request)
    }
    
    private func getAccessToken() -> String {
        let accessToken = keychainManager.retrieveToken(forKey: "accessToken") ?? ""
        if accessToken.isEmpty { print("ExamService failed to get accessToken") }
        return accessToken
    }
}
