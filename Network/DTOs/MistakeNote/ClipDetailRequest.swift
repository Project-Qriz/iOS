//
//  ClipDetailRequest.swift
//  QRIZ
//
//  Created by Claude on 1/28/26.
//

import Foundation

/// 오답노트 문제 상세 조회
/// GET /api/v1/clips/{clipId}/detail
struct ClipDetailRequest: Request {
    typealias Response = ClipDetailResponse

    let accessToken: String
    let clipId: Int

    var path: String { "/api/v1/clips/\(clipId)/detail" }
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

// MARK: - Response

struct ClipDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: DailyResultDetail
}
