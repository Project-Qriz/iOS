//
//  MistakeNoteService.swift
//  QRIZ
//
//  Created by Claude on 1/21/26.
//

import Foundation
import QRIZUtils

public protocol MistakeNoteService: Sendable {
    /// 오답노트 문제 목록 조회
    /// - Parameters:
    ///   - category: 카테고리 (2 = 데일리, 3 = 모의고사)
    ///   - testInfo: 특정 데일리 (ex: "Day6") 또는 모의고사 세션
    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse

    /// 완료한 데일리 목록 조회
    func getCompletedDays() async throws -> CompletedDailyDaysResponse

    /// 완료한 모의고사 세션 목록 조회
    func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse

    /// 오답노트 문제 상세 조회
    /// - Parameter clipId: 문제 ID (MistakeNoteQuestion.id)
    func getClipDetail(clipId: Int) async throws -> ClipDetailResponse
}

public final class MistakeNoteServiceImpl: MistakeNoteService, Sendable {

    // MARK: - Properties

    private let network: Network
    private let keychainManager: KeychainManager

    // MARK: - Initialization

    public init(
        network: Network = NetworkImpl(session: URLSession.shared),
        keychainManager: KeychainManager = KeychainManagerImpl()
    ) {
        self.network = network
        self.keychainManager = keychainManager
    }

    // MARK: - Methods

    public func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse {
        let request = ClipsRequest(
            accessToken: getAccessToken(),
            category: category,
            testInfo: testInfo
        )
        return try await network.send(request)
    }

    public func getCompletedDays() async throws -> CompletedDailyDaysResponse {
        let request = CompletedDailyDaysRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }

    public func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse {
        let request = CompletedExamSessionsRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }

    public func getClipDetail(clipId: Int) async throws -> ClipDetailResponse {
        let request = ClipDetailRequest(
            accessToken: getAccessToken(),
            clipId: clipId
        )
        return try await network.send(request)
    }

    private func getAccessToken() -> String {
        keychainManager.retrieveToken(forKey: TokenKey.accessToken.rawValue) ?? ""
    }
}
