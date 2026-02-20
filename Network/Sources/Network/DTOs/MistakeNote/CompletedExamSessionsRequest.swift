//
//  CompletedExamSessionsRequest.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

/// 완료한 모의고사 리스트 조회
public struct CompletedExamSessionsRequest: Request, Sendable {
    public typealias Response = CompletedExamSessionsResponse

    public let accessToken: String
    public let path = "/api/v1/clips/sessions"
    public let method: HTTPMethod = .get

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

public struct CompletedExamSessionsResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: CompletedExamSessionsData
}

public struct CompletedExamSessionsData: Decodable, Sendable {
    public let sessions: [String]
    public let latestSession: String?
}
