//
//  MistakeNoteService.swift
//  QRIZ
//
//  Created by Claude on 1/21/26.
//

import Foundation

protocol MistakeNoteService {
    /// 오답노트 문제 목록 조회
    /// - Parameters:
    ///   - category: 카테고리 (2 = 데일리)
    ///   - testInfo: 특정 데일리 (ex: "Day6")
    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse

    /// 완료한 데일리 목록 조회
    func getCompletedDays() async throws -> CompletedDailyDaysResponse
}

final class MistakeNoteServiceImpl: MistakeNoteService {

    // MARK: - Properties

    private let network: Network
    private let keychainManager: KeychainManager

    // MARK: - Initializers

    init(
        network: Network = NetworkImpl(session: URLSession.shared),
        keychainManager: KeychainManager = KeychainManagerImpl()
    ) {
        self.network = network
        self.keychainManager = keychainManager
    }

    // MARK: - Methods

    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse {
        let request = ClipsRequest(
            accessToken: getAccessToken(),
            category: category,
            testInfo: testInfo
        )
        return try await network.send(request)
    }

    func getCompletedDays() async throws -> CompletedDailyDaysResponse {
        let request = CompletedDailyDaysRequest(accessToken: getAccessToken())
        return try await network.send(request)
    }

    private func getAccessToken() -> String {
        keychainManager.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
    }
}
