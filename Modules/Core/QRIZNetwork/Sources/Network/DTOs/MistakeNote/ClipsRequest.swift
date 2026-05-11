//
//  ClipsRequest.swift
//  QRIZ
//
//  Created by Claude on 1/21/26.
//

/// 오답노트 문제 목록 조회
/// - 최신 데일리: /api/v1/clips?category=2
/// - 특정 데일리: /api/v1/clips?testInfo=Day6
/// - 개념/오답 필터링은 프론트에서 처리
public struct ClipsRequest: Request, Sendable {
    public typealias Response = ClipsResponse

    public let method: HTTPMethod = .get
    private let accessToken: String
    private let category: Int?
    private let testInfo: String?

    public var path: String { "/api/v1/clips" }

    public var query: QueryItems {
        var items: QueryItems = [:]

        if let category = category {
            items["category"] = "\(category)"
        }

        if let testInfo = testInfo {
            items["testInfo"] = testInfo
        }

        return items
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(
        accessToken: String,
        category: Int? = nil,
        testInfo: String? = nil
    ) {
        self.accessToken = accessToken
        self.category = category
        self.testInfo = testInfo
    }
}

public struct ClipsResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [ClipsQuestionData]

    public init(code: Int, msg: String, data: [ClipsQuestionData]) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct ClipsQuestionData: Decodable, Sendable {
    public let id: Int
    public let questionNum: Int
    public let question: String
    public let correction: Bool
    public let keyConcepts: String
    public let date: String
}
