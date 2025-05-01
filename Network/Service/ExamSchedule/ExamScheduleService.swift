//
//  ExamScheduleService.swift
//  QRIZ
//
//  Created by 김세훈 on 5/1/25.
//

import Foundation

protocol ExamScheduleService {
    /// 등록된 시험 조회
    func fetchAppliedExams() async throws -> AppliedExamsResponse
}

final class ExamScheduleServiceImpl: ExamScheduleService {
    
    // MARK: - Properties
    
    private let network: Network
    private let keychain: KeychainManager
    
    // MARK: - Initialize
    
    init(
        network: Network = NetworkImp(session: URLSession.shared),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network = network
        self.keychain = keychain
    }
    
    // MARK: - Functions
    
    func fetchAppliedExams() async throws -> AppliedExamsResponse {
        let access = keychain.retrieveToken(forKey: "accessToken") ?? ""
        return try await network.send(AppliedExamsRequest(accessToken: access))
    }
}
