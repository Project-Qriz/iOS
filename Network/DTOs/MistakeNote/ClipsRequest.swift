//
//  ClipsRequest.swift
//  QRIZ
//
//  Created by Claude on 1/21/26.
//

import Foundation

/// 오답노트 문제 목록 조회
/// - 최신 데일리: /api/v1/clips?category=2
/// - 특정 데일리: /api/v1/clips?testInfo=Day6
/// - 개념/오답 필터링은 프론트에서 처리
struct ClipsRequest: Request {
    typealias Response = ClipsResponse

    let accessToken: String
    let category: Int?
    let testInfo: String?

    var path: String { "/api/v1/clips" }
    let method: HTTPMethod = .get

    var query: QueryItems {
        var items: QueryItems = [:]

        if let category = category {
            items["category"] = "\(category)"
        }

        if let testInfo = testInfo {
            items["testInfo"] = testInfo
        }

        return items
    }

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    init(
        accessToken: String,
        category: Int? = nil,
        testInfo: String? = nil
    ) {
        self.accessToken = accessToken
        self.category = category
        self.testInfo = testInfo
    }
}

// MARK: - Response

struct ClipsResponse: Decodable {
    let code: Int
    let msg: String
    let data: [ClipsQuestionData]
}

struct ClipsQuestionData: Decodable {
    let id: Int
    let questionNum: Int
    let question: String
    let correction: Bool
    let keyConcepts: String
    let date: String
}
