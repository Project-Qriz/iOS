//
//  CompletedExamSessionsRequest.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import Foundation

/// 완료한 모의고사 리스트 조회
struct CompletedExamSessionsRequest: Request {
    typealias Response = CompletedExamSessionsResponse

    let accessToken: String
    let path = "/api/v1/clips/sessions"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct CompletedExamSessionsResponse: Decodable {
    let code: Int
    let msg: String
    let data: CompletedExamSessionsData
}

struct CompletedExamSessionsData: Decodable {
    let sessions: [String]
    let latestSession: String?
}
