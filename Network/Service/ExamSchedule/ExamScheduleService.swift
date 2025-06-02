//
//  ExamScheduleService.swift
//  QRIZ
//
//  Created by 김세훈 on 5/25/25.
//

import Foundation

protocol ExamScheduleService {
    /// 등록된 시험 조회
    func fetchAppliedExams() async throws -> AppliedExamsResponse
    
    /// 시험 접수 목록 조회
    func fetchExamList() async throws -> ExamScheduleListResponse
    
    /// 시험 접수 신청
    func applyExamSchedule(applyId: Int) async throws -> ApplyExamScheduleResponse
    
    /// 시험 일정 변경
    func updateExamSchedule(userApplyId: Int, newApplyId: Int) async throws -> UpdateExamScheduleResponse
}

final class ExamScheduleServiceImpl: ExamScheduleService {
    
    // MARK: - Properties
    
    private let network: Network
    private let keychain: KeychainManager
    
    // MARK: - Initialize
    
    init(
        network: Network = NetworkImpl(session: URLSession.shared),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network = network
        self.keychain = keychain
    }
    
    // MARK: - Functions
    
    func fetchAppliedExams() async throws -> AppliedExamsResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = AppliedExamsRequest(accessToken: access)
        return try await network.send(request)
    }
    
    func fetchExamList() async throws -> ExamScheduleListResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = ExamScheduleListRequest(accessToken: access)
        return try await network.send(request)
    }
    
    func applyExamSchedule(applyId: Int) async throws -> ApplyExamScheduleResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = ApplyExamScheduleRequest(accessToken: access, applyId: applyId)
        return try await network.send(request)
    }
    
    func updateExamSchedule(userApplyId: Int, newApplyId: Int) async throws -> UpdateExamScheduleResponse {
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = UpdateExamScheduleRequest(
            accessToken: access,
            userApplyId: userApplyId,
            newApplyId: newApplyId
        )
        return try await network.send(request)
    }
}

